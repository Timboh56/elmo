# ELMO - Secure, robust, and versatile data collection.
# Copyright 2011 The Carter Center
#
# ELMO is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# ELMO is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with ELMO.  If not, see <http://www.gnu.org/licenses/>.
# 
class UserSessionsController < ApplicationController
  
  def new
      @title = "Login"
      @user_session = UserSession.new
  end
  
  def create
    @captcha = false
    # if IP has not been logged yet, or this is the first attempt to login from the user..
    if (@user_ip =  IpLogin.find_by_ip_address(request.env['REMOTE_ADDR'].to_s)).nil?
      @user_ip = IpLogin.create(:ip_address =>  request.env['REMOTE_ADDR'].to_s, :login_attempts => 0 )
    end
    
    @user_session = UserSession.new(params[:user_session])
    
    
    # if session attempts is nil (which means it hasn't been set) or is less than three..  
    if  @user_ip.login_attempts < 3
      if @user_session.save
        reset_session

        # reset the perishable token for security's sake
        @user_session.user.reset_perishable_token!
        flash[:success] = "Login successful"
      else
        flash[:error] = @user_session.errors.full_messages.join(",")
      end
    else
      
      # if current time is more than 30 minutes since the IP was locked for the captcha, reset number of login attempts
      # this prevents entire pool of IP's from being "locked" out
      Time.now > @user_ip.time_locked + 30.minutes ? @user_ip.login_attempts = 0 : nil

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
        # else show the captcha
        @captcha = true
        
        # only show the wrong captcha error if the user just entered the wrong captcha
        # this only occurs when the user has more than 3 attempts
        @user_ip.login_attempts > 3 ? flash[:error] = "You entered the wrong captcha" : nil
      end
    end
    
    @user_ip.increment(:login_attempts)
    @user_ip.save    
    redirect_to(:action => :new, :captcha => @captcha)
  end
  
  def destroy
    @user_session = UserSession.find  
    @user_session.destroy
    forget_location
    Subindex.clear_all(session)
    redirect_to(:action => :logged_out)
  end
  
  def logged_out
    @title = "Logged Out"
  end
end
