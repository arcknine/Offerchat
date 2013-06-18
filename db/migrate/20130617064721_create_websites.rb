class CreateWebsites < ActiveRecord::Migration
  def change
    create_table :websites do |t|
      t.string :url
      t.string :name
      t.string :api_key
      t.integer :owner_id

      t.timestamps
    end

    add_index :websites, :api_key
  end
end
