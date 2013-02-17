class SmsResponsesController < ApplicationController
	def incoming				
		
		@adapter = Sms::Adapters::Factory.new.create(params[:provider])
		smses = adapter.receive(params) # return hash with phone number and message

		smses.each{ |sms|
			sender_info = User.where('phone = ? || phone2 = ?', sms.phone, sms.phone)
			unless sender_info.empty?
				unless sender_info.count > 1
					@sender = sender_info.first
					sms_response = new smsResponse
					if sms_response.load_message?(sms.message)
						# form_id = sms_response.get_form_id
						# mission = get_mission
						#if user has access
							# response.save
							# sms_response.save
						#else
							# message = 'sms.error.cantaccess' 
						#end
					else
						@adapter.add_outgoing_message( sms_response.get_outgoing_message) )
					end
				else
					@adapter.add_outgoing_message('sms.error.morethanoneuserwithphone')
				end
			else	
				#  #blank message for non responses
			end
		}
		
		#adapter.reply(phone)
			
		@output = 'hello'
		render :template => "sms_responses/ok.txt.erb"
  	end
  	
  	
  		
end
