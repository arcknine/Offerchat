@Offerchat.module "ChatsApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Controller extends App.Controllers.Base
    interval:  null
    composing: null

    initialize: (options ={}) ->
      { @token }      = options
      @connection     = App.xmpp.connection
      visitors        = App.request "get:chats:visitors"
      @visitor        = visitors.findWhere token: @token
      visitor         = @visitor
      @visitor        = App.request "visitor:entity" if typeof @visitor is "undefined"
      @height         = App.request "get:chat:window:height"
      @messages       = App.request "get:chats:messages"
      @transcript     = App.request "transcript:entity"
      @transcript.url = Routes.email_export_transcript_index_path
      @scroll         = false
      @last_agent_msg = ""
      @diff           = 0

      all_sites = App.request "get:all:sites"

      @qrs = App.request "get:qrs"
      App.execute "when:fetched", @qrs, =>
        App.reqres.setHandler "get:qrs", =>
          @qrs

      @profile = App.request "get:current:profile"
      App.execute "when:fetched", @profile, =>

        @currentSite = all_sites.findWhere api_key: @visitor.get("api_key")
        @pid = @currentSite.get("plan")

        if @pid isnt "FREE"
          @visitor_notes_list = App.request "get:visitor_notes", @visitor.get("token")

          @listenTo @visitor_notes_list, "all", (event) =>
            @showNotesCount()

          App.execute "when:fetched", @visitor_notes_list, =>

            @visitor_notes_list.forEach (model, index) ->
              model.set
                created_at: moment(model.get("created_at")).format('MMMM D, YYYY - h:mm a')

      @layout      = @getLayout()

      @visitor.setActiveChat() if @visitor

      @agentMsgs   = App.request "get:agent:chats:messages"
      # if typeof visitor isnt "undefined" and @visitor.get("history") isnt true
      #   @parseChatHistory()
      # else

      @currentMsgs = App.request "messeges:entities"
      @currentMsgs.add @messages.where({token: @token})

      @listenTo visitors, "add", =>
        if @visitor.get("token") isnt @token
          visitor = visitors.findWhere token: @token
          unless typeof visitor is "undefined"
            visitor.setActiveChat()
            visitor.set history: true
            @visitor.set visitor.attributes
            # @parseChatHistory()
            @layout = @getLayout()

      @listenTo @visitor, "all", =>
        visitors.sort()
        @showNotesCount()

      @listenTo @messages, "add", (message) =>
        if message.get("token") is @token
          @currentMsgs.add message
          $(".chat-viewer-content").animate({ scrollTop: $('.chat-viewer-inner')[0].scrollHeight}, 500) if @scroll is true

      @listenTo @layout, "show", =>
        @visitorInfoView()
        @chatsView()
        App.execute "subtract:unread", 'visitor', @visitor


      App.commands.setHandler "set:sidebar:modal:height", =>
        container_height = $(window).height() - @diff
        $(".modal-viewer").attr("style","height:#{container_height}px")

      @resizeChatWrapper()
      @show @layout

    showNotesCount: ->
      if @visitor_notes_list and @visitor_notes_list.length > 0
        notes_count = "(#{@visitor_notes_list.length})"
        $(".notes-count").html notes_count
      else
        $(".notes-count").html("")

    visitorInfoView: ->
      @visitor.generateGravatarSource()
      visitorView = @getVisitorInfoView()

      @listenTo visitorView, "show:quick_responses", =>
        @qrSidebarView()

      @listenTo visitorView, "show:notes", =>
        @notesSidebarView()

      @layout.visitorRegion.show visitorView

    getNewVisitorNotesView: (model) ->
      new Show.ModalVisitorNotesForm
        model: model

    notesSidebarView: ->

      if @pid isnt "FREE"
        visitor_note = App.request "new:visitor_note"
        newVisitorNotesView = @getNewVisitorNotesView visitor_note

        @listenTo newVisitorNotesView, "save:visitor:note", (e, model) =>

          text_area = $(e.currentTarget)
          note = text_area.val()

          obj = new Object()
          obj =
            message: note
            vtoken: @visitor.get("token")

          model.unset("id", "silent") if model.has("id")
          model.url = Routes.visitor_notes_path()
          model.save obj

          # add to current collection
          new_note =
            message: note
            avatar: gon.current_user.avatar
            user_id: gon.current_user.id
            user_name: gon.current_user.display_name
            created_at: moment().format('MMMM D, YYYY - h:mm a')
          @visitor_notes_list.add new_note

          text_area.val("").focus()

        sidebarView = @getNotesSidebarView()
        formView = App.request "sidebar:wrapper", sidebarView

        notesView = @getVisitorNotesList()

        @listenTo notesView, "childview:click:delete:note", (item) =>
          $(".sidebar-modal-fixed").find("a.close").trigger("click")
          confirmView = @getConfirmDelete item.model

          @listenTo confirmView, "click:cancel:delete", (e) =>
            $(".modal-backdrop").remove()

          @listenTo confirmView, "click:confirm:delete", (e) =>
            res = @visitor_notes_list.findWhere id: e.model.get("id")
            res.destroy()
            $(".modal-backdrop").remove()


          $("body").append(confirmView.render().$el)

        @listenTo formView, "show", =>
          sidebarView.notesRegion.show notesView
          sidebarView.newNotesRegion.show newVisitorNotesView
          @diff = 150
          App.execute "set:sidebar:modal:height"

        @listenTo sidebarView, "edit:visitor:info", (e) =>
          @editVisitorView e, "show"

        @listenTo sidebarView, "save:visitor:info", (e) =>

          vname = $(e.view.el).find("#visitor-name").val()
          vemail = $(e.view.el).find("#visitor-email").val()
          vphone = $(e.view.el).find("#visitor-phone").val()

          info = @visitor.get("info")

          info.email = vemail
          info.name = vname
          info.phone = vphone

          @visitor.unset("id", "silent") if @visitor.has("id")

          @visitor.set
            info: info
          @visitor.url = Routes.update_info_visitor_path info.token
          @visitor.save()

          to   = "#{@visitor.get("jid")}@#{gon.chat_info.server_name}"
          pres = $msg({to: to}).c('change').c('name').t(vname).up().c('email').t(vemail).up().c('phone').t(vphone)
          @connectionSend pres

          $(e.view.el).find(".vname").html(vname)
          $(e.view.el).find(".vemail").html(vemail)
          $(e.view.el).find(".vphone").html(vphone)

          @editVisitorView e, "hide"

      else # free accounts
        sidebarView = @getNotesViewFree()
        formView = App.request "sidebar:wrapper", sidebarView

      App.sidebarRegion.show formView

    getConfirmDelete: (note) ->
      new Show.VisitorNoteConfirm
        model: note

    getNotesViewFree: ->
      new Show.ModalVisitorNotesFree
        model: @visitor

    getVisitorNotesList: ->
      new Show.VisitorNotes
        collection: @visitor_notes_list

    editVisitorView: (e, action) ->
      dom = $(e.view.el)
      edit_visitor_info = dom.find(".edit-visitor-info")
      visitor_info = dom.find(".visitor-info")

      if action is "show"
        edit_visitor_info.removeClass("hide")
        visitor_info.addClass("hide")
        dom.find("#visitor-name").focus()
      else
        edit_visitor_info.addClass("hide")
        visitor_info.removeClass("hide")

    getNotesSidebarView: ->
      new Show.ModalVisitorNotes
        model: @visitor

    qrSidebarView: ->

      qr  = App.request "new:qr"

      sidebarView = @getSidebarView(qr)
      formView = App.request "sidebar:wrapper", sidebarView

      qrsView = @getQRList(@qrs)

      @listenTo qrsView, "childview:qrs:clicked", (e) =>
        $(".chat-response").find("textarea").focus().val(e.model.get("message") + " ")

      @listenTo formView, "show", =>
        sidebarView.qrRegion.show qrsView
        @diff = 57
        App.execute "set:sidebar:modal:height"

      @listenTo sidebarView, "new:response", =>
        @showQuickResponse()

      @listenTo sidebarView, "cancel:new:response", =>
        @hideQuickResponse()

      @listenTo sidebarView, "create:new:response", =>
        quick_response = $(".new-response-text").val()
        arr = quick_response.split(" ")
        shortcut = arr[0]
        arr.splice(0,1)
        message = arr.join(" ")

        if quick_response == ""
          @showQuickResponseError("Quick response can't be blank")
          return false

        if arr.length < 1
          @showQuickResponseError("Invalid formatting. Format should be '/shortcut message'")
          return false

        if quick_response.charAt(0) != "/"
          @showQuickResponseError("Invalid formatting. Format should be '/shortcut message'")
          return false

        qr.set message: message, shortcut: shortcut
        qr.url = "/quick_responses"
        qr.type = "POST"
        qr.save {},
          success: (data) =>
            @hideQuickResponse()
            # add qrs
            new_qrs =
              message: message
              shortcut: shortcut
            @qrs.add new_qrs


      App.sidebarRegion.show formView

    getSidebarView: (qr) ->
      new Show.ModalQuickResponses
        model: qr

    getQRList: (qrs) ->
      new Show.QuickResponses
        collection: qrs

    showQuickResponse: ->
      $(".new-response-text").parent().removeClass("field-error")
      $(".response-error").addClass("hide")
      $(".new-response-form").removeClass("hide")
      $(".new-response").addClass("hide")

    hideQuickResponse: ->
      $(".new-response-text").parent().removeClass("field-error")
      $(".response-error").addClass("hide")
      $(".new-response-form").addClass("hide")
      $(".new-response").removeClass("hide")
      $(".new-response-text").val("")

    showQuickResponseError: (message) ->
      $(".new-response-text").parent().addClass("field-error")
      $(".response-error").removeClass("hide")
      $(".response-error").text(message)

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
        else if option is "ticket"
          @showCreateTicket()

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

      if message.charAt(0) is "/"
        if @qrs is ""
          @qrs = App.request "get:qrs"
          @listenTo @qrs, "when:fetched", =>
            App.reqres.setHandler "get:qrs", =>
              @qrs

      if message is ""
        @last_agent_msg = ""

      if ev.keyCode is 13 and message isnt ""

        App.execute "close:quick:responses"

        if message.charAt(0) is "/"
          res = @qrs.findWhere shortcut: message
          if res
            message = res.get("message")

        if @last_agent_msg isnt ""
          @last_agent_msg.set message: message, time: new Date(), edited: true
          @last_agent_msg = ""

          to  = "#{@visitor.get("jid")}@#{gon.chat_info.server_name}"
          msg = $msg({to: to, type: "chat", edit: true}).c('body').t($.trim(message))
          @connectionSend msg, to

        else

          @visitor.set("yours", 1)
          $(".active-warning").remove()

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
            edited:     false

          if @currentMsgs.last() and @currentMsgs.last().get("sender") is "agent"
            currentMsg.child      = true
            currentMsg.childClass = "child"

          @messages.add currentMsg

          # exec mixpanel code
          mixpanel.track("Send Message")

          archivedMessages = JSON.stringify(@messages.toJSON())
          sessionStorage.setItem("archived-messages", archivedMessages)
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
        App.execute "set:sidebar:modal:height"


    getLayout: ->
      visitor_info = @visitor.get("info")

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

    getCreateTicketView: =>
      new Show.TicketModal
        model: @currentSite

    showCreateTicket: =>
      v_info = @visitor.get("info")

      modalView = @getCreateTicketView()
      formView = App.request "modal:wrapper", modalView

      @listenTo formView, "modal:unsubmit", (e) =>
        parent = $(e.view.el)
        subject = parent.find(".ticket-subject").val()

        if subject is ""
          parent.find(".ticket-subject").closest("fieldset").addClass("field-error")
        else

          type = parent.find(".ticket-type").data("selected")
          mark = parent.find(".ticket-mark").data("selected")
          prio = parent.find(".ticket-priority").data("selected")

          description = "#{v_info.name}\n"
          if v_info.email isnt ""
            description = "#{description}#{v_info.email}\n"
          description = description = "#{description}#{v_info.OS},#{v_info.browser}\n\n############\n\n"

          conversations = ""
          agent_name = @profile.get("display_name")
          @currentMsgs.forEach (model, index) =>
            sender = if model.get("sender") isnt "agent" then model.get("sender") else agent_name
            conversations = "#{conversations}[#{model.get('timesimple')}] #{sender}: #{model.get('message')}\n"

          description = "#{description}#{conversations}"

          formView.close()
          $(".section-overlay").removeClass("hide")

          this_site = @currentSite
          this_site.url = Routes.zendesk_auth_website_path(@currentSite.get("id"))
          this_site.fetch
            type: "POST"
            data: { subject: "#{@profile.get('display_name')}: #{subject}", desc: description, type: type, prio: prio, status: mark }
            success: (e) =>
              @showNotification("Your zendesk ticket has been created.")
              $(".section-overlay").addClass("hide")
            error: (data, response) =>
              @showNotification(response.responseText, "warning")
              $(".section-overlay").addClass("hide")

      @listenTo formView, "modal:cancel", (item)->
        formView.close()

      App.modalRegion.show formView


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