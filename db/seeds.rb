# Pricing Plans
Plan.delete_all
Plan.create(:name => "Free", :description => "Forever Free", :price => 0, :max_agent_seats => 1)
Plan.create(:name => "Starter", :description => "1 agent seat, unbrandable", :price => 14, :max_agent_seats => 1)
Plan.create(:name => "Lite", :description => "2 to 5 agents, unbrandable", :price => 29, :max_agent_seats => 5)
Plan.create(:name => "Business", :description => "6 to 12 agents, unbrandable", :price => 59, :max_agent_seats => 12)
Plan.create(:name => "Pro", :description => "up to 30 agent seats, unbrandable", :price => 129, :max_agent_seats => 30)
