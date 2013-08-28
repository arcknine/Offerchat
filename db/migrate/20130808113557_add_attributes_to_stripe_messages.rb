class AddAttributesToStripeMessages < ActiveRecord::Migration
  def change
    add_column :stripe_messages, :event_id, :string
    add_column :stripe_messages, :created, :string
    add_column :stripe_messages, :livemode, :boolean
    add_column :stripe_messages, :data, :text
    add_column :stripe_messages, :previous_attributes, :text
  end
end
