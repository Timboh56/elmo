class SmsResponse < ActiveRecord::Base
  attr_accessible :message, :response_id
  
  belongs_to :response
  
  validates(:message, :presence => true)
  validates(:response_id, :presence => true)
  
  
	def initialize
	@outgoing_message = ''
	@noerrors = true
	end
	
	def load_message?(message)
		if decipher? (message)
			getAnswers
		end
		
		return @noerrors
	end
	
	
	private
	def decipher? (message)
		result = message.scan(/^(! ?([0-9]+) ([^\-]+[a-z0-9]{1})) ?-?(r)?$/)
		result_array = result[0]		
		@noerrors = true
		
		unless result_array == nil
			@form_id = result_array[1]
			
			@form = Form.find_by_id(@form_id)
			
			unless(@form == nil)
				unless(@form.published == true)
					@outgoing_message = 'sms.error.formNotAvailable'
					@noerrors = nil
				else
					@sms_codes = SmsCode.where('form_id = ?',@incoming_form_id) 		
					@question_count = SmsCode.where('form_id = ?',@incoming_form_id).map(&:questioning).uniq.count
					
					@incoming_fullcode = result_array[0]
					@incoming_message = result_array[2]	
					@incoming_flag = result_array[3]
					
					@incoming_codes = @incoming_message.strip.split(' ')
					if(@question_count != @incoming_codes.count)
						@outgoing_message = 'sms.error.numberOfAnswersDoNotMatch'
						@noerrors = nil
					end
				end
			else
				@outgoing_message = @outgoing_message = 'sms.error.formNotFound.'+@form_id
				@noerrors = nil
			end
			
		else
			@outgoing_message = 'sms.error.cantReadMessage'
			@noerrors = nil
		end
		return @noerrors
	end
	
	
	def getAnswers?
		@answers = []
		@incoming_codes.each { |code|	
			result = code.scan(/^([0-9]+)\.(.+)?$/)
			incoming_question_number = result[0][0]
			incoming_answer = result[0][1]
							
			sms_codes = SmsCode.where('form_id = ? AND question_number = ?', @incoming_form_id, incoming_question_number)
			type = sms_codes.first.questioning.question.type.name
			
			case type
			when 'integer'
				if incoming_answer is_a? Integer
					add_answer(sms_codes.first, incoming_answer)
				else
					@outgoing_message = 'sms.error.answerNotAnInteger.'+incoming_question_number
					@noerrors = nil
				end
			when 'select_one'
				answer = sms_codes.select { |c| c.code == incoming_answer}
				unless answer == nil
					add_answer(answer.first)
				else
					@outgoing_message = 'sms.error.answerNotValid.'+incoming_question_number
					@noerrors = nil
				end
			when 'select_mutiple'
				answers = incoming_answer.split('')
			
				answers.each( |a|
					answer = sms_codes.select { |c| c.code == a}
					unless answer == nil
						add_answer(answer.first)
					else
						@outgoing_message = 'sms.error.answerNotValid.'+incoming_question_number
						@noerrors = nil
					end	
				}
			else
				@outgoing_message = 'sms.error.system'
				@noerrors = nil
			end				
		}	
		return noerrors
	end
	
	def add_answer(code, value = nil)
		@answers << {
			'form_id' => code.form_id,
			'questioning_id' => code.form_id,
			'option_id' => code.option_id,
			'value' => value
		}
	end
	
	def is_flagged?
		flag_action = nil 
		unless @incoming_flag == nil

			case @incoming_flag
			when 'r'
				sms_response = SmsResponse.find(:all, :conditions => ["responses.user_id = ? AND sms = ? AND sms_responses.created_at BETWEEN ? AND ?", @sender.id, @incoming_fullcode, Time.now - 45.minutes, Time.now], :joins => {:response =>{}} ).first
				flag_action = (sms_response == nil ? nil : true)
			end	
		end
		return flag_action
	end
  
end
