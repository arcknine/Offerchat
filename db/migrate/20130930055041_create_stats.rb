class CreateStats < ActiveRecord::Migration
  def change
    create_table :stats do |t|
      t.integer :user_id
      t.integer :website_id
      t.integer :active
      t.integer :proactive
      t.integer :missed

      t.timestamps
    end
    add_index :stats, :user_id
    add_index :stats, :website_id
  end
end
