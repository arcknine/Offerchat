@Offerchat.module "SidebarApp.Visitors", (Visitors, App, Backbone, Marionette, $, _) ->

  class Visitors.Controller extends App.Controllers.Base
    # visitorsStorage: new Backbone.LocalStorage "visitors-storage"

    initialize: (options = {}) ->
      @currentUser = App.request "set:current:user", App.request "get:current:user:json"
      @visitors    = App.request "visitors:entities"
      @agents      = App.request "online:agents:entities"
      @messages    = App.request "messeges:entities"
      @agentMsgs   = App.request "messeges:entities"
      @currentSite = App.request "get:sidebar:selected:site"
      @sites       = App.request "get:all:sites"
      @layout      = @getLayout()

      sidebar = ($(window).height() - 93) + "px"
      $("#chat-sidebar-region").css("height", sidebar)

      $(window).resize ->
        $("#chat-sidebar-region").css("height", ($(window).height() - 93) + "px")

      App.commands.setHandler "set:no:active:chat", =>
        @visitors.updateModels('active', null)
        @agents.updateModels('active', null)

      if App.xmpp.status is Strophe.Status.CONNECTED
        @connection = App.xmpp.connection
        @connected()

      @listenTo @currentSite, "change", =>
        @visitorsList()
        @agentsList()

      @listenTo @currentSite, "show", =>
        @visitorsList()
        @agentsList()

      @listenTo @visitors, "all", =>
        @visitorsList()

      @listenTo @agents, "all", =>
        @agentsList()

      App.reqres.setHandler "get:chats:messages", =>
        @messages

      App.reqres.setHandler "get:agent:chats:messages", =>
        @agentMsgs

      App.reqres.setHandler "get:chats:visitors", =>
        @visitors

      App.reqres.setHandler "get:online:agents", =>
        @agents

      @show @layout

    getLayout: ->
      new Visitors.Layout

    getVisitorsView: (visitors) ->
      new Visitors.List
        collection: visitors

    getAgentsView: (agents) ->
      new Visitors.Agents
        collection: agents

    visitorsList: ->
      unless @currentSite.get("all")
        visitors = App.request "visitors:entities"
        visitors.set @visitors.where { api_key: @currentSite.get("api_key") }
      else
        visitors = @visitors

      visitorsView = @getVisitorsView(visitors)

      @listenTo visitorsView, "childview:click:visitor:tab", (visitor) =>

        App.navigate "chats/visitor/#{visitor.model.get('token')}", trigger: true

        visitor.model.set
          unread: null
          newClass: null
          active: 'active'

      @layout.visitorsRegion.show visitorsView

    agentsList: ->
      agents  = App.request "online:agents:entities"
      unless @currentSite.get("all")
        api_keys = [@currentSite.get("api_key")]
      else
        api_keys = @sites.pluck("api_key")

      $.each @agents.models, (key, value) ->
        agents.set value if _.intersection(api_keys, value.get("api_keys")).length > 0

      agentsView = @getAgentsView(agents)

      @listenTo agentsView, "childview:click:agent:tab", (agent) =>

        App.navigate "chats/agent/#{agent.model.get('token')}", trigger: true

        agent.model.set
          unread: null
          newClass: null
          active: 'active'

      @layout.agentsRegion.show agentsView

    connected: ->
      @connection.vcard.init(@connection)
      @connection.addHandler @onPresence, null, "presence"
      @connection.addHandler @onPrivateMessage, null, "message", "chat"

      App.execute "when:fetched", @sites, =>
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
                .c('DISPLAY_NAME').t(info.display_name).up()
                .c('AVATAR').c('TYPE').t(info.avatar_content_type).up().c('URL').t(info.avatar).up().up()
                .c('JABBERID').t(info.jabber_user).up()
                .c('API_KEYS').t(JSON.stringify(@sites.pluck("api_key")))

        @connection.sendIQ build
        sessionStorage.setItem("vcard", true)

    sendPresence: ->
      pres = $pres().c('priority').t('1').up().c('status').t("Online")
      @connection.send(pres)

    onPresence: (presence) =>
      from     = $(presence).attr("from")
      jid      = Strophe.getBareJidFromJid from
      node     = Strophe.getNodeFromJid from
      resource = Strophe.getResourceFromJid from
      type     = $(presence).attr("type")
      info     = JSON.parse($(presence).find('offerchat').text() || "{}")
      token    = info.token
      visitor  = @visitors.findWhere { token: token }
      agent    = @agents.findWhere { token: node }

      if info.chatting
        chatting  = (if info.chatting.status then "busy" else null)
        chatting  = (if gon.current_user.jabber_user is info.chatting.agent then "online" else chatting)
        available = (if chatting isnt null then true else false)
        title     = (if chatting isnt null then "Chatting with #{info.chatting.name}" else "")
        title     = (if chatting is "online" then "Chatting with You" else title)

      if type is "unavailable"
        visitor = @visitors.findWhere {  jid: node }

        if visitor
          # remove visitor from list
          resources = visitor.get "resources"
          index     = $.inArray(resource, resources)

          resources.splice(index, 1) if index > -1

          if resources.length is 0
            App.navigate Routes.root_path(), trigger: true if Backbone.history.fragment.indexOf(visitor.get("token")) != -1

            @visitors.remove visitor
          else
            visitor.set { jid: node, resources: resources }
            @visitors.set visitor

        else if typeof agent isnt "undefined"
          # remove agent from list
          App.navigate Routes.root_path(), trigger: true if Backbone.history.fragment.indexOf(agent.get("token")) != -1
          @agents.remove agent

      else if !$(presence).find('offerchat').text() and typeof agent is "undefined"
        @connection.vcard.get ((stanza) =>
          info =
            name:         $(stanza).find("NAME").text()
            display_name: $(stanza).find("DISPLAY_NAME").text()
            avatar:       $(stanza).find("URL").text()

          api_keys = JSON.parse $(stanza).find("API_KEYS").text()

          @agents.add { jid: node, token: node, info: info, agent: true, api_keys: api_keys }
        ), jid

      else if typeof visitor is "undefined"

        @displayCurrentUrl(token, node, info.url)
        @visitors.add
          jid:       node
          token:     token
          info:      info
          resources: [resource]
          api_key:   info.api_key
          email:     info.email
          status:    chatting
          available: available
          title:     title
      else
        @displayCurrentUrl(token, node, info.url)
        resources = visitor.get "resources"
        resources.push(resource) if $.inArray(resource, resources) is -1
        visitor.set { jid: node, resources: resources, info: info, status: chatting, available: available, title: title }
        @visitors.set visitor

      true

    onPrivateMessage: (message) =>
      from    = $(message).attr("from")
      jid     = Strophe.getBareJidFromJid from
      node    = Strophe.getNodeFromJid from
      body    = $(message).find("body").text()
      agent   = @agents.findWhere jid: node
      transfer  = $(message).find("transfer")

      if body and typeof agent is "undefined"
        messages = App.request "messeges:entities"
        visitor  = @visitors.findWhere { jid: node }
        token    = visitor.get("token")
        info     = visitor.get "info"
        new_message = @messages.where token: token
        messages.add(new_message)
        localStorage.setItem("ofc-chatlog-"+token, JSON.stringify(new_message))
        visitor_msg =
          token:      token
          jid:        info.name
          sender:     (if jid is token then agent_info.name else "visitor")
          message:    body
          time:       new Date()
          viewing:    false
          timesimple: moment().format('hh:mma')

        if messages.last().get("jid") is info.name and messages.last().get("viewing") is false
          visitor_msg.child      = true
          visitor_msg.childClass = "child"

        @messages.add visitor_msg

        # add ticker
        if Backbone.history.fragment.indexOf(token)==-1
          @visitors.findWhere({token: token}).addUnread()
          @visitors.sort()

      else if agent# and body

        if body or transfer.length

          token    = agent.get("token")
          messages = App.request "messeges:entities"
          info     = agent.get("info")
          name     = (if info.name then info.name else info.display_name)

          messages.add(@agentMsgs.where token: token)

          agent_msg =
            token:      token
            name:       name
            sender:     "visitor"
            message:    body
            time:       new Date()
            viewing:    false
            timesimple: moment().format('hh:mma')

          if transfer.length
            accepted = $(transfer).find('accepted')
            transfer_id   = $(transfer).attr('id')

            if accepted.length
              vtoken = $(transfer).find('vjid').text()
              msg = @agentMsgs.findWhere({token: token, trn_id: transfer_id})

              res =
                trn_responded: true

              if accepted.text() is "true" then res.trn_accepted = true
              else res.trn_accepted = false

              agent_msg = ""

              msg.set res

            else
              reason        = $(transfer).find('reason').text()
              visitor_token = $(transfer).find('vtoken').text()
              visitor_name  = $(transfer).find('vjid').text()

              agent_msg.transfer      = true
              agent_msg.trn_reason    = reason
              agent_msg.trn_vname     = visitor_name
              agent_msg.trn_vtoken    = visitor_token
              agent_msg.trn_responded = false
              agent_msg.trn_accepted  = false
              agent_msg.trn_id        = transfer_id

          if messages.last() and messages.last().get("name") is name
            agent_msg.child      = true
            agent_msg.childClass = "child"


          if agent_msg
            @agentMsgs.add agent_msg

            if Backbone.history.fragment.indexOf(token)==-1
              agent.addUnread()

      true

    displayCurrentUrl:(token, jid, url) ->
      curUrl =
        token:      token
        jid:        jid
        sender:     "visitor"
        message:    url
        time:       new Date()
        timesimple: moment().format('hh:mma')
        viewing:    true
      @messages.add curUrl
      localStorage.setItem("ofc-chatlog-"+token, JSON.stringify(curUrl))

