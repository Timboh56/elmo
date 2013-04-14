class Smser
  
<<<<<<< HEAD
  # get adapter from settings
  $adapter = configatron.outgoing_sms_adapter
  
=======
>>>>>>> 91db4a5e0e6c76c8de6e056acea8623922590e05
  def self.deliver(recips, which_phone, msg)
    
    # get numbers
    numbers = []
    numbers += recips.collect{|u| u.phone} if %w(main_only both).include?(which_phone)
    numbers += recips.collect{|u| u.phone2} if %w(alternate_only both).include?(which_phone)
    numbers.compact!
    
    # build the sms
    message = Sms::Message.new(:direction => :outgoing, :to => numbers, :body => msg)
    
    # deliver
<<<<<<< HEAD
    $adapter.deliver(numbers, msg)
  end
  
  # check_balance uses the Intellisms adapter to retrieve the SMS balance
  def self.check_balance()
    return $adapter.check_balance()
=======
    configatron.outgoing_sms_adapter.deliver(message)
  end
  
  # check_balance uses the outgoing adapter to retrieve the SMS balance
  def self.check_balance
    configatron.outgoing_sms_adapter.check_balance
  end
  
  def self.outgoing_service_name
    configatron.outgoing_sms_adapter.service_name
>>>>>>> 91db4a5e0e6c76c8de6e056acea8623922590e05
  end
end