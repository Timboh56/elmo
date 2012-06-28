class AddMinToQuestions < ActiveRecord::Migration
  def change
	add_column :questions,:maximum,:integer
  end
end
