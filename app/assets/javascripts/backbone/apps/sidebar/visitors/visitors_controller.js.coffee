@Offerchat.module "SidebarApp.Visitors", (Visitors, App, Backbone, Marionette, $, _) ->

  class Visitors.Controller extends App.Controllers.Base
    connection: null

    initialize: (options = {}) ->
      @currentUser = App.request "set:current:user", App.request "get:current:user:json"
      @connect()

    connect: ->
      bosh_url = "http://local.offerchat.com:7070/http-bind/"
      _this    = @
      _this.connection = new Strophe.Connection bosh_url
      _this.connection.connect  "#{_this.currentUser.get('jabber_user')}/offerchat", _this.currentUser.get('jabber_password'), (status) ->
        if status is Strophe.Status.CONNECTING
          console.log "Connecting to offerchat"
        else if status is Strophe.Status.AUTHENTICATING
          console.log "Authenticating"
        else if status is Strophe.Status.CONNECTED
          _this.connected()
        # else if status is Strophe.Status.DISCONNECTED
        #   _this.xmpp_status "disconnected"
        #   _this.disconnect()

    connected: ->
      conn = @connection

      # connection can be passed all through out the app
      App.reqres.setHandler "set:strophe:connection", ->
        conn

      console.log App.request "set:strophe:connection"
