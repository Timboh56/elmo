class SmsCodesController < ApplicationController
  # render :text => n, :status => 200
  def show
  	I18n.locale = configatron.outgoing_sms_language
  	
  	@form_id= params[:form_id]
    make_code
    
    render :template => 'sms_codes/show.html', :layout => false
  end
 
  def make_code()	
		alpha_index = ('a'..'z').to_a	
		@sms_qings = []
		
		@form = Form.find(@form_id)
		unless @form == nil			
			# only prints qings that are not hidden, not conditional, and are of the type (select_one, select_multiple or integer)
			qings = @form.questionings.select { |q| q.hidden == false && q.condition == nil && (q.question.type.name == 'select_one' || q.question.type.name == 'select_multiple' || q.question.type.name == 'integer')}	   
			
			qings.each_with_index do |qing, n|
				@code_text = []
				qn = n + 1
				
				# save sms_question_number
				qing.question.update_attributes(:sms_question_no => qn )
				qing.question.save
				
				# save sms_code to options
				type = qing.question.type.name
				if type == 'select_one' || type == 'select_multiple'
					qing.question.option_set.sorted_options.each_with_index do |option, nn|
						option.update_attributes(:sms_code => alpha_index.fetch(n))
						option.save	
						@code_text << alpha_index.fetch(nn)+ '. '+option.name	
					end
				end
				
				sms_qing = {:qing => qing, :code_text => @code_text}				
				@sms_qings << sms_qing
			end
		end
	end

end
