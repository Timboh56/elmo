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
class IntelliSmsAdapter
  require 'open-uri'
  require 'uri'
  $username = "#{configatron.intellisms_username}"
  $password = "#{configatron.intellisms_password}" 
   
  
  def self.deliver(numbers, msg)
    raise "No numbers given" if numbers.empty?
    uri = "http://www.intellisoftware.co.uk/smsgateway/sendmsg.aspx?" +
       "username=" + $username +  
      "&password=" + $password +
      "&to=#{numbers.join(',')}&text=#{URI.encode(msg)}"
    result = open(uri){|f| f.read}
    errors = result.split("\n").reject{|l| !l.match(/ERR:/)}.join("\n")
    raise errors unless errors.blank?
  end 
  
  # check_balance returns the balance string
  def self.check_balance()
    uri = "http://www.intellisoftware.co.uk/smsgateway/getbalance.aspx?" +
      "username=" + $username + 
      "&password=" + $password
    result = open(uri){|f| f.read}
    return result
  end

end