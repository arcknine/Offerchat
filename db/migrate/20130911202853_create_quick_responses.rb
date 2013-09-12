class CreateQuickResponses < ActiveRecord::Migration
  def change
    create_table :quick_responses do |t|
      t.integer :website_id
      t.string :shortcut
      t.string :message

      t.timestamps
    end
    add_index :quick_responses, :website_id
  end
end
