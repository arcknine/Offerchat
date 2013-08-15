attributes :id, :email, :name, :display_name, :jabber_user, :jabber_password, :plan_identifier, :stripe_customer_token
node(:avatar) { |user| user.avatar.url(:small) }
