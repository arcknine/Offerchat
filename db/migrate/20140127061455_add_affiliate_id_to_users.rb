class AddAffiliateIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :affiliate_id, :integer
    add_index :users, :affiliate_id
  end
end
