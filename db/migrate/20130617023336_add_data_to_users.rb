class AddDataToUsers < ActiveRecord::Migration
  def change
    add_column :users, :name, :string
    add_column :users, :display_name, :string
    add_column :users, :avatar, :string
    add_column :users, :jabber_user, :string
    add_column :users, :jabber_password, :string
    add_column :users, :plan_id, :integer
  end
end
