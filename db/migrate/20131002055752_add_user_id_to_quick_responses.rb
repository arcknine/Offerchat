class AddUserIdToQuickResponses < ActiveRecord::Migration
  def change
    add_column :quick_responses, :user_id, :integer
    add_index :quick_responses, :user_id
  end
end
