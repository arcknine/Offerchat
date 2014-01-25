# Pricing Plans
Plan.delete_all
Plan.create(:name => "Free", :description => "Forever Free", :price => 0, :max_agent_seats => 1, :plan_identifier => "FREE")
Plan.create(:name => "Starter", :description => "or you can choose to get the white labeled widget only for", :price => 14, :max_agent_seats => 1, :plan_identifier => "STARTER")
Plan.create(:name => "Personal", :description => "for your small personal business", :price => 37, :max_agent_seats => 4, :features => ['up to 4 agent seats', 'white labeled widget'], :plan_identifier => "PERSONAL")
Plan.create(:name => "Business", :description => "for e-commerce websites", :price => 87, :max_agent_seats => 10, :features => ['up to 10 agent seats', 'white labeled widget'], :plan_identifier => "BUSINESS")
Plan.create(:name => "Enterprise", :description => "for large sales companies", :price => 197, :max_agent_seats => 30, :features => ['unlimited agent seats', 'white labeled widget'], :plan_identifier => "ENTERPRISE")
# Plan.create(:name => "Premium", :description => "hidden", :price => 197, :max_agent_seats => 30, :features => ['unlimited agent seats'], :plan_identifier => "PREMIUM")
Plan.create(:name => "Basic", :description => "Basic Plan", :price => 9, :max_agent_seats => 50, :plan_identifier => "BASIC")
Plan.create(:name => "Pro", :description => "Pro Plan", :price => 17, :max_agent_seats => 50, :plan_identifier => "PRO")
Plan.create(:name => "Pro(Trial)", :description => "Pro(Trial) Plan", :price => 0, :max_agent_seats => 50, :plan_identifier => "PROTRIAL")

# Admin User
Admin.where(:email => "admin@offerchat.com").delete_all
Admin.create(:email => "admin@offerchat.com", :password => "passw0rd", :password_confirmation => "passw0rd")

AttentionGrabber.delete_all
AttentionGrabber.create(:name => "Grabber 1", :src => "d1cpaygqxflr8n.cloudfront.net/images/attention-grabbers/01.png", :height => 155, :width => 200)
AttentionGrabber.create(:name => "Grabber 2", :src => "d1cpaygqxflr8n.cloudfront.net/images/attention-grabbers/02.png", :height => 155, :width => 200)
AttentionGrabber.create(:name => "Grabber 3", :src => "d1cpaygqxflr8n.cloudfront.net/images/attention-grabbers/03.png", :height => 253, :width => 200)
AttentionGrabber.create(:name => "Grabber 4", :src => "d1cpaygqxflr8n.cloudfront.net/images/attention-grabbers/04.png", :height => 122, :width => 306)
AttentionGrabber.create(:name => "Grabber 5", :src => "d1cpaygqxflr8n.cloudfront.net/images/attention-grabbers/05.png", :height => 230, :width => 230)
AttentionGrabber.create(:name => "Grabber 6", :src => "d1cpaygqxflr8n.cloudfront.net/images/attention-grabbers/06.png", :height => 240, :width => 240)
AttentionGrabber.create(:name => "Grabber 7", :src => "d1cpaygqxflr8n.cloudfront.net/images/attention-grabbers/07.png", :height => 268, :width => 192)
