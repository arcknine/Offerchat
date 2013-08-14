@Offerchat.module "SidebarApp.Visitors", (Visitors, App, Backbone, Marionette, $, _) ->

  class Visitors.Controller extends App.Controllers.Base
    # visitorsStorage: new Backbone.LocalStorage "visitors-storage"

    initialize: (options = {}) ->
      @currentUser = App.request "set:current:user", App.request "get:current:user:json"
      @visitors    = App.request "visitors:entities"
      @messages    = App.request "messeges:entities"
      @currentSite = App.request "get:sidebar:selected:site"
      @layout      = @getLayout()

      App.reqres.setHandler "set:no:active:visitor:chat", =>
        @visitors.updateModels('active', null)

      if App.xmpp.status is Strophe.Status.CONNECTED
        @connection = App.xmpp.connection
        @connected()

      @listenTo @layout, "show", =>
        # @visitorsList()
        @agentsList()

      @listenTo @currentSite, "change", =>
        @visitorsList()
        # console.log @currentSite

      App.reqres.setHandler "get:chats:messages", =>
        @messages

      App.reqres.setHandler "get:chats:visitors", =>
        @visitors

      @show @layout

    getLayout: ->
      new Visitors.Layout

    getVisitorsView: (visitors) ->
      new Visitors.List
        collection: visitors

    getAgentsView: ->
      new Visitors.Agents

    visitorsList: ->
      unless  @currentSite.get("all")
        console.log @visitors

        visitors = App.request "visitors:entities"
        visitors.set @visitors.where { api_key: @currentSite.get("api_key") }
      else
        console.log @visitors
        visitors = @visitors

      visitorsView = @getVisitorsView(visitors)

      @listenTo visitorsView, "childview:click:visitor:tab", (visitor) =>

        # remove all active visitors chat
        App.request "set:no:active:visitor:chat"

        visitor.model.set
          unread: null
          active: 'active'

        App.navigate "chats/#{visitor.model.get('token')}", trigger: true

      @layout.visitorsRegion.show visitorsView

    agentsList: ->
      agentsView = @getAgentsView()
      @layout.agentsRegion.show agentsView

    connected: ->
      @connection.vcard.init(@connection)
      @connection.addHandler @onPresence, null, "presence"
      @connection.addHandler @onPrivateMessage, null, "message", "chat"

      @create_vcard()
      @sendPresence()

    create_vcard: ->
      vcard = sessionStorage.getItem("vcard")
      unless vcard
        info  = gon.current_user

        $.each info, (key, value) ->
          if !value
            info[key] = 'null'

        build = $iq({type: 'set'}).c('vCard', {xmlns: 'vcard-temp'})
                .c('NAME').t(info.name).up()
                .c('DN').t(info.display_name).up()
                .c('AVATAR').c('TYPE').t(info.avatar_content_type).up().c('BINVAL').t(info.avatar).up().up()
                .c('JABBERID').t(info.jabber_user)

        @connection.sendIQ build
        sessionStorage.setItem("vcard", true)

    sendPresence: ->
      pres = $pres().c('priority').t('1').up().c('status').t("Online")
      @connection.send(pres)

    onPresence: (presence) =>
      from     = $(presence).attr("from")
      jid      = Strophe.getNodeFromJid from
      resource = Strophe.getResourceFromJid from
      type     = $(presence).attr("type")
      # visitor  = @visitors.findWhere { jid: jid }

      info     = JSON.parse($(presence).find('offerchat').text() || "{}")
      token    = info.token
      visitor  = @visitors.findWhere { token: token }

      @displayCurrentUrl(token, jid, info.url)

      if type is "unavailable"
        @visitors.remove visitor
      else if typeof visitor is "undefined"
        @visitors.add { jid: jid, token: token ,info: info, resource: resource, api_key: info.api_key, email: info.email }
      else
        visitor.set jid: jid
        @visitors.set visitor

      true

    onPrivateMessage: (message) =>

      from    = $(message).attr("from")
      jid     = Strophe.getNodeFromJid from
      body    = $(message).find("body").text()
      if body
        visitor = @visitors.findWhere { jid: jid }
        token = visitor.get("token")

        if @messages.last().get("jid") is jid and @messages.last().get("viewing") is false
          child = true
          childClass = "child"

        @messages.add
          token:      token
          jid:        jid
          sender:     "visitor"
          message:    body
          time:       new Date()
          viewing:    false
          child:      child || false
          childclass: childClass || ""
          timesimple: moment().format('hh:mma')

        # add ticker
        if Backbone.history.fragment.indexOf(token)==-1
          @visitors.findWhere({token: token}).addUnread()
          @visitors.sort()

      true

    displayCurrentUrl:(token, jid, url) ->
      @messages.add
        token:      token
        jid:        jid
        sender:     "visitor"
        message:    url
        time:       new Date()
        timesimple: moment().format('hh:mma')
        viewing:    true


