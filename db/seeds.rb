# Pricing Plans
Plan.delete_all
Plan.create(:name => "Free", :description => "Forever Free", :price => 0, :max_agent_seats => 1, :plan_identifier => "FREE")
Plan.create(:name => "Starter", :description => "or you can choose to get the white labeled widget only for", :price => 14, :max_agent_seats => 1, :plan_identifier => "STARTER")
Plan.create(:name => "Personal", :description => "for your small personal business", :price => 37, :max_agent_seats => 4, :features => ['up to 4 agent seats', 'white labeled widget'], :plan_identifier => "PERSONAL")
Plan.create(:name => "Business", :description => "for e-commerce websites", :price => 87, :max_agent_seats => 10, :features => ['up to 10 agent seats', 'white labeled widget'], :plan_identifier => "BUSINESS")
Plan.create(:name => "Enterprise", :description => "for large sales companies", :price => 197, :max_agent_seats => 30, :features => ['up to 30 agent seats', 'white labeled widget'], :plan_identifier => "ENTERPRISE")

# Admin User
Admin.where(:email => "admin@offerchat.com").delete_all
Admin.create(:email => "admin@offerchat.com", :password => "passw0rd", :password_confirmation => "passw0rd")
