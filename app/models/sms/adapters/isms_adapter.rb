class Sms::Adapters::ISMSAdapter < Sms::Adapters::Adapter
  
  def initialize
  	  @incoming_messages = []
  	  @outgoing_messages = []
  end
  
  def service_name
    "ISMS"
  end
  
  def receive (params)		
		hash = Hash.from_xml( params[:XMLDATA] )				
		base = hash['Response']['MessageNotification']
		if base.is_a? Array
			base.each{ |message|
				m = {
					:phone => message['SenderNumber'],
					:message => message['Message']
					}
				messages << m
			}
		else
			m = {
				:phone => base['SenderNumber'],
				:message => base['Message']
				}
			incoming_messages << m
		end
		return incoming_messages
	end
	
	def add_outgoing_message (message)
		@outgoing_messages << message
	end
  
end