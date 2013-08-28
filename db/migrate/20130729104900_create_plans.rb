class CreatePlans < ActiveRecord::Migration
  def change
    create_table :plans do |t|
      t.string :name
      t.string :description
      t.float :price
      t.integer :max_agent_seats

      t.timestamps
    end
  end
end
