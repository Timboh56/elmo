class UserSessionsController < ApplicationController
  
  def new
    @title = "Login"
    @user_session = UserSession.new
  end
  
  def create
<<<<<<< HEAD
    @captcha = false
    # if IP has not been logged yet, or this is the first attempt to login from the user..
    ip = request.env['REMOTE_ADDR'].to_s
    if (@user_ip = IpLogin.find_by_ip_address(ip)).nil?
      @user_ip = IpLogin.create(:ip_address => ip, :login_attempts => 0 )
    end
    
    @user_session = UserSession.new(params[:user_session])
    
    
    # if session attempts is nil (which means it hasn't been set) or is less than three..  
    if  @user_ip.login_attempts < 3
      if @user_session.save
        reset_session

        # reset the perishable token for security's sake
        @user_session.user.reset_perishable_token!
        
        # destroy the row in user ip table once user logs in successfully
        @user_ip.destroy
        
        flash[:success] = "Login successful"
        redirect_back_or_default(root_path)
        return
      else
        flash[:error] = @user_session.errors.full_messages.join(",")
      end
=======
    # reset the session for security purposes
    reset_session_preserving_return_to
    
    @user_session = UserSession.new(params[:user_session])
    
    # if the save is successful, the user is logged in automatically
    if @user_session.save
      
      # do post login housekeeping
      return unless post_login_housekeeping
      
      flash[:success] = "Login successful"
      redirect_back_or_default(root_path)
>>>>>>> 91db4a5e0e6c76c8de6e056acea8623922590e05
    else
      
      # if current time is more than 30 minutes since the IP was locked for the captcha, reset number of login attempts
      # this prevents entire pool of IP's from being "locked" out
      if !@user_ip.time_locked.nil? && Time.now > @user_ip.time_locked + 30.minutes
        @user_ip.login_attempts = 0
      end
      
      # update the lock time since user failed to login
      @user_ip.time_locked = Time.now
      
      # if simple captcha is valid, then check to see if credentials are also valid
      if simple_captcha_valid?
        
        # reset login attempts 
        @user_ip.login_attempts = 0
        
        # if credentials are incorrect and captcha is valid          
        if !@user_session.save
          flash[:error] = @user_session.errors.full_messages.join(",")
        end
          
      else
        
        Rails.logger.debug("in here")       
        # else show the captcha
        flash[:captcha] = true
        
        # only show the wrong captcha error if the user just entered the wrong captcha
        # this only occurs when the user has more than 3 attempts
        if @user_ip.login_attempts > 3
          flash[:error] = "You entered the wrong captcha"
        end
      end
    end
    
    @user_ip.increment(:login_attempts)
    @user_ip.save
    redirect_to(:action => :new)    
  end
  
  def destroy
    @user_session = UserSession.find  
    @user_session.destroy
    forget_location
    redirect_to(logged_out_path)
  end
  
  def logged_out
    @title = "Logged Out"
  end
end
