class CreateTriggers < ActiveRecord::Migration
  def change
    create_table :triggers do |t|
      t.references :website
      t.string :message
      t.integer :rule_type
      t.integer :status

      t.timestamps
    end
    add_index :triggers, :website_id
  end
end
