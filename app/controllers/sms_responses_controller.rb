class SmsResponsesController < ApplicationController
	
	def incoming				
		# test_xml_doc = "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>\r\n<Response>\r\n<Msg_Count>6</Msg_Count>\r\n<MessageNotification>\r\n<Message_Index>1</Message_Index>\r\n<ModemNumber>1:0823971496</ModemNumber>\r\n<SenderNumber>+243813688939</SenderNumber>\r\n<Date>13/02/26</Date>\r\n<Time>13:19:18</Time>\r\n<EncodingFlag>ASCII</EncodingFlag>\r\n<Message>!9 1 2.ad 3.e</Message>\r\n</MessageNotification>\r\n<MessageNotification>\r\n<Message_Index>2</Message_Index>\r\n<ModemNumber>1:0823971496</ModemNumber>\r\n<SenderNumber>+243816107022</SenderNumber>\r\n<Date>13/02/26</Date>\r\n<Time>13:23:07</Time>\r\n<EncodingFlag>ASCII</EncodingFlag>\r\n<Message> !1 1.3 2.ac 3.a</Message>\r\n</MessageNotification>\r\n<MessageNotification>\r\n<Message_Index>3</Message_Index>\r\n<ModemNumber>1:0823971496</ModemNumber>\r\n<SenderNumber>+243816107022</SenderNumber>\r\n<Date>13/02/26</Date>\r\n<Time>13:26:53</Time>\r\n<EncodingFlag>ASCII</EncodingFlag>\r\n<Message>!9 1.6 2.af 3.e</Message>\r\n</MessageNotification>\r\n<MessageNotification>\r\n<Message_Index>4</Message_Index>\r\n<ModemNumber>1:0823971496</ModemNumber>\r\n<SenderNumber>+243816107022</SenderNumber>\r\n<Date>13/02/26</Date>\r\n<Time>13:52:04</Time>\r\n<EncodingFlag>ASCII</EncodingFlag>\r\n<Message>!9 1.6 2.af 3.e</Message>\r\n</MessageNotification>\r\n<MessageNotification>\r\n<Message_Index>5</Message_Index>\r\n<ModemNumber>1:0823971496</ModemNumber>\r\n<SenderNumber>+243816107022</SenderNumber>\r\n<Date>13/02/26</Date>\r\n<Time>13:53:09</Time>\r\n<EncodingFlag>ASCII</EncodingFlag>\r\n<Message>!9 1.6 2.af 3.e</Message>\r\n</MessageNotification>\r\n<MessageNotification>\r\n<Message_Index>6</Message_Index>\r\n<ModemNumber>1:0823971496</ModemNumber>\r\n<SenderNumber>+243813688939</SenderNumber>\r\n<Date>13/02/26</Date>\r\n<Time>13:56:39</Time>\r\n<EncodingFlag>ASCII</EncodingFlag>\r\n<Message>!9 1.2 2.ac 3.c</Message>\r\n</MessageNotification>\r\n</Response>"
		# params[:XMLDATA] = test_xml_doc.html_safe
		
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
		render :template => "sms_responses/ok.#{@output[:format]}", :layout => false
  	end
end
