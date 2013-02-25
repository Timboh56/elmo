class SmsCodesController < ApplicationController
  # render :text => n, :status => 200
  def show
  	I18n.locale = configatron.outgoing_sms_language
  	
  	@form_id= params[:form_id]
    make_code
    render :template => 'sms_codes/show.html.erb', :layout => false
  end
 
 
  def make_code()	
		@codeText = []
		
		@form = Form.find(@form_id)
		
		unless @form == nil
			SmsCode.delete_all(:form_id => @form_id)				
			qing = @form.questionings.select { |q| q.question.type.name == 'select_one' || q.question.type.name == 'select_multiple' || q.question.type.name == 'integer'}	
			qing.each_with_index do |q, n|
				nn = n + 1
				code_text = q.add_sms_code(nn)
				@codeText << nn.to_s + '. ' + q.question.name + "\n" + code_text			
			end
		else
			@codeText << 'Form Not Found!'
		end
	end

end
