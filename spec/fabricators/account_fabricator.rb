Fabricator(:account) do
  role 1
end

Fabricator(:owner, :class_name => :account) do
  role 1
end

Fabricator(:admin, :class_name => :account) do
  role 2
end

Fabricator(:agent, :class_name => :account) do
  role 3
end