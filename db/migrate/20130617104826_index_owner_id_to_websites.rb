class IndexOwnerIdToWebsites < ActiveRecord::Migration
  def up
    add_index :websites, :owner_id
  end

  def down
    remove_index :websites, :owner_id
  end
end
