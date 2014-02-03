class AddMixpanelIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :mixpanel_id, :string
  end
end
