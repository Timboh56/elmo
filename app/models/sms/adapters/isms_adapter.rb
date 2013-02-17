class Sms::Adapters::ISMSAdapter < Sms::Adapters::Adapter
  require 'open-uri'
  require 'uri'
  
  
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
				@incoming_messages << m
			}
		else
			m = {
				:phone => base['SenderNumber'],
				:message => base['Message']
				}
			@incoming_messages << m
		end
		return @incoming_messages
	end
	
	def deliver(message, options = {})
	super	
		numbers = message.to.join(',')
		text = URI.encode(message.body)
		numbers.each{ |n|
			# build the URI the request
			uri = build_uri("sendmsg", "to=\"#{n}\"&text=#{text}")
			Rails.logger.debug("http request: #{@uri}")
			
			# honor the dont_send option
			unless options[:dont_send]
			  response = send_request(uri)
			  # no error reporting from isms  
			end
		}
		# if we get to this point, it worked
		return true
	end
	
	
	def get_reply
		unless @outgoing_messages.empty?
				
			outgoing_messages.each{ |m|
				deliver(m.phone, m.message)
			}
		end
		return {:output => '', 'format'=>'txt'}
	
	end
	
	def add_outgoing_message (message, phone)
		@outgoing_messages << {:message => message, :phone => phone}
	end
	
	private
    # builds uri based on given action and query string params
    def build_uri(action, params = "")
    	"http://#{configatron.outgoing_sms_extra}/#{action}?" + 
    	"user=#{@outgoing_sms_username}&passwd=#{@outgoing_sms_password}&cat=1&#{params}"
    
      "http://www.intellisoftware.co.uk/smsgateway/#{action}.aspx?" +
        "username=#{configatron.intellisms_username}&password=#{configatron.intellisms_password}&#{params}"
    end
    
    # sends request to given uri and returns response
    def send_request(uri)
      open(uri){|f| f.read}
    end
  
end