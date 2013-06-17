class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.references :user
      t.integer :website_id
      t.integer :owner_id
      t.integer :role

      t.timestamps
    end
    add_index :accounts, :user_id
  end
end
