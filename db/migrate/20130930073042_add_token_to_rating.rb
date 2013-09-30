class AddTokenToRating < ActiveRecord::Migration
  def change
    add_column :ratings, :token, :string
    add_index :ratings, :token
  end
end
