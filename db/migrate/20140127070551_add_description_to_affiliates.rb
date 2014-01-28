class AddDescriptionToAffiliates < ActiveRecord::Migration
  def change
    add_column :affiliates, :description, :string
  end
end
