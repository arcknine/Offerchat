class CreateChatSessions < ActiveRecord::Migration
  def change
    create_table :chat_sessions do |t|
      t.references :visitor
      t.references :roster
      t.timestamps
    end
    add_index :chat_sessions, :visitor_id
    add_index :chat_sessions, :roster_id
  end
end
