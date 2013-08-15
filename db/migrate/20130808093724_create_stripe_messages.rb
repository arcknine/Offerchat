class CreateStripeMessages < ActiveRecord::Migration
  def change
    create_table :stripe_messages do |t|
      t.text :response

      t.timestamps
    end
  end
end
