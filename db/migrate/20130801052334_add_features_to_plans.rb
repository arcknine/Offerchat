class AddFeaturesToPlans < ActiveRecord::Migration
  def change
    add_column :plans, :features, :text
  end
end
