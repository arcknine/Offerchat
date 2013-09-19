attributes :id, :email, :name, :display_name, :jabber_user, :jabber_password, :plan_identifier, :stripe_customer_token, :trial_days_left
node(:avatar) { |user| user.avatar.url(:small) }
