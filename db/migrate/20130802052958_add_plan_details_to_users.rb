class AddPlanDetailsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :plan_identifier, :string
    add_index :users, :plan_identifier
    add_column :users, :billing_start_date, :date
  end
end
