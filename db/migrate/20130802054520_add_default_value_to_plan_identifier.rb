class AddDefaultValueToPlanIdentifier < ActiveRecord::Migration
  def up
    change_column :users, :plan_identifier, :string, :default => "FREE"
  end

  def down
    change_column :users, :plan_identifier, :string, :default => nil
  end
end
