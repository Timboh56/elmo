class CreateIpLogins < ActiveRecord::Migration
  def change
    create_table :ip_logins do |t|
      t.string :ip_address
      t.integer :login_attempts

      t.timestamps
    end
  end
end
