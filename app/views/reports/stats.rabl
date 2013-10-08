object @stats
attributes :active, :proactive, :missed, :created_at

node do |website|
  {
    :period => website.created_at.nil? ? DateTime.now.strftime("%Y-%m-%d") : website.created_at.strftime("%Y-%m-%d")
  }
end