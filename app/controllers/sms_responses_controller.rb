class SmsResponsesController < ApplicationController
	
	def incoming				
		@adapter = Sms::Adapters::Factory.new.create(params[:provider])
		smses = @adapter.receive(params) # return hash with phone number and message

		I18n.locale = params[:lng]
		
		smses.each do |sms|
				sender_info = User.where('phone = ? || phone2 = ?', sms[:phone], sms[:phone])
			unless sender_info.empty?
				unless sender_info.count > 1
					
					sender = sender_info.first					
					
					if SmsResponse.message_loaded?(sms[:message])
						
						mission = SmsResponse.get_mission
						Setting.find_or_create(mission)
						
						if sender.can_access_mission?(mission)
				
							SmsResponse.save_answers(sender)									
						else
							@message = t 'sms.form.permission_denied', :form_id => sms_response.get_form_id, :message=>sms[:message]
						end						
					end
				else
					@message = t 'sms.error.system.multiple_users'
									
				end
				unless @message
					m = SmsResponse.get_outgoing
					@message = t m[:message], m[:vars]
				end
				@adapter.add_outgoing_message(@message, sms[:phone])
			
			else
				#  #blank message for non-recognized numbers
			end
		end
		
		@output = @adapter.get_reply()
		render :template => "sms_responses/ok.#{@output[:format]}.erb"
  	end
end
