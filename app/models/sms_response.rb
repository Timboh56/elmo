class SmsResponse < ActiveRecord::Base
  attr_accessible :message, :response_id
  
  belongs_to :response
  
  validates(:message, :presence => true)
  validates(:response_id, :presence => true)
  
  
	def initialize
		@outgoing_message = 'sms.error.general'
		@noerrors = true
	end
	
	def message_loaded?(message)
		if message_decoded? (message)
			get_answers
		end	
		return @noerrors
	end
	
	def save_answers(sender)
		unless is_flagged?
			all_answers = Hash[*answers]
			self.response = Response.create(:form => @form, :user => sender, :mission => @mission, 'source' => 'sms', :all_answers => all_answers)			
			
			if self.responsenew_record ?
				self.save
				@outgoing_message = 'sms.success'
				@outgoing_message_vars = {:message=>@message}
			else
				@outgoing_message = 'sms.response.not_valid'
				@outgoing_message_vars = {:message=>@message}
			end
		else
			@outgoing_message = 'sms.success'
			@outgoing_message_vars = {:message=>@message}
		end
	end
	
	def get_outgoing_message
		@outgoing_message	
	end
	
	def get_outgoing_messag_vars
		@outgoing_vars	
	end
	
	def get_form_id
		@form_id	
	end
	
	def get_mission
		@mission
	end
	
	private
	def message_decoded? (message)
		@message = message
		result = message.scan(/^(! ?([0-9]+) ([^\-]+[a-z0-9]{1})) ?-?(r)?$/)
		result_array = result[0]		
		@noerrors = true
		
		unless result_array == nil
			@form_id = result_array[1]
			begin	
				@form = Form.find_by_id(@form_id)
			rescue ActiveRecord::RecordNotFound
				@outgoing_message = 'sms.error.form.not_found.'
				@outgoing_message_vars = {:form_id=>@form_id, :message=>@message}
				@noerrors = nil
			else
				if (@form.published == true)
					@mission = @form.mission

					question_count = SmsCode.where('form_id = ?',@incoming_form_id).map(&:questioning).uniq.count
					
					self.message = result_array[0]
					@incoming_message = result_array[2]	
					@incoming_flag = result_array[3]
					
					@incoming_codes = @incoming_message.strip.split(' ')
					if(question_count != @incoming_codes.count)
						@outgoing_message = 'sms.error.message.no_of_answers'
						@outgoing_message_vars = {:no_responses => @incoming_codes.count, :no_questions => question_count, :message=>@message}

						@noerrors = nil
					end	
				else
					@outgoing_message = 'sms.error.form.not_avail.'
					@outgoing_message_vars = {:form_id => @form_id, :message=>@message}					
					@noerrors = nil
				end
			end	
		else
			@outgoing_message = 'sms.error.message.cant_read'
			@outgoing_message_vars = {:message => @message }
			@noerrors = nil
		end
		return @noerrors
	end
	
	
	def get_answers
		@answers = []
		@incoming_codes.each { |code|	
			result = code.scan(/^([0-9]+)\.(.+)?$/)
			incoming_question_number = result[0][0]
			incoming_answer = result[0][1]
			
			begin
				sms_codes = SmsCode.where('form_id = ? AND question_number = ?', @incoming_form_id, incoming_question_number)
			rescue ActiveRecord::RecordNotFound
				@outgoing_message = 'sms.error.response.question_not_found.'
				@outgoing_message_vars = {:message => @message, ':question_no'=> incoming_question_number}				
				@noerrors = nil
			else
				type = sms_codes.first.questioning.question.type.name
				
				case type
				when 'integer'
					if incoming_answer is_a? Integer
						add_answer(sms_codes.first, incoming_answer)
					else
						@outgoing_message = 'sms.error.response.NotAnInteger.'
						@outgoing_message_vars = {:message => @message, ':question_no'=> incoming_question_number, :response=>incoming_answer}				
						@noerrors = nil
					end
				when 'select_one'
					answer = sms_codes.select { |c| c.code == incoming_answer}
					unless answer == nil
						add_answer(answer.first)
					else
						@outgoing_message = 'sms.error.response.not_valid_specific.'
						@outgoing_message_vars = {:message => @message, ':question_no'=> incoming_question_number, :response=>answer}				
						@noerrors = nil
					end
				when 'select_mutiple'
					answers = incoming_answer.split('')
				
					answers.each( |a|
						answer = sms_codes.select { |c| c.code == a}
						unless answer == nil || @noerrors = nil
							add_answer(answer.first)
						else
							@outgoing_message = 'sms.error.response.not_valid_specific.'
							@outgoing_message_vars = {:message => @message, ':question_no'=> incoming_question_number, :response=> a}				
							@noerrors = nil
						end	
					}
				else
					@outgoing_message = 'sms.error.system'
					@noerrors = nil
				end
			end
		}	
		return noerrors
	end
	
	def add_answer(code, value = nil)
		@answers << {:relevant=> 'true', :response_id => '', :option_id => code.option.id, :questioning_id => code.questioning.id, :value => value }
	end
	
	def is_flagged?
		flag_action = nil 
		unless @incoming_flag == nil

			case @incoming_flag
			when 'r'
				sms_response = SmsResponse.find(:all, :conditions => ["responses.user_id = ? AND sms = ? AND sms_responses.created_at BETWEEN ? AND ?", @sender.id, self.message, Time.now - 45.minutes, Time.now], :joins => {:response =>{}} ).first
				flag_action = (sms_response == nil ? nil : true)
			end	
		end
		return flag_action
	end
  
end
