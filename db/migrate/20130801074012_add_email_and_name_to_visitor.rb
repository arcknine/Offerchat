class AddEmailAndNameToVisitor < ActiveRecord::Migration
  def change
    add_column :visitors, :email, :string
    add_column :visitors, :name, :string
  end
end
