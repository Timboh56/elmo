class SmsResponse < ActiveRecord::Base
  attr_accessible :message, :response_id
  
  belongs_to :response
  
  validates(:message, :presence => true)
  validates(:response_id, :presence => true)
end
