Fabricator(:user) do
  email                  { sequence(:email) { |i| "user#{i}@offerchat.com" } }
  password               "password"
  password_confirmation  "password"
  name { sequence(:name) { |i| "User #{i}" } }
  display_name           { sequence(:display_name) { |i| "Display #{i}" } }
end
