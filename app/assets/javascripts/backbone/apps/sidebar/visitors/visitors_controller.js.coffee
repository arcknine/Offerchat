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
      @siteAgents  = App.request "online:agents:entities"
      @layout      = @getLayout()
      @unreadMsgs  = App.request "unread:messages:entities"

      App.commands.setHandler "add:is:typing", (vname) =>
        isTyping = @getTypingView vname
        $('#chats-collection').append(isTyping.render().$el)
        $(".chat-viewer-content").animate({ scrollTop: $('.chat-viewer-inner')[0].scrollHeight}, 500)

      App.commands.setHandler "remove:is:typing", =>
        $("#chats-collection").find(".is-typing").remove()

      App.commands.setHandler "set:new:chat:title", =>
        # change title here
        title = $('title')

        clearInterval(@title_interval)
        @title_interval = setInterval(=>
          if title.text() == "Offerchat"
            title.text "New message"
          else
            title.text "Offerchat"
        , 2000)

      App.commands.setHandler "set:original:title", =>
        $('title').text "Offerchat"
        clearInterval @title_interval

      App.commands.setHandler "set:no:active:chat", =>
        @visitors.updateModels('active', null)
        @agents.updateModels('active', null)

      App.commands.setHandler "chat:sound:notify", =>
        try
          sound = document.getElementById("beep-notify")
          sound.play() if sound

      App.reqres.setHandler "detect:url:from:string", (str) =>
        @detectURL str

      if App.xmpp.status is Strophe.Status.CONNECTED
        @connection = App.xmpp.connection
        @connected()

      @listenTo @currentSite, "change", =>
        @siteAgents = App.request "online:agents:entities"
        @visitorsList()
        @agentsList()

      @listenTo @currentSite, "show", =>
        @visitorsList()
        @agentsList()

      @listenTo @visitors, "all", =>
        @visitorsList()

      @listenTo @agents, "all", =>
        # agents = @agents.where token: "41376457245"
        # @agents.remove agents
        @agentsList()

      @listenTo @unreadMsgs, "all", (type) =>
        unreads = []
        $.each @sites.models, (key, value) =>
          unreads = @unreadMsgs.where api_key: value.get("api_key")
          if unreads.length > 0
            value.set unread: unreads.length, "new": true, newClass: "new"
          else
            value.set unread: unreads.length, "new": false, newClass: ""

      App.reqres.setHandler "get:chats:messages", =>
        @messages

      App.reqres.setHandler "get:agent:chats:messages", =>
        @agentMsgs

      App.reqres.setHandler "get:chats:visitors", =>
        @visitors

      App.reqres.setHandler "get:online:agents", =>
        @agents

      @show @layout

      $(window).resize ->
        if ( $("#chat-sidebar-region").hasClass("chats-sidebar-container") )
          $("#chat-sidebar-region").css("height", ($(window).height() - 93) + "px")

      if ($("#chat-sidebar-region").hasClass("chats-sidebar-container") )
        $("#chat-sidebar-region").css("height", ($(window).height() - 93) + "px")

    getLayout: ->
      new Visitors.Layout

    getVisitorsView: (visitors) ->
      new Visitors.List
        collection: visitors

    getAgentsView: (agents) ->
      new Visitors.Agents
        collection: agents

    getTypingView: (vname) ->
      new Visitors.Typing
        name: vname

    visitorsList: ->
      unless @currentSite.get("all")
        visitors = App.request "visitors:entities"
        visitors.set @visitors.where { api_key: @currentSite.get("api_key") }
      else
        visitors = @visitors

      visitorsView = @getVisitorsView(visitors)

      @listenTo visitorsView, "childview:click:visitor:tab", (visitor) =>
        App.navigate "chats/visitor/#{visitor.model.get('token')}", trigger: true
        @subtractCounter "visitor", visitor.model

      @layout.visitorsRegion.show visitorsView

    agentsList: ->
      unless @currentSite.get("all")
        api_keys = [@currentSite.get("api_key")]
      else
        api_keys = @sites.pluck("api_key")

      $.each @agents.models, (key, value) =>
        val = @siteAgents.findWhere jid: value.get("jid")
        @siteAgents.add value if _.intersection(api_keys, value.get("api_keys")).length > 0 and typeof val is "undefined"

      agentsView = @getAgentsView @siteAgents

      @listenTo agentsView, "childview:click:agent:tab", (agent) =>
        App.navigate "chats/agent/#{agent.model.get('token')}", trigger: true
        @subtractCounter "agent", agent.model

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
      status   = $(presence).find('status').text()

      if agent
        # set online/offline here
        if status
          if status is 'Online'
            agent.set("status", "online")
          else
            agent.set("status", null)

      if info.chatting
        chatting  = (if info.chatting.status then "busy" else null)
        chatting  = (if gon.current_user.jabber_user is info.chatting.agent then "online" else chatting)
        available = (if chatting isnt null then true else false)
        title     = (if chatting isnt null then "Chatting with #{info.chatting.name}" else "")
        title     = (if chatting is "online" then "Chatting with You" else title)
        yours     = (if chatting is "busy" then 3 else 1)
        yours     = (if chatting is null then 2 else yours)

      if type is "unavailable"
        if node
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

          else if typeof agent isnt "undefined"
            # remove agent from list
            App.navigate Routes.root_path(), trigger: true if Backbone.history.fragment.indexOf(agent.get("token")) != -1
            @siteAgents.remove agent
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

      else if typeof visitor is "undefined" && info && info.api_key

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
          yours:     yours

      else
        unless agent
          @displayCurrentUrl(token, node, info.url)
          resources = visitor.get "resources"
          resources.push(resource) if $.inArray(resource, resources) is -1
          visitor.set { jid: node, resources: resources, info: info, status: chatting, available: available, title: title, yours: yours }

      true

    detectURL: (str) ->
      urlPattern          = /\b(?:https?|ftp):\/\/[a-z0-9-+&@#\/%?=~_|!:,.;]*[a-z0-9-+&@#\/%=~_|]/gim
      pseudoUrlPattern    = /(^|[^\/])(www\.[\S]+(\b|$))/gim
      emailAddressPattern = /\w+@[a-zA-Z_]+?(?:\.[a-zA-Z]{2,6})+/gim

      str
        .replace(urlPattern, '<a href="$&" target="_blank">$&</a>')
        .replace(pseudoUrlPattern, '$1<a href="http://$2" target="_blank">$2</a>')
        .replace(emailAddressPattern, '<a href="mailto:$&">$&</a>')

    onPrivateMessage: (message) =>
      from      = $(message).attr("from")
      jid       = Strophe.getBareJidFromJid from
      node      = Strophe.getNodeFromJid from
      body      = $(message).find("body").text()
      agent     = @agents.findWhere jid: node
      transfer  = $(message).find("transfer")
      comp      = $(message).find("composing")
      paused    = $(message).find("paused")

      if body
        body = App.request "detect:url:from:string", body

      if comp.length or paused.length
        if typeof agent is "undefined"
          visitor  = @visitors.findWhere { jid: node }
          info     = visitor.get("info")
          token    = visitor.get("token")
        else
          info     = agent.get("info")
          token    = agent.get("token")

        if Backbone.history.fragment.indexOf(token) isnt -1
          if paused.length
            App.execute "remove:is:typing"
          else
            App.execute "add:is:typing", info.name

      else if body and typeof agent is "undefined"
        messages = App.request "messeges:entities"
        visitor  = @visitors.findWhere { jid: node }
        token    = visitor.get("token")
        info     = visitor.get "info"
        new_message = @messages.where token: token
        messages.add(new_message)
        # localStorage.setItem("ofc-chatlog-"+token, JSON.stringify(new_message))
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
          visitor = @visitors.findWhere({token: token})
          visitor.addUnread()
          visitor.set("yours", 1)

          @visitors.sort()
          @addCounter "visitor", visitor

          App.execute "set:new:chat:title"

        else
          App.execute "remove:is:typing"

        # chat sound here
        App.execute "chat:sound:notify"

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

              # the requesting agent will be redirected to the chat window
              # of the answering agent???
              # App.navigate "chats/agent/#{token}", trigger: true

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
            agent_msg.childclass = "child"

          if agent_msg
            @agentMsgs.add agent_msg

            if Backbone.history.fragment.indexOf(token)==-1
              agent.addUnread()
              @addCounter "agent", agent

              App.execute "set:new:chat:title"
            else
              App.execute "remove:is:typing"

            # chat sound here
            App.execute "chat:sound:notify"

      true

    addCounter: (type, model) ->
      if type is "agent"
        counter  = 0
        api_keys = model.get("api_keys")
        $.each api_keys, (key, api_key) =>
          $.each @agents.models, (inner_key, inner_value) =>
            unread = @unreadMsgs.findWhere api_key: api_key, token: model.get("token")
            if _.intersection(api_keys, inner_value.get("api_keys")).length > 0 && typeof unread is "undefined"
              @unreadMsgs.add api_key: api_key, token: model.get("token")
      else
        unread = @unreadMsgs.findWhere api_key: model.get("api_key"), token: model.get("token")
        @unreadMsgs.add api_key: model.get("api_key"), token: model.get("token") if typeof unread is "undefined"

    subtractCounter: (type, model) ->
      if type is "agent"
        api_keys = model.get("api_keys")
        $.each api_keys, (key, api_key) =>
          unread = @unreadMsgs.findWhere api_key: api_key, token: model.get("token")
          @unreadMsgs.remove unread unless typeof unread is "undefined"
      else
        unread = @unreadMsgs.findWhere api_key: model.get("api_key"), token: model.get("token")
        @unreadMsgs.remove unread unless typeof unread is "undefined"

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
      # localStorage.setItem("ofc-chatlog-"+token, JSON.stringify(curUrl))

