class AddWidgetInstalledToUsers < ActiveRecord::Migration
  def change
    add_column :users, :widget_installed, :boolean, :default => false
  end
end
