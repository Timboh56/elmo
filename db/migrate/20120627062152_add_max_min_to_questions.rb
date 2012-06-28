class AddMaxMinToQuestions < ActiveRecord::Migration
  def change
	add_column :questions, :minimum, :integer
  end
end
