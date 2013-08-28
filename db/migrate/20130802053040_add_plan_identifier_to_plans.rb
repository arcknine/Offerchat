class AddPlanIdentifierToPlans < ActiveRecord::Migration
  def change
    add_column :plans, :plan_identifier, :string
    add_index :plans, :plan_identifier
  end
end
