@Offerchat.module "SidebarApp.Visitors", (Visitors, App, Backbone, Marionette, $, _) ->

  class Visitors.Controller extends App.Controllers.Base

    initialize: (options = {}) ->
      @currentUser = App.request "set:current:user", App.request "get:current:user:json"
      @visitors    = App.request "visitors:entities"
      @messages    = App.request "messeges:entities"

      if App.xmpp.status is Strophe.Status.CONNECTED
        @connection = App.xmpp.connection
        @connected()

      visitorsView = @getVisitorsView()
      App.chatSidebarRegion.show visitorsView

     getVisitorsView: ->
      new Visitors.List
        collection: @visitors

    connected: ->
      @connection.vcard.init(@connection)
      @connection.addHandler @on_presence, null, "presence"
      @connection.addHandler @on_private_message, null, "message", "chat"

      @send_presence()

    send_presence: ->
      pres = $pres().c('priority').t('1').up().c('status').t("Online")
      @connection.send(pres)

    on_presence: (presence) =>
      from    = $(presence).attr("from")
      jid     = Strophe.getNodeFromJid from
      type    = $(presence).attr("type")
      visitor = @visitors.findWhere { jid: jid }

      if type is "unavailable"
        @visitors.remove visitor
      else if typeof visitor is "undefined"
        visitor = { jid: jid }
        @visitors.add visitor

      true

    on_private_message: (message) =>
      from    = $(message).attr("from")
      jid     = Strophe.getNodeFromJid from
      body    = $(message).find("body").text()

      # console.log body

      true