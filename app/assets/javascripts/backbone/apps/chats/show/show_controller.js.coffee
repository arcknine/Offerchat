@Offerchat.module "ChatsApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Controller extends App.Controllers.Base
    interval:  null
    composing: null

    initialize: (options ={}) ->
      { @token }   = options
      @connection  = App.xmpp.connection
      visitors     = App.request "get:chats:visitors"
      @visitor     = visitors.findWhere token: @token
      visitor      = @visitor
      @visitor     = App.request "visitor:entity" if typeof @visitor is "undefined"
      @height      = App.request "get:chat:window:height"
      @messages    = App.request "get:chats:messages"
      @transcript  = App.request "transcript:entity"
      @transcript.url = Routes.email_export_transcript_index_path
      @scroll      = false
      @last_agent_msg = ""

      @layout      = @getLayout()
      # console.log "layout", @visitor

      @visitor.setActiveChat() if @visitor

      @agentMsgs   = App.request "get:agent:chats:messages"
      if typeof visitor isnt "undefined" and @visitor.get("history") isnt true
        @parseChatHistory()
      else
        @currentMsgs = App.request "messeges:entities"
        @currentMsgs.add @messages.where({token: @token})

      @listenTo visitors, "add", =>
        if @visitor.get("token") isnt @token
          visitor = visitors.findWhere token: @token
          unless typeof visitor is "undefined"
            visitor.setActiveChat()
            visitor.set history: true
            @visitor.set visitor.attributes
            @parseChatHistory()
            @layout = @getLayout()

      @listenTo @visitor, "all", =>
        visitors.sort()

      @listenTo @messages, "add", (message) =>
        if message.get("token") is @token
          @currentMsgs.add message
          $(".chat-viewer-content").animate({ scrollTop: $('.chat-viewer-inner')[0].scrollHeight}, 500) if @scroll is true

      @listenTo @layout, "show", =>
        @visitorInfoView()
        @chatsView()
        App.execute "subtract:unread", 'visitor', @visitor

      @resizeChatWrapper()
      @show @layout

    visitorInfoView: ->
      @visitor.generateGravatarSource()
      visitorView = @getVisitorInfoView()
      @layout.visitorRegion.show visitorView

    chatsView: ->
      chatsView = @getChatsView()

      @listenTo chatsView, "show", ->
        $(chatsView.el).find("textarea").focus()

      @listenTo chatsView, "is:typing", @sendChat
      @listenTo chatsView, "end:chat", @endChat

      @listenTo chatsView, "actions:menu:clicked", (elem) =>
        @actionsMenuClicked chatsView, elem

      @listenTo chatsView, "menu:option:selected", (elem) =>
        option = $(elem.currentTarget).data("action")

        if option is "transfer"
          @transferChat()
        else if option is "export"
          @showTranscriptModalView @visitor
          @transcript.set messages: $('#transcript-collection').html()
        # else if option is "ban"

      @layout.chatsRegion.show chatsView
      $(".chat-viewer-content").animate({ scrollTop: $('.chat-viewer-inner')[0].scrollHeight}, 500);

    transferChat: =>
      # only get online agents
      agents = App.request "get:online:agents"
      siteAgents  = App.request "online:agents:entities"

      App.execute "when:fetched", agents, =>

        if agents.length is 0
          alert "There are no other agents online."
        else
          @firstAgent = agents.first()

          modalView = @getTransferChatModalView @visitor
          formView  = App.request "modal:wrapper", modalView

          $.each agents.models, (key, value) =>
            val = siteAgents.findWhere jid: value.get("jid")
            siteAgents.add value if typeof val is "undefined"

          agentListView = @getAgents siteAgents

          @listenTo formView, "show", =>
            modalView.agentsListRegion.show agentListView

          @listenTo modalView, "choose:agent:clicked", (elem) ->
            params =
              element: elem
              openClass: "btn-selector"
              activeClass: "btn-action-selector"
            modalView.toggleDropDown params

          @listenTo formView, "modal:unsubmit", (item) ->
            reason = $(item.view.el).find('textarea.large')

            if reason.val()
              agent_elem = $(item.view.el).find(".current-selection")
              agent_jid = agent_elem.data("jid") # get agent jid
              agent_name = agent_elem.text()

              transfer_id = "#{Number(new Date())}"

              currentMsg =
                token:      "#{agent_jid}"
                sender:     "agent"
                jid:        "You"
                name:       agent_name
                time:       new Date()
                timesimple: moment().format('hh:mma')

                transfer:   true
                trn_id:     transfer_id
                trn_owned:  true
                trn_reason: reason.val()
                trn_responded: false
                trn_vtoken: @visitor.get("token")
                trn_accepted: false

              @agentMsgs.add currentMsg

              # navigate to agent chat after transfering visitor
              App.navigate "chats/agent/#{agent_jid}", trigger: true

              agent_jid = "#{agent_jid}@#{gon.chat_info.server_name}"
              visitor_jid = @visitor.get("jid")
              msg = $msg({to: agent_jid, type: "chat"}).c('transfer',{id: transfer_id}).c('reason').t(reason.val()).up().c('vjid').t(visitor_jid).up().c('vtoken').t(@visitor.get("token"))  # create xmpp msg
              @connectionSend msg, agent_jid

              formView.close()

            else
              reason.closest("fieldset").addClass("field-error")
              reason.next("div").html("Please provide a reason for transferring")


          @listenTo agentListView, "childview:select:transfer:agent", (item) =>
            agent_info = item.model.get("info")
            current_agent = $(item.el).parents('div.btn-selector').find(".current-selection")
            current_agent.attr("data-jid", item.model.get("jid")).html(agent_info.name)

            agentListView.closeDropDown()
            $(agentListView.el).parents(".btn-selector").find(".btn-action-selector").removeClass("active")


          @listenTo formView, "modal:close", (item)->
            formView.close()

          @listenTo formView, "modal:cancel", (item)->
            formView.close()

          App.modalRegion.show formView

    getTransferChatModalView: (model) ->
      new Show.TransferChatLayout
        model: model
        firstAgent: @firstAgent

    getAgents: (agents) ->
      new Show.TransferChatAgents
        collection: agents

    actionsMenuClicked: (view, elem) ->
      params =
        element: elem
        openClass: "btn-selector"
        activeClass: "btn-action-selector"
      view.toggleDropDown params

    endChat: (item) =>
      if confirm("Are you sure you want to end this chat session?")
        jid = "#{@visitor.get("jid")}@#{gon.chat_info.server_name}"
        msg = $msg({to: jid, type: "chat"}).c('body').t("!endchat")

        @connectionSend msg, jid    # function can be found in controller base

        # TODO:
        # send report to dashboard

        App.navigate Routes.root_path(), trigger: true


    sendChat: (ev) =>
      input_elem = $(ev.currentTarget)
      message = $.trim(input_elem.val())
      clearInterval(@interval)

      if message is ""
        @last_agent_msg = ""

      if ev.keyCode is 13 and message isnt ""

        if @last_agent_msg isnt ""
          @last_agent_msg.set message: message, time: new Date()
          @last_agent_msg = ""

          to  = "#{@visitor.get("jid")}@#{gon.chat_info.server_name}"
          msg = $msg({to: to, type: "chat", edit: true}).c('body').t($.trim(message))
          @connectionSend msg, to

        else

          @visitor.set("yours", 1)
          $(".chat-actions-notifications").remove()

          to  = "#{@visitor.get("jid")}@#{gon.chat_info.server_name}"
          msg = $msg({to: to, type: "chat"}).c('body').t($.trim(message))
          @connectionSend msg, to

          message = App.request "detect:url:from:string", message

          currentMsg =
            token:      @token
            sender:     "agent"
            jid:        "You"
            message:    message
            time:       new Date()
            timesimple: moment().format('hh:mma')

          if @currentMsgs.last() and @currentMsgs.last().get("sender") is "agent"
            currentMsg.child      = true
            currentMsg.childClass = "child"

          @messages.add currentMsg
          # localStorage.setItem("ofc-chatlog-"+@token, JSON.stringify(@messages))

        $(".chat-viewer-content").animate({ scrollTop: $('.chat-viewer-inner')[0].scrollHeight}, 500)
        input_elem.val("")
        @composing = null

      else if ev.keyCode is 38 and message is ""
        agent_msgs = @currentMsgs.where sender: "agent"
        if agent_msgs.length > 0
          @last_agent_msg = agent_msgs[agent_msgs.length - 1]
          msg = @last_agent_msg.get("message")

          input_elem.val msg

      else
        to        = "#{@visitor.get("jid")}@#{gon.chat_info.server_name}"
        composing = $msg({type: 'chat', to: to}).c('composing', {xmlns: 'http://jabber.org/protocol/chatstates'})
        paused    = $msg({type: 'chat', to: to}).c('paused', {xmlns: 'http://jabber.org/protocol/chatstates'})
        inactive  = $msg({type: 'chat', to: to}).c('inactive', {xmlns: 'http://jabber.org/protocol/chatstates'})

        unless @composing?
          @connection.send composing
          @composing = true

        #send paused after 5s
        @interval = setInterval(=>
          @composing = null
          @connection.send paused
          clearInterval @interval
        , 5000)


    resizeChatWrapper: ->
      visitor_height = ($(window).height() - 296) + "px"
      @height.set visitor_chats: visitor_height

      $(window).resize =>
        @height.set
          height:        $(window).height()
          visitor_chats: ($(window).height() - 296) + "px"

    getLayout: ->
      visitor_info = @visitor.get("info")
      # console.log visitor_info
      unless typeof visitor_info is "undefined"
        chatting = visitor_info.chatting

        active_chat = false
        if chatting.agent isnt "" and chatting.agent isnt gon.current_user.jabber_user
          active_chat = true

        layout = new Show.Layout
          is_chatting: active_chat
          agent_name: chatting.name
      else
        layout = new Show.Layout

      layout

    getVisitorInfoView: ->
      new Show.VisitorInfo
        model: @visitor

    getChatsView: ->
      new Show.ChatsList
        collection: @currentMsgs
        model:      @height

    getTranscriptModalView: ->
      new Show.TransciptModal
        collection: @currentMsgs
        model: @transcript

    showTranscriptModalView: (messages)->
      modalView = @getTranscriptModalView messages
      formView  = App.request "modal:wrapper", modalView
      App.modalRegion.show formView

      @listenTo formView, "modal:cancel", (item)->
        formView.close()

      @listenTo @transcript, "created", (model) =>
        formView.close()
        @showNotification("Transcript has been successfully sent!")

    parseChatHistory: ->
      history      = App.request "get:chats:history", @token
      @currentMsgs = App.request "messeges:entities"

      App.execute "when:fetched", history, =>
        messages = @messages.where token: @token
        @messages.remove messages
        @visitor.set history: true
        @scroll = false
        info    = @visitor.get("info")
        regex   = /\[Chat Trigger\]\s(.*)/

        if info.referrer && history.models.length is 0
          referrer =
            token:      @token
            sender:     "visitor"
            message:    info.referrer
            time:       new Date()
            timesimple: moment().format('hh:mma')
            referrer:   true

          @messages.add referrer

        $.each history.models, (index, model) =>
          sender = (if model.get("sender") is @visitor.get("info").name then "visitor" else model.get("sender"))
          jid    = (if model.get("sender") is @visitor.get("info").name then @visitor.get("info").name else "You")

          if info.referrer && index is 0
            referrer =
              token:      @token
              sender:     "visitor"
              message:    info.referrer
              time:       new Date()
              timesimple: moment(model.get("sent")).format('hh:mma')
              referrer:   true

            @messages.add referrer

          msgs =
            jid:     jid
            message: model.get("msg")
            sender:  sender
            time:    model.get("sent")
            timesimple: moment(model.get("sent")).format('hh:mma')
            token:   @token
            viewing: false
            scroll:  false

          if regex.test(msgs.message)
            msgs.message = msgs.message.replace("[Chat Trigger] ", "")
            msgs.trigger = true

          if @currentMsgs.last() and @currentMsgs.last().get("sender") is sender
            msgs.child      = true
            msgs.childClass = "child"

          # @currentMsgs.add msgs
          @messages.add msgs

        # @messages.add messages[0]
        $(".chat-viewer-content").animate({ scrollTop: $('.chat-viewer-inner')[0].scrollHeight}, 100)
        @scroll = true