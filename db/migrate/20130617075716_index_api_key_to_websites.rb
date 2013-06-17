class IndexApiKeyToWebsites < ActiveRecord::Migration
  def up
    add_index :websites, :api_key
  end

  def down
    remove_index :websites, :api_key
  end
end
