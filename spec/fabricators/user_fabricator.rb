Fabricator(:user) do
  email         {sequence(:email) { |u| "email#{u}@offerchat.com" } }
  password      "password"
end
