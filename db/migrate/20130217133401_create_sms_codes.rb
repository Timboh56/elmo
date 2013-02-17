class CreateSmsCodes < ActiveRecord::Migration
  def change
    create_table :sms_codes do |t|
      t.string :code
      t.integer :questioning_id
      t.integer :option_id
      t.integer :form_id
      t.integer :question_number

      t.timestamps
    end
  end
end
