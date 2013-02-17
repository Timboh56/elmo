class CreateSmsCodes < ActiveRecord::Migration
  def change
    create_table :sms_codes do |t|
      t.string :code,               :default => false
      t.integer :questioning_id
      t.integer :option_id,               :default => false
      t.integer :form_id
      t.integer :question_number

      t.timestamps
    end
  end
end
