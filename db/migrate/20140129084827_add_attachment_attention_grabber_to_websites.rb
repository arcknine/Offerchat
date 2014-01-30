class AddAttachmentAttentionGrabberToWebsites < ActiveRecord::Migration
  def self.up
    add_attachment :websites, :attention_grabber
  end

  def self.down
    remove_attachment :websites, :attention_grabber
  end
end
