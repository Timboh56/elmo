class SmsResponsesController < ApplicationController
	def incoming				
		
		@adapter = Sms::Adapters::Factory.create(params[:provider])
		# sms = adapter.receive(params) # return hash with number and message
		# isms = new ISMSAdapter
		
		# if User find by phone 1 OR phone 2
		
			#sms_response = new smsResponse
		
			#if response = sms_response.load_message?(sms.message) #decodes and deciphers
				# form_id = sms_response.get_form_id
				# mission = get_mission
				#if user has access
					# response.save
					# sms_response.save
				#else
					# message = 'sms.error.cantaccess' 
				#end	
			#else
				# message = response.getMessage
			#end
			
			# adapter.reply(message, phone)
			
			@output = 'hello'
			render :template => "sms_responses/ok.txt.erb"
  	end
  	
  	
  		
end
