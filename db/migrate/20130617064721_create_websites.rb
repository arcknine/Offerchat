class CreateWebsites < ActiveRecord::Migration
  def change
    create_table :websites do |t|
      t.string :url
      t.string :name
      t.string :api_key
      t.text :settings

      t.timestamps
    end
  end
end
