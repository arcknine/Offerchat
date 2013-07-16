Fabricator(:website) do
  url      { sequence(:url) { |i| "https://www.website#{i}.com" } }
  name     { sequence(:url) { |i| "Website Name #{i}" } }
end
