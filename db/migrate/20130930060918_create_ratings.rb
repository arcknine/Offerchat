class CreateRatings < ActiveRecord::Migration
  def change
    create_table :ratings do |t|
      t.references :user
      t.references :website
      t.integer :up
      t.integer :down

      t.timestamps
    end
    add_index :ratings, :user_id
    add_index :ratings, :website_id
  end
end
