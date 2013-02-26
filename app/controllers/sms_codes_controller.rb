class SmsCodesController < ApplicationController
  # render :text => n, :status => 200
  def show
  	
  	# this may be different that the language setting for the website
  	I18n.locale = configatron.outgoing_sms_language
  	
  	@form_id= params[:form_id]
    make_code
    
    render :template => 'sms_codes/show.html', :layout => false
  end
 
  def make_code()	
		@codeText = []
		
		@form = Form.find(@form_id)
		
		# array to store qings to be printed 
		@sms_qings = []
		unless @form == nil
			# clears sms_codes of old data for form_id
			SmsCode.delete_all(:form_id => @form_id)				
			
			# only prints qings that are not hidden, not conditional, and are of the type (select_one, select_multiple or integer)
			qings = @form.questionings.select { |q| q.hidden == false && q.condition == nil && (q.question.type.name == 'select_one' || q.question.type.name == 'select_multiple' || q.question.type.name == 'integer')}	   
			
			qings.each_with_index do |qing, n|
				nn = n + 1
				
				# gets code text for qings that have options - 'select_one', 'select_multiple'
				code_text = SmsCode.load_sms_code_and_get_text(qing, nn)	
				sms_qing = {:qing => qing, :code_text => code_text}				
				@sms_qings << sms_qing
			end
		end
	end

end
