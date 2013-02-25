class SmsCodesController < ApplicationController
  # render :text => n, :status => 200
  def show
  	@form_id= params[:form_id]
    make_code
    render :template => 'sms_codes/show.txt.erb'
  end
 
 
  def make_code()	
		@codeText = []	
		begin	
			@form = Form.find(@form_id)			
		rescue ActiveRecord::RecordNotFound
			@codeText << 'Form Not Found!'
		else			
			SmsCode.delete_all(:form_id => @form_id)				
			qing = @form.questionings.select { |q| q.question.type.name == 'select_one' || q.question.type.name == 'select_multiple' || q.question.type.name == 'integer'}	
			qing.each_with_index do |q, n|
				nn = n + 1
				code_text = q.add_sms_code(nn)
				@codeText << nn.to_s + '. ' + q.question.name + "\n" + code_text			
			end
		end
	end

end
