Fabricator(:user) do
  email                  { sequence(:email) { |i| "user#{i}@offerchat.com" } }
  password               "password"
  password_confirmation  "password"
  name                   { sequence(:name) { |i| "User #{i}" } }
  display_name           { sequence(:display_name) { |i| "Display #{i}" } }
  plan_identifier        "FREE"
end

Fabricator(:starter_user, class_name: "User") do
  email                  { sequence(:email) { |i| "user#{i}@offerchat.com" } }
  password               "password"
  password_confirmation  "password"
  name                   { sequence(:name) { |i| "User #{i}" } }
  display_name           { sequence(:display_name) { |i| "Display #{i}" } }
  plan_identifier        "STARTER"
end

Fabricator(:personal_user, class_name: "User") do
  email                  { sequence(:email) { |i| "user#{i}@offerchat.com" } }
  password               "password"
  password_confirmation  "password"
  name                   { sequence(:name) { |i| "User #{i}" } }
  display_name           { sequence(:display_name) { |i| "Display #{i}" } }
  plan_identifier        "PERSONAL"
end

Fabricator(:business_user, class_name: "User") do
  email                  { sequence(:email) { |i| "user#{i}@offerchat.com" } }
  password               "password"
  password_confirmation  "password"
  name                   { sequence(:name) { |i| "User #{i}" } }
  display_name           { sequence(:display_name) { |i| "Display #{i}" } }
  plan_identifier        "BUSINESS"
end

Fabricator(:enterprise_user, class_name: "User") do
  email                  { sequence(:email) { |i| "user#{i}@offerchat.com" } }
  password               "password"
  password_confirmation  "password"
  name                   { sequence(:name) { |i| "User #{i}" } }
  display_name           { sequence(:display_name) { |i| "Display #{i}" } }
  plan_identifier        "ENTERPRISE"
end

Fabricator(:premium_user, class_name: "User") do
  email                  { sequence(:email) { |i| "user#{i}@offerchat.com" } }
  password               "password"
  password_confirmation  "password"
  name                   { sequence(:name) { |i| "User #{i}" } }
  display_name           { sequence(:display_name) { |i| "Display #{i}" } }
  plan_identifier        "PREMIUM"
end
