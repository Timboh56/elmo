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
class Smser
  
  def self.deliver(recips, which_phone, msg)
    
    # get numbers
    numbers = []
    numbers += recips.collect{|u| u.phone} if %w(main_only both).include?(which_phone)
    numbers += recips.collect{|u| u.phone2} if %w(alternate_only both).include?(which_phone)
    numbers.compact!
    
    # deliver
    configatron.outgoing_sms_adapter.deliver(numbers, msg)
  end
  
  # check_balance uses the Intellisms adapter to retrieve the SMS balance
  def self.check_balance
    configatron.outgoing_sms_adapter.check_balance
  end
end