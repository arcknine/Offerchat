object @notes
attributes :id, :message, :user_id, :visitor_id, :created_at

node do |note|
  {
    :avatar => note.user.avatar,
    :user_name => note.user.display_name
  }
end