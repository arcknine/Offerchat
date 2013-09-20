every 4.hours do
  runner "User.freeify"
  runner "User.notify_expiring(5)"
  runner "User.notify_expiring(3)"
  runner "User.notify_expiring(1)"
end
