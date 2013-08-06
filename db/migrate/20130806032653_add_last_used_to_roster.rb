class AddLastUsedToRoster < ActiveRecord::Migration
  def change
    add_column :rosters, :last_used, :datetime, :default => Time.now
  end
end
