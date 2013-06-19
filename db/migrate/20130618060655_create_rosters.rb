class CreateRosters < ActiveRecord::Migration
  def change
    create_table :rosters do |t|
      t.references :website
      t.string :jabber_user
      t.string :jabber_password

      t.timestamps
    end
    add_index :rosters, :website_id
  end
end
