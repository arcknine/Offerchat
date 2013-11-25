class AddPhoneToVisitors < ActiveRecord::Migration
  def change
    add_column :visitors, :phone, :string
  end
end
