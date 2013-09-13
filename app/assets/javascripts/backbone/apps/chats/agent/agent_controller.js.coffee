@Offerchat.module "ChatsApp.Agent", (Agent, App, Backbone, Marionette, $, _) ->

  class Agent.Controller extends App.Controllers.Base
    interval:  null
    composing: null

    initialize: (options ={}) ->
      { @token }   = options
      @connection = App.xmpp.connection
      @agents     = App.request "get:online:agents"
      @agent      = @agents.findWhere token: @token
      @agent      = App.request "online:agent:entity" if typeof @agent is "undefined"
      @messages   = App.request "get:agent:chats:messages"
      @height     = App.request "get:chat:window:height"
      @layout     = @getLayout()

      @agent.setActiveChat() if @agent

      @currentMsgs = App.request "messeges:entities"
      @currentMsgs.add @messages.where({token: @token})

      @listenTo @agents, "all", (type) =>
        agent = @agents.findWhere token: @token

        if type is "add" and typeof agent isnt "undefined"
          agent.setActiveChat()

        unless type is "remove"
          unless typeof agent is "undefined"
            @agent.set agent.attributes

      @listenTo @messages, "add", (message) =>
        if message.get("token") is @token
          @currentMsgs.add message
          $(".chat-viewer-content").animate({ scrollTop: $('.chat-viewer-inner')[0].scrollHeight}, 500);

      $(window).resize =>
        @height.set
          height: $(window).height()
          str_h:  ($(window).height() - 256) + "px"

      @listenTo @layout, "show", =>
        @agentInfo()
        @loadChatsView()

      @show @layout

    agentInfo: ->
      agentInfoView = @getAgentInfo()
      @layout.agentRegion.show agentInfoView

    loadChatsView: ->
      chatsView = @getChats()
      @listenTo chatsView, "agent:is:typing", @sendChat

      @listenTo chatsView, "childview:chat:transfer:accept", (msg) =>
        @respondTransfer msg.model, 'accepted'

        vtoken = msg.model.get('trn_vtoken')

        visitorList = App.request "get:chats:visitors"
        visitor = visitorList.findWhere token: vtoken

        info = visitor.get("info")
        info.chatting =
          agent: gon.current_user.jabber_user
          name: gon.current_user.display_name
          status: true

        visitor.set {info: info}

        App.navigate "chats/visitor/#{vtoken}", trigger: true   # navigate to visitor chat

        # send stanza to accept
        agent_jid = "#{@token}@#{gon.chat_info.server_name}"
        msg = $msg({to: agent_jid, type: "chat"}).c('transfer', {id: msg.model.get('trn_id')}).c('accepted').t('true').up().c('vjid').t(vtoken)
        @connectionSend msg, agent_jid


        # this is where the magic begins
        # send a chat informing visitor about the transfer
        currentMsgs = App.request "messeges:entities"
        messages    = App.request "get:chats:messages"
        currentMsgs.add messages.where({token: vtoken})

        message = "Hello I will be assisting you from hereon."
        currentMsg =
          token:      vtoken
          sender:     "agent"
          jid:        "You"
          message:    message
          time:       new Date()
          timesimple: moment().format('hh:mma')

        if currentMsgs.last() and currentMsgs.last().get("sender") is "agent"
          currentMsg.child      = true
          currentMsg.childClass = "child"

        messages.add currentMsg

        localStorage.setItem("ofc-chatlog-"+vtoken, JSON.stringify(messages))
        $(".chat-viewer-content").animate({ scrollTop: $('.chat-viewer-inner')[0].scrollHeight}, 500)

        # send msg to visitor that accepted
        to  = "#{visitor.get("jid")}@#{gon.chat_info.server_name}"
        msg = $msg({to: to, type: "chat"}).c('body').t($.trim(message))

        @connectionSend msg, to


      @listenTo chatsView, "childview:chat:transfer:decline", (msg) =>
        @respondTransfer msg.model, 'declined'

        # send stanza to decline
        vtoken = msg.model.get('trn_vtoken')
        agent_jid = "#{@token}@#{gon.chat_info.server_name}"
        msg = $msg({to: agent_jid, type: "chat"}).c('transfer', {id: msg.model.get('trn_id')}).c('accepted').t('false').up().c('vjid').t(vtoken)
        @connectionSend msg, agent_jid

      @layout.chatsRegion.show chatsView

    respondTransfer: (model, response) ->
      update_obj =
        trn_responded: true

      if response is 'accepted' then update_obj.trn_accepted = true

      model.set(update_obj)
      true

    sendChat: (ev) =>
      message = $(ev.currentTarget).val()
      clearInterval(@interval)

      if ev.keyCode is 13 and message isnt ""
        messages = App.request "messeges:entities"
        messages.add(@messages.where token: @token)

        to  = "#{@agent.get("jid")}@#{gon.chat_info.server_name}"
        msg = $msg({to: to, type: "chat"}).c('body').t($.trim(message))
        @connectionSend msg, to

        message = App.request "detect:url:from:string", message

        msgs =
          token:      @token
          sender:     "agent"
          name:       "You"
          message:    message
          time:       new Date()
          timesimple: moment().format('hh:mma')
          child:      (if messages.last() and messages.last().get("sender") is "agent" then true else false)
          childclass: (if messages.last() and messages.last().get("sender") is "agent" then "child" else "")

        @messages.add msgs

        $(".chat-viewer-content").animate({ scrollTop: $('.chat-viewer-inner')[0].scrollHeight}, 500);
        $(ev.currentTarget).val("")
        @composing = null

      else
        to        = "#{@agent.get("jid")}@#{gon.chat_info.server_name}"
        composing = $msg({type: 'chat', to: to}).c('composing', {xmlns: 'http://jabber.org/protocol/chatstates'})
        paused    = $msg({type: 'chat', to: to}).c('paused', {xmlns: 'http://jabber.org/protocol/chatstates'})
        inactive  = $msg({type: 'chat', to: to}).c('inactive', {xmlns: 'http://jabber.org/protocol/chatstates'})

        unless @composing?
          @connection.send composing
          @composing = true

        #send paused after 10s
        @interval = setInterval(=>
          @composing = null
          @connection.send paused
          clearInterval @interval
        , 10000)

    getLayout: ->
      new Agent.Layout

    getAgentInfo: ->
      new Agent.Info
        model: @agent

    getChats: ->
      new Agent.Chats
        collection: @currentMsgs
        model: @height
