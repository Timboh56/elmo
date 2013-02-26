class SmsCodesController < ApplicationController
  # render :text => n, :status => 200
  def show
  	
  	# this may be different that the language setting for the website
  	I18n.locale = configatron.outgoing_sms_language
  	
  	@form_id= params[:form_id]
    get_codes
    
    render :template => 'sms_codes/show.html', :layout => false
  end
 
  def get_codes	
		
		@form = Form.find(@form_id)	
		
		# array to store qings to be printed 
		@sms_qings = {}
		
		#resets last to nil;
		@last_qing_id = nil
		
		unless @form == nil	
			# get all the codes for this form
			sms_codes = SmsCode.where('form_id = ? ', @form_id).order("question_number ASC, code ASC")
			sms_codes.each do |c|
				@qing = c.questioning
Rails.logger.debug('check')				
				
				# is this the next qing?
				# we test using the last_qing_id
				if (@last_qing_id != @qing.id ? true : false)
Rails.logger.debug('first qing')					
					# array to temporarily store code text
					@code_text = []
					@last_qing_id = @qing.id					
				
				end
				
				if c.code != nil
					@code_text << c.code + '. ' + c.option.name
				end
				
				@sms_qings[@qing.id] = {:qing => @qing, :code_text => @code_text}
				
			end
		end
	end

end
