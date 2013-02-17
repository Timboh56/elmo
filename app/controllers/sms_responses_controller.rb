class SmsResponsesController < ApplicationController
	def incoming					
		@adapter = Sms::Adapters::Factory.new.create(params[:provider])
		smses = adapter.receive(params) # return hash with phone number and message

		I18n.locale = configatron.outgoing_sms_language
		
		smses.each{ |sms|
			begin	
				sender_info = User.where('phone = ? || phone2 = ?', sms.phone, sms.phone)
			rescue ActiveRecord::RecordNotFound
				#  #blank message for non-recognized numbers
			else
				
				unless sender_info.count > 1
					
					@sender = sender_info.first
					sms_response = new smsResponse
					
					if sms_response.message_loaded?(sms.message)
						
						mission = sms_response.get_missionn
						
						if @sender.can_access_mission?(mission)
							
							sms_response.save_answers(@sender)
							@adapter.add_outgoing_message( sms_response.get_outgoing_message(), sms.phone )
						
						else	
							@adapter.add_outgoing_message('sms.error.cantAccessForm.'+form.id.to_s, sms.phone)
						
						end
						
					else
						@adapter.add_outgoing_message( sms_response.get_outgoing_message(), sms.phone )
					
					end
				
				else
					@adapter.add_outgoing_message('sms.error.moreThanOneUserWithPhone', sms.phone)
				
				end				
			end
		}
		
		@output = @adapter.get_reply()
		render :template => "sms_responses/ok.#{@output[:format]}.erb"
  	end
end
