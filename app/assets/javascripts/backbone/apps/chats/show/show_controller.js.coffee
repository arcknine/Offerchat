@Offerchat.module "ChatsApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Controller extends App.Controllers.Base
    interval:  null
    composing: null

    initialize: (options ={}) ->
      { @token }   = options
      @connection  = App.xmpp.connection
      @layout      = @getLayout()
      visitors     = App.request "get:chats:visitors"
      @visitor     = visitors.findWhere token: @token
      @visitor     = App.request "visitor:entity" if typeof @visitor is "undefined"
      @height      = App.request "get:chat:window:height"
      @messages    = App.request "get:chats:messages"
      @transcript  = App.request "transcript:entity"
      @transcript.url = Routes.email_export_transcript_index_path

      if @messages.length is 0
        @messages.add JSON.parse(localStorage.getItem("ofc-chatlog-"+@token))
      else
        localStorage.setItem("ofc-chatlog-"+@token, JSON.stringify(@messages))

      @currentMsgs = App.request "messeges:entities"
      @agentMsgs   = App.request "get:agent:chats:messages"
      @currentMsgs.add @messages.where({token: @token})

      @listenTo visitors, "add", =>
        if @visitor.get("token") isnt @token
          visitor = visitors.findWhere token: @token
          @visitor.set visitor.attributes unless typeof visitor is "undefined"

      @listenTo @messages, "add", (message) =>
        if message.get("token") is @token
          @currentMsgs.add message
          $(".chat-viewer-content").animate({ scrollTop: $('.chat-viewer-inner')[0].scrollHeight}, 500);

      @listenTo @layout, "show", =>
        @visitorInfoView()
        @chatsView()

      @resizeChatWrapper()
      @show @layout

    visitorInfoView: ->
      @visitor.generateGravatarSource()
      visitorView = @getVisitorInfoView()
      @layout.visitorRegion.show visitorView

    chatsView: ->
      chatsView = @getChatsView()

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

      App.execute "when:fetched", agents, =>

        if agents.length is 0
          alert "There are no other agents online."
        else
          @firstAgent = agents.first()

          modalView = @getTransferChatModalView @visitor
          formView  = App.request "modal:wrapper", modalView

          agentListView = @getAgents agents

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

              agent_jid = "#{agent_jid}@#{gon.chat_info.server_name}"
              visitor_jid = @visitor.get("jid")
              msg = $msg({to: agent_jid, type: "chat"}).c('transfer',{id: transfer_id}).c('reason').t(reason.val()).up().c('vjid').t(visitor_jid).up().c('vtoken').t(@visitor.get("token"))  # create xmpp msg
              @connectionSend msg, agent_jid

              formView.close()

              # App.navigate Routes.root_path()
            else
              reason.closest("fieldset").addClass("field-error")
              reason.next("div").html("Please provide a reason for transferring")


          @listenTo agentListView, "childview:select:transfer:agent", (item) =>
            current_agent = $(item.el).parents('div.btn-selector').find(".current-selection")
            current_agent.attr("data-jid", item.model.get("jabber_user")).html(item.model.get("name"))

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
      message = $(ev.currentTarget).val()
      clearInterval(@interval)

      if ev.keyCode is 13 and message isnt ""
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
        localStorage.setItem("ofc-chatlog-"+@token, JSON.stringify(@messages))
        $(".chat-viewer-content").animate({ scrollTop: $('.chat-viewer-inner')[0].scrollHeight}, 500)
        $(ev.currentTarget).val("")
        @composing = null

        to  = "#{@visitor.get("jid")}@#{gon.chat_info.server_name}"
        msg = $msg({to: to, type: "chat"}).c('body').t($.trim(message))

        @connectionSend msg, to

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
      new Show.Layout

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
        @showNotification("Transcript has been success fully sent!")



