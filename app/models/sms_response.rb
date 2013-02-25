class SmsResponse < ActiveRecord::Base
  attr_accessible :message, :response_id
  
  belongs_to :response
  
  validates(:message, :presence => true)
  validates(:response_id, :presence => true)
  	
	
	def self.message_loaded?(message)
		@outgoing = {:message=>'sms.error.system.general', :vars=>{:message=>message}}
		@noerrors = true
		if self.message_decoded? (message)
			self.get_answers
		end	
		return @noerrors
	end
	
	def self.save_answers(sender)
	@sender = sender
	Rails.logger.debug(@answers)
		unless self.is_flagged?
			resp = Response.new(:form => @form, :user => sender, :mission => @mission, 'source' => 'sms', :answers => @answers)			
			resp.save!
			unless resp.new_record?
				@outgoing[:message] = 'sms.success'
    			sms_resp = create(:message => @message, :response_id => resp.id )
				sms_resp.save!
			else
				@outgoing[:message] = 'sms.error.response.not_valid'
			end
		else
			@outgoing[:message] = 'sms.success'
		end
	end
	
	def self.get_outgoing
		@outgoing	
	end
	
	def self.get_form_id
		@form_id	
	end
	
	def self.get_mission
		@mission
	end
	
	private
	def self.message_decoded? (message)
		result = message.scan(/^(! ?([0-9]+) ([^\-]+[a-z0-9]{1})) ?-?(r)?$/).first				
		unless result == nil
			@form_id = result[1]
			begin	
				@form = Form.find_by_id!(@form_id)
			rescue ActiveRecord::RecordNotFound
				@outgoing[:message] = 'sms.error.form.not_found.'
				@outgoing[:vars][:form_id] = @form_id
				@noerrors = nil
			else
				if (@form.published == true)
					@mission = @form.mission

					question_count = SmsCode.where('form_id = ?',@form_id).map(&:questioning).uniq.count
					
					@message = result[0]
					message_code = result[2]	
					@message_flag = result[3]
					
					@incoming_codes = message_code.strip.split(' ')
					if(question_count != @incoming_codes.count)
						@outgoing[:message] = 'sms.error.message.no_of_answers'
						@outgoing[:vars][:no_responses] = @incoming_codes.count
						@outgoing[:vars][:no_questions] = question_count

						@noerrors = nil
					end	
				else
					@outgoing[:message] = 'sms.error.form.not_avail'
					@outgoing[:vars][:form_id] = @form_id					
					@noerrors = nil
				end
			end	
		else
			@outgoing[:message] = 'sms.error.message.cant_read'
			@noerrors = nil
		end
		return @noerrors
	end
	
	
	def self.get_answers
		@answers = []
		@incoming_codes.each_with_index { |code, n|	
			result = code.scan(/^([0-9]+)\.(.+)?$/)
			incoming_question_number = result[0][0]
			incoming_answer = result[0][1]
			sms_codes = SmsCode.where('form_id = ? AND question_number = ?', @form_id, incoming_question_number)
			if sms_codes.empty?
				@outgoing[:message] = 'sms.error.response.question_not_found.'
				@outgoing[:vars][:question_no] =  incoming_question_number				
				@noerrors = nil
			else
				if @noerrors == true	
					type = sms_codes.first.questioning.question.type.name
					case type
					when 'integer'
						int = incoming_answer.scan(/\A[0-9]+\Z/).first					
						unless int == nil
							self.add_answer(n, sms_codes.first, int.to_i)
						else
							@outgoing[:message] = 'sms.error.response.NotAnInteger.'
							@outgoing[:vars][:question_no] =  incoming_question_number				
							@outgoing[:vars][:response] =  incoming_answer						
							@noerrors = nil
						end
					when 'select_one'
						answer = sms_codes.select { |c| c.code == incoming_answer}
						unless answer == nil
							add_answer(n, answer.first)
						else
							@outgoing[:message] = 'sms.error.response.not_valid_specific.'
							@outgoing[:vars][:question_no] =  incoming_question_number				
							@outgoing[:vars][:response] =  incoming_answer							
							@noerrors = nil
						end
					when 'select_multiple'
						choices = []
						answers = incoming_answer.split('')
						answers.each do |a| 
							answer = sms_codes.select { |c| c.code == a}
							unless answer == nil
								choices << answer.first.option.id
							else @noerrors == true
								@outgoing[:message] = 'sms.error.response.not_valid_specific.'
								@outgoing[:vars][:question_no] =  incoming_question_number				
								@outgoing[:vars][:response] =  a							
								@noerrors = nil
							end	
						end
						unless @noerrors == nil
							add_answer(n, answer.first, nil, choices)
						end
					else
						@outgoing[:message] = 'sms.error.system.general'
						@noerrors = nil
					end
				end
			end
		}	
		return @noerrors
	end
	
	def self.add_answer(n, code, value = nil, choices=nil)
		ans = Answer.new(:relevant=> 'true', :response_id => '', :option_id => (code.option == nil || choices == true ? nil : code.option.id), :questioning_id => code.questioning.id, :value => value )
		unless choices == nil
			choices.each do |c|
				ans.choices.build(:option_id => c)
			end
		end
		@answers << ans
	end
	
	def self.is_flagged?
		flag_action = nil 
		unless @message_flag == nil

			case @message_flag
			when 'r'
				sms_response = SmsResponse.find(:all, :conditions => ["responses.user_id = ? AND message = ? AND sms_responses.created_at BETWEEN ? AND ?", @sender.id, @message, Time.now - 45.minutes, Time.now], :joins => {:response =>{}} ).first
				flag_action = (sms_response == nil ? nil : true)
			end	
		end
		return flag_action
	end
  
end
