closeApp = ->
  Offerchat.xmpp.connection.disconnect()  if Offerchat.xmpp and Offerchat.xmpp.connection

$ ->
  currentUser = gon.current_user
  bosh_url = gon.chat_info.bosh_url
  username = "#{currentUser.jabber_user}@#{gon.chat_info.server_name}/offerchat"
  password = currentUser.jabber_password
  Offerchat.xmpp = {}

  Offerchat.xmpp.connection = new Strophe.Connection bosh_url
  Offerchat.xmpp.connection.connect username, password, (status) ->

    if status is Strophe.Status.CONNECTED
      $("#connecting-region").removeClass("modal-backdrop")
      Offerchat.xmpp.status = status
      Offerchat.start currentUser: JSON.stringify(currentUser)

    else if status is Strophe.Status.CONNECTING
      $("#connecting-region").addClass("modal-backdrop")

      # if app cannot connect to chat server it will wait for 20s before loading the app
      setTimeout (=>
        unless Offerchat.xmpp.status is Strophe.Status.CONNECTED
          $("#connecting-region").removeClass("modal-backdrop")
          Offerchat.xmpp.status = status
          Offerchat.start currentUser: JSON.stringify(currentUser)
      ), 20000

    else if status is Strophe.Status.DISCONNECTED
      Offerchat.xmpp.status = status

# window.onbeforeunload = (e) ->
#   "Are your sure you want to reload this page?"