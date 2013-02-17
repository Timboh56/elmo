class SmsCode < ActiveRecord::Base
  attr_accessible :code, :form_id, :option_id, :question_number, :questioning_id
end
