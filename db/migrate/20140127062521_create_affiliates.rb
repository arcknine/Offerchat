class CreateAffiliates < ActiveRecord::Migration
  def change
    create_table :affiliates do |t|
      t.string :name
      t.boolean :enabled, :default => true

      t.timestamps
    end
  end
end
