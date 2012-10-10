class AddTimeLockedToIpLogins < ActiveRecord::Migration
  def change
    add_column :ip_logins, :time_locked, :datetime
  end
end
