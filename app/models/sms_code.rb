class SmsCode < ActiveRecord::Base
  attr_accessible :code, :option_id, :form_id, :question_number, :questioning_id

  	belongs_to :questioning
  	belongs_to :option
  
  	validates(:questioning_id, :presence => true)
  	validates(:form_id, :presence => true)
  	validates(:question_number, :presence => true)
  	
  	def self.load_sms_code_and_get_text(qing, nn)
		alpha_index = ('a'..'z').to_a
		options = (qing.question.option_set == nil ? [] : qing.question.option_set.sorted_options)
		code_text = []
		unless options.empty?
			options.each_with_index do |option, n|
				sms_code = new(:form_id=> qing.form_id, :code => alpha_index.fetch(n), :option_id => option.id, :questioning_id => qing.id, :question_number => nn)
				sms_code.save!
				
				code_text << alpha_index.fetch(n)+ '. '+option.name	
			end
		else
			sms_code = new(:form_id=> qing.form_id, :questioning_id => qing.id, :question_number => nn)
			sms_code.save!
		end		
		
		return code_text
	end
end
