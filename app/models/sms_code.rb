class SmsCode < ActiveRecord::Base
  attr_accessible :code, :form_id, :option_id, :question_number, :questioning_id

	belongs_to :form
  	belongs_to :questioning
  	belongs_to :option
  
  	validates(:questioning_id, :presence => true)
  	validates(:question_number, :presence => true)
end
