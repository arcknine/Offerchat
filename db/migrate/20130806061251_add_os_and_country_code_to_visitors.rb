class AddOsAndCountryCodeToVisitors < ActiveRecord::Migration
  def change
    add_column :visitors, :country_code, :string
    add_column :visitors, :operating_system, :string
  end
end
