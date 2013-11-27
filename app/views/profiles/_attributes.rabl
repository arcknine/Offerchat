attributes :id, :email, :name, :display_name, :jabber_user, :jabber_password, :plan_identifier, :stripe_customer_token, :trial_days_left
node(:avatar) { |user| user.avatar.url(:small) }

node do |user|
  {
    :notifications => {
      :new_message => user.settings(:notifications).new_message,
      :new_visitor => user.settings(:notifications).new_visitor
    }
  }
end