class CreateAttentionGrabbers < ActiveRecord::Migration
  def change
    create_table :attention_grabbers do |t|
      t.string :name
      t.text :src
      t.integer :height
      t.integer :width

      t.timestamps
    end
  end
end
