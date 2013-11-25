class CreateNotes < ActiveRecord::Migration
  def change
    create_table :notes do |t|
      t.string :agent
      t.text :message
      t.references :visitor

      t.timestamps
    end
    add_index :notes, :visitor_id
  end
end
