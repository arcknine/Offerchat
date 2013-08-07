@Offerchat.module "ChatsApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Controller extends App.Controllers.Base

    visitorStorage: new Backbone.LocalStorage "visitor"

    interval:  null
    composing: null

    initialize: (options ={}) ->
      { @token }   = options
      @connection = App.xmpp.connection
      @layout     = @getLayout()

      @allMessages = App.request "get:chats:messages"
      visitors     = App.request "get:chats:visitors"
      @visitor     = App.request "visitor:entity"

      @messages    = App.request "messeges:entities"

      unless @allMessages.length is 0
        @messages.add(@allMessages.where { token: @token })

      unless visitors.length is 0
        @visitor.set visitors.findWhere({ jid: @token }).attributes

      @listenTo visitors, "add", (item) =>
        if item.get("jid") is @token
          @visitor.set item.attributes
          @visitor.generateGravatarSource()

      @listenTo @allMessages, "add", (item) =>
        item.set { child: true, childclass: "child" } if @messages.last() and @messages.last().get("jid") is item.get("jid") and item.get("sender") isnt "agent"
        @messages.add(item) if item.get("token") is @token

        $(".chat-viewer-content").animate({ scrollTop: $('.chat-viewer-inner')[0].scrollHeight}, 500);

      @listenTo @layout, "show", =>
        @visitorInfoView @visitor
        @chatsView @messages

      @show @layout

    visitorInfoView: (visitor) ->
      visitor.generateGravatarSource()
      visitorView = @getVisitorInfoView visitor
      @layout.visitorRegion.show visitorView

    chatsView: (messages) ->
      chatsView = @getChatsView messages

      @listenTo chatsView, "is:typing", @sendChat
      @listenTo chatsView, "end:chat", @endChat

      @listenTo chatsView, "actions:menu:clicked", (elem) =>
        @actionsMenuClicked chatsView, elem

      @listenTo chatsView, "menu:option:selected", (elem) =>
        option = $(elem.currentTarget).data("action")

        if option is "transfer"
          @transferChat()
        # else if option is "export"
        # else if option is "ban"

      @layout.chatsRegion.show chatsView

    transferChat: =>
      # TODO:
      # only get online agents
      agents = App.request "agents:entities"

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
        # get agent jid
        # create xmpp msg
        # msg = $msg({to: agent_jid, type: "chat"}).c('inactive', {xmlns: 'http://jabber.org/protocol/chatstates'})
        # @connection.send msg

        console.log 'itemmmmmmmmm', item
        # false




      @listenTo agentListView, "childview:select:transfer:agent", (item) =>
        $(item.el).parents('div.btn-selector').find(".current-selection").html(item.model.get("name"))
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
        jid = @visitor.get("jid")
        msg = $msg({to: jid, type: "chat"}).c('body').t("!endchat")

        @connectionSend msg, jid    # function can be found in controller base

        # TODO:
        # send report to dashboard

        App.navigate Routes.root_path(), trigger: true

    sendChat: (ev) =>
      message = $(ev.currentTarget).val()
      clearInterval(@interval)

      if ev.keyCode is 13 and message isnt ""
        if @messages.last() and @messages.last().get("sender") is "agent"
          console.log @messages.last().get("sender")
        @messages.add
          token:      @token
          sender:     "agent"
          jid:        "You"
          message:    message
          time:       new Date()
          timesimple: moment().format('hh:mma')
          child:      (if @messages.last() and @messages.last().get("sender") is "agent" then true else false)
          childclass: (if @messages.last() and @messages.last().get("sender") is "agent" then "child" else "")

        @allMessages.add @messages.last()

        $(".chat-viewer-content").animate({ scrollTop: $('.chat-viewer-inner')[0].scrollHeight}, 500);
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

        #send paused after 10s
        @interval = setInterval(=>
          @composing = null
          @connection.send paused
          clearInterval @interval
        , 10000)

    getLayout: ->
      new Show.Layout

    getVisitorInfoView: (visitor) ->
      new Show.VisitorInfo
        model: visitor

    getChatsView: (messages) ->
      new Show.ChatsList
        collection: messages

