class CreateVisitors < ActiveRecord::Migration
  def change
    create_table :visitors do |t|
      t.string :token
      t.references :website
      t.timestamps
    end
    add_index :visitors, :website_id
  end
end
