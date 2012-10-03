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
    if !cookies_enabled?
      flash[:cookies] = "Cookies are disabled by your browser. Please enable them."
    end
      @title = "Login"
      @user_session = UserSession.new
  end
  
  def create
    
    if simple_captcha_valid?
      session[:attempts] = 0
    end
    
    @user_session = UserSession.new(params[:user_session])
    if (session[:attempts] < 3) && @user_session.save
      reset_session
      
      
      # reset the perishable token for security's sake
      @user_session.user.reset_perishable_token!
      flash[:success] = "Login successful"
      redirect_back_or_default(root_path)
    else
      
      # increment login attempts in session
      if !session[:attempts]
        session[:attempts] = 0
      else
        session[:attempts] = session[:attempts] + 1
        session[:attempts] > 3 ? flash[:captcha] = "Please enter all symbols in the captcha to continue." : nil
      end
      flash[:error] = @user_session.errors.full_messages.join(",")
      redirect_to(:action => :new)
    end
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
