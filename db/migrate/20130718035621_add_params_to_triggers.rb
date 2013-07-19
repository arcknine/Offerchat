class AddParamsToTriggers < ActiveRecord::Migration
  def change
    add_column :triggers, :params, :string
  end
end
