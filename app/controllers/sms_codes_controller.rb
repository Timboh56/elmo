class SmsCodesController < ApplicationController
  # render :text => n, :status => 200
  def show
  	I18n.locale = configatron.outgoing_sms_language
  	
  	@form_id= params[:form_id]
    make_code
    
    render :template => 'sms_codes/show.html', :layout => false
  end
 
 
  def make_code()	
		@codeText = []
		
		@form = Form.find(@form_id)
		@sms_qings = []
		unless @form == nil
			SmsCode.delete_all(:form_id => @form_id)				
			
			# only prints qings that are not hidden, not conditional, and are of the type (select_one, select_multiple or integer)
			qings = @form.questionings.select { |q| q.hidden == false && q.condition == nil && (q.question.type.name == 'select_one' || q.question.type.name == 'select_multiple' || q.question.type.name == 'integer')}	   
			
			qings.each_with_index do |qing, n|
				nn = n + 1
				options_arr = SmsCode.add_sms_code(qing, nn)	
				sms_qings = {:qing => qing, :options_arr => options_arr}				
				@sms_qings << sms_qings
			end
		end
	end

end
