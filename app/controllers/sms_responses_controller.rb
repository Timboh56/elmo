class SmsResponsesController < ApplicationController
	def incoming					
		@adapter = Sms::Adapters::Factory.new.create(params[:provider])
		smses = adapter.receive(params) # return hash with phone number and message

		I18n.locale = params[:lng]
		
		smses.each{ |sms|
			begin	
				sender_info = User.where('phone = ? || phone2 = ?', sms.phone, sms.phone)
			rescue ActiveRecord::RecordNotFound
				#  #blank message for non-recognized numbers
			else
				
				unless sender_info.count > 1
					
					@sender = sender_info.first
					sms_response = new SmsResponse
					
					if sms_response.message_loaded?(sms.message)
						
						mission = sms_response.get_missionn
						Setting.find_or_create(mission)
						
						if @sender.can_access_mission?(mission)
				
							sms_response.save_answers(@sender)
							
							message = t(sms_response.get_outgoing_message, sms_response.get_outgoing_messag_vars),
						
						else
							message = t('sms.form.permission_denied', :form_id => sms_response.get_form_id, :message=>sms.message),
						end
						
					else
						message = t(sms_response.get_outgoing_message, sms_response.get_outgoing_messag_vars),					
					end
				
				else
					message = t 'sms.error.system.multiple_users'
					
					@adapter.add_outgoing_message('sms.error.system.multiple_users', sms.phone)
				
				end
				
				@adapter.add_outgoing_message(message, sms.phone))
			
			end
		}
		
		@output = @adapter.get_reply()
		render :template => "sms_responses/ok.#{@output[:format]}.erb"
  	end
end
