@Offerchat.module "HistoryApp.Conversations", (Conversations, App, Backbone, Marionette, $, _) ->

  class Conversations.Layout extends App.Views.Layout
    template: "history/conversation/layout"
    className: "main-inner"
    regions:
      headerRegion:         "#history-header-region"
      filterRegion:         "#history-filter-region"
      conversationsRegion:  "#history-conversation-region"

  class Conversations.Agent extends App.Views.ItemView
    template: "history/conversation/agent"
    tagName: "li"
    triggers:
      "click":              "agent:filter:selected"

  class Conversations.Agents extends App.Views.CollectionView
    template: "history/conversation/agents"
    itemView: Conversations.Agent
    tagName: "ul"

  class Conversations.Header extends App.Views.CompositeView
    template: "history/conversation/header"

    triggers:
      "click .trash-btn"    : "remove:conversations:clicked"

    events:
      "click .calendar-picker-btn" : "toggle_date_picker"
      "click #apply-date"          : "filter_conversations"
      "click .date-today"          : "set_date_today"
      "click .date-this-week"      : "set_date_this_week"
      "click .date-this-month"     : "set_date_this_month"
      "click #close-datepicker"    : "toggle_date_picker"

    filter_conversations: ->
      App.execute "filter:conversations", @get_dates()

    get_dates: ->
      $('#historyDate').DatePickerGetDate(true)

    set_date_today: ->
      $('#historyDate').DatePickerSetDate(moment(new Date).format("YYYY-MM-DD"))

    set_date_this_week: ->
      today = new Date
      d = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay())
      $('#historyDate').DatePickerSetDate([moment(d).format("YYYY-MM-DD"),new Date])

    set_date_this_month: ->
      today = new Date
      d = new Date(today.getFullYear(), today.getMonth(), 1)
      $('#historyDate').DatePickerSetDate([d,moment(new Date).format("YYYY-MM-DD")])

    render_date_picker: ->
      d = new Date()
      $('#historyDate').html('').children().off()
      $('#historyDate').DatePicker
        flat: true,
        date: moment(d).format("YYYY-MM-DD")
        current: moment(d).format("YYYY-MM-DD")
        calendars: 3
        mode: 'range'
        starts: 1
      @

    toggle_date_picker: ->
      @render_date_picker()
      $(".history-date-wrapper").toggleClass("hide")

  class Conversations.Filter extends App.Views.Layout
    template: "history/conversation/filter"
    className: "table-row table-head shadow group"
    regions:
      agentsFilterRegion:   "#agents-filter-region"

    events:
      "click #checkboxGradient"   : "select_conversations"

    select_conversations: (evt)->
      evt.stopPropagation()
      evt.preventDefault()
      checkbox = @$("label.checkbox")
      if checkbox.hasClass("checked")
        $(".table-row").removeAttr("data-checked")
        $("label.checkbox").removeClass("checked")
      else
        $("label.checkbox").addClass("checked")
        $(".table-row").attr("data-checked", true)

    triggers:
      "click .agent-row-selector" : "agents:filter:clicked"

    serializeData: ->
      agents_count: @collection.length > 1
      agent: @collection.at(0).get("name")


  class Conversations.Item extends App.Views.ItemView
    template: "history/conversation/conversation"
    className: "table-row linkable group"

    remove: ->
      @$el.remove()

    modelEvents:
      "change" : "render"
      "destroy": "remove"

    events:
      "click"                 : "open_conversation"
      "click label.checkbox"  : "select_conversation"
    render: ->
      @$el.attr("data-id", @model.get("_id"))
      super()

    select_conversation: (evt)->
      evt.stopPropagation()
      evt.preventDefault()
      checkbox = $(evt.target).closest("label.checkbox")
      if checkbox.hasClass("checked")
        checkbox.removeClass("checked")
        $("label#checkboxGradient").removeClass("checked")
        $("label#checkboxGradient").closest(".table-row").removeAttr("data-checked")
        $(evt.target).closest(".table-row").removeAttr("data-id")
        $(evt.target).closest(".table-row").removeAttr("data-checked")
      else
        checkbox.addClass("checked")
        $(evt.target).closest(".table-row").attr("data-id", @model.get("_id"))
        $(evt.target).closest(".table-row").attr("data-checked", true)

    open_conversation: (evt)->
      console.log evt
      App.execute "open:conversation:modal", @model

    initialize: ->
      m = @model.get("updated_at")
      #@model.set momentary: moment(m, '"YYYY-MM-DDTHH:mm:ss Z"').fromNow()
      @model.set momentary: moment(m).format("hh:mma")
      #model = @model
      # setInterval ->
      #   model.set momentary: moment(m, '"YYYY-MM-DDTHH:mm:ss Z"').fromNow()
      # , 3000

  class Conversations.GroupItem extends App.Views.CompositeView
    template: "history/conversation/group_item"
    itemView: Conversations.Item
    modelEvents:
      "change" : "render"
    initialize: ->
      momentary = @model.get("created")
      @model.set momentary: moment(@model.get("created")).format("MMMM DD, YYYY")
      @collection = App.request "new:conversations:entitites", @model.get("conversations")
    appendHtml: (collectionView, itemView)->
      collectionView.$(".table-row-wrapper").append(itemView.el)

  class Conversations.EmptyView extends App.Views.ItemView
    template: "history/conversation/empty"

  class Conversations.Groups extends App.Views.CollectionView
    template: "history/conversation/groups"
    itemView: Conversations.GroupItem
    emptyView: Conversations.EmptyView
    className: "table-history-viewer-content"
    id: "historyTableViewer"

    App.commands.setHandler "bounce:element", (element) ->
      element.animate({ marginTop: '-=' + '5px'}, 50 ).animate({ marginTop: '+=' + '5px' }, 50)

    onShow: ->
      console.log 'height: ', $(window).height()
      $(".main-content-view").css('overflow-y','hidden')
      w_height = $(window).height() - 203
      $("#historyTableViewer").css('height', w_height + 'px')
      $(".history-table-heading").first().removeClass("relative").addClass("fixed")

      lastScrollTop = 0
      $(".table-history-viewer-content").scroll (event) ->
        currentScrollTop = $(this).scrollTop()
        if currentScrollTop > lastScrollTop
          $(".history-table-heading").each ->
            if $(this).hasClass("fixed")
              _next_header = $(this).parent("div").next("div").find(".history-table-heading")
              if $(_next_header).length > 0
                if ($(this).offset().top + $(this).height()) >= $(_next_header).offset().top
                  App.execute "bounce:element", _next_header
                  $(this).removeClass("fixed").addClass "relative"
                  $(_next_header).removeClass("relative").addClass "fixed"
        else
          $(".history-table-heading").each ->
            if $(this).hasClass("fixed")
              _prev_header = $(this).parent("div").prev("div").find(".history-table-heading")
              if $(_prev_header).length > 0
                if $(this).offset().top <= ($("#" + $(_prev_header).attr("id") + "_content").offset().top + $(this).height())
                  App.execute "bounce:element", _prev_header
                  $(this).removeClass("fixed").addClass "relative"
                  $(_prev_header).removeClass("relative").addClass "fixed"

        lastScrollTop = currentScrollTop

  class Conversations.ChatsModalRegion extends App.Views.Layout
    template: "history/conversation/chats_modal"
    regions:
      headerRegion:   "#chat-modal-header-region"
      bodyRegion:     "#chat-modal-body-region"
      footerRegion:   "#chat-modal-footer-region"
    triggers:
      "click a.close" : "close:chats:modal"
      "click div.close-modal-backdrop" : "close:chats:modal"

  class Conversations.ChatModalHeader extends App.Views.ItemView
    template: "history/conversation/chats_modal_header"

  class Conversations.ChatMessage extends App.Views.ItemView
    template: "history/conversation/chat_message"
    modelEvents:
      "change" : "render"
    initialize: ->
      momentary = @model.get("sent")
      @model.set sent: moment(@model.get("sent")).format("hh:mma")

  class Conversations.Chats extends App.Views.CompositeView
    template: "history/conversation/chat_messages"
    itemView: Conversations.ChatMessage

  class Conversations.ChatModalFooter extends App.Views.ItemView
    template: "history/conversation/chat_modal_footer"
    events:
      "click #forwardToEmailBtn"        : "show_forward_email"
      "click #cancelTranscriptFormBtn"  : "hide_forward_email"
      "click .forward-to-email-btn"     : "forward_convo_to_email"
      "click .delete-conversation"      : "delete_convo"
      "click #downloadTranscript"       : "download_transcript"

    download_transcript: (evt)->
      evt.preventDefault()
      window.location.href = "#{gon.history_url}/transcript/agent/#{@model.get('token')}"

    show_forward_email: (evt)->
      @$(".transcript-email-form").removeClass("hide")
      @$(".transcript-actions").addClass("hide")

    hide_forward_email: (evt)->
      @$(".transcript-email-form").addClass("hide")
      @$(".transcript-actions").removeClass("hide")

    forward_convo_to_email: (evt)->
      console.log "Process forwarding to email here"
      console.log @$(".forwarding-recipient").val()

    delete_convo: (evt)->
      r = confirm "Are you sure you want to delete this conversation?"
      if r is true
        self = @
        conversations = @collection
        ids = [@model.get("_id")]
        self.trigger "close:chats:modal"
        $.ajax
          url: "#{gon.history_url}/convo/remove"
          data: {ids: ids}
          dataType : "jsonp"
          processData: true
          success: ->
            self.trigger "close:chats:modal"
            self.model.destroy()