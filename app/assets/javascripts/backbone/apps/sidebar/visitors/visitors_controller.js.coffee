@Offerchat.module "SidebarApp.Visitors", (Visitors, App, Backbone, Marionette, $, _) ->

  class Visitors.Controller extends App.Controllers.Base
    # visitorsStorage: new Backbone.LocalStorage "visitors-storage"

    initialize: (options = {}) ->
      @currentUser = App.request "set:current:user", App.request "get:current:user:json"
      @visitors    = App.request "visitors:entities"
      @messages    = App.request "messeges:entities"
      @layout      = @getLayout()

      # @visitorsStorage.create @visitors

      if App.xmpp.status is Strophe.Status.CONNECTED
        @connection = App.xmpp.connection
        @connected()

      @listenTo @layout, "show", =>
        @visitorsList()
        @agentsList()

      App.reqres.setHandler "get:chats:messages", =>
        @messages

      App.reqres.setHandler "get:chats:visitors", =>
        @visitors

      @show @layout

    getLayout: ->
      new Visitors.Layout

    getVisitorsView: ->
      new Visitors.List
        collection: @visitors

    getAgentsView: ->
      new Visitors.Agents

    visitorsList: ->
      visitorsView = @getVisitorsView()

      @listenTo visitorsView, "childview:click:visitor:tab", (visitor) =>
        App.navigate "chats/#{visitor.model.get('jid')}", trigger: true

      @layout.visitorsRegion.show visitorsView

    agentsList: ->
      agentsView = @getAgentsView()
      @layout.agentsRegion.show agentsView

    connected: ->
      @connection.vcard.init(@connection)
      @connection.addHandler @on_presence, null, "presence"
      @connection.addHandler @on_private_message, null, "message", "chat"

      @send_presence()

    send_presence: ->
      pres = $pres().c('priority').t('1').up().c('status').t("Online")
      @connection.send(pres)

    on_presence: (presence) =>
      from     = $(presence).attr("from")
      jid      = Strophe.getNodeFromJid from
      resource = Strophe.getResourceFromJid from
      type     = $(presence).attr("type")
      visitor  = @visitors.findWhere { jid: jid }

      if type is "unavailable"
        @visitors.remove visitor
      else if typeof visitor is "undefined"
        visitor = { jid: jid, resource: resource }
        @visitors.add visitor

      true

    on_private_message: (message) =>
      from    = $(message).attr("from")
      jid     = Strophe.getNodeFromJid from
      body    = $(message).find("body").text()

      if body
        @messages.add
          token:      jid
          jid:        jid
          sender:     jid
          message:    body
          time:       new Date()
          timesimple: moment().format('hh:mma')

      true