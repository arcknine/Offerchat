class ChangeDefaultValueOfPlan < ActiveRecord::Migration
  def change
    change_column_default :users, :plan_identifier, "PREMIUM"
  end
end
