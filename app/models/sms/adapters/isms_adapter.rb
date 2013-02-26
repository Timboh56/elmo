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
  
  # receives data in XML from ISMS server when a message is received  
  def receive (params)		
		hash = Hash.from_xml( params[:XMLDATA] )				
		base = hash['Response']['MessageNotification']
		
		# SMS sometimes sends incoming messages in a batch 
		if base.is_a? Array
			base.each{ |message|
				m = {
					:phone => message['SenderNumber'],
					:message => message['Message']
					}
				@incoming_messages << m
			}
		#sometimes as a single message
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
		text = URI.encode(message.body)
		message.to.each{ |n|
			# build the URI the request
			uri = build_uri("sendmsg", "to=#{n}&text=#{text}")			
			# honor the dont_send option
			unless options[:dont_send]
			  response = send_request(uri)
			  # no error reporting from isms  
			end
		}
		# if we get to this point, it worked
		return true
	end
	
	# deliver each outgoing message
	def get_reply
		unless @outgoing_messages.empty?
			@outgoing_messages.each{ |m|				
				deliver(m)
			}
		end
		{:output => '', :format=>'txt'}	
	end
	
	# since the system may receive a batch, 
	# with each pass through the sms_response_controller
	# we add an outgoing message and corresponding phone #
	# to the outgoing_messages array
	def add_outgoing_message (message, phone)
		m = Sms::Message.new(:direction => :outgoing, :to => [phone], :body => message)
		@outgoing_messages << m
	end
	
	private
    # builds uri based on given action and query string params
    def build_uri(action, params = "")
    	"http://#{configatron.outgoing_sms_extra}/#{action}?" + 
    	"user=#{configatron.outgoing_sms_username}&enc=1&passwd=#{configatron.outgoing_sms_password}&cat=1&#{params}"
      
    end
    
    # sends request to given uri and returns response
    def send_request(uri)
       open(uri){|f| f.read}
    end
  
end