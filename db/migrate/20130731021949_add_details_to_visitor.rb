class AddDetailsToVisitor < ActiveRecord::Migration
  def change
    add_column :visitors, :location, :string
    add_column :visitors, :ipaddress, :string
    add_column :visitors, :browser, :string
  end
end
