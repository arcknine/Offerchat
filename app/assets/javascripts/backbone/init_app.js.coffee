$ ->
  Offerchat.xmpp = {}
  connect()

  window.onbeforeunload = (e) ->
    status = Offerchat.xmpp.status
    "" unless status is Strophe.Status.DISCONNECTED or status is "logout"

closeApp = ->
  Offerchat.xmpp.connection.disconnect()  if Offerchat.xmpp and Offerchat.xmpp.connection

connect = ->
  currentUser = gon.current_user
  bosh_url = gon.chat_info.bosh_url
  username = "#{currentUser.jabber_user}@#{gon.chat_info.server_name}/offerchat"
  password = currentUser.jabber_password

  Offerchat.xmpp.connection = new Strophe.Connection bosh_url
  Offerchat.xmpp.connection.connect username, password, (status) ->
    console.log status
    if status is Strophe.Status.CONNECTED
      $("#connecting-region").fadeOut()

      if Offerchat.xmpp.status isnt Strophe.Status.DISCONNECTED
        Offerchat.xmpp.status = status
        Offerchat.start currentUser: JSON.stringify(currentUser)
      else
        Offerchat.xmpp.status = "reconnect"

    else if status is Strophe.Status.CONNECTING
      setTimeout (=>
        unless Offerchat.xmpp.status is Strophe.Status.CONNECTED
          $("#connecting-region").fadeOut()
          Offerchat.xmpp.status = status
          Offerchat.start currentUser: JSON.stringify(currentUser)
      ), 20000

    else if status is Strophe.Status.DISCONNECTED
      unless Offerchat.xmpp.status is "logout"
        location.reload()
        $("#connecting-region").show()
        Offerchat.xmpp.status = status
