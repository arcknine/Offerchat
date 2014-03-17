@Offerchat.module "HistoryApp.Conversations", (Conversations, App, Backbone, Marionette, $, _) ->

  class Conversations.Controller extends App.Controllers.Base

    initialize: ->

      App.request "show:preloader"

      @curDate     = App.request "reports:current:date"

      App.execute "when:fetched", @curDate, =>
        @curDate.set type: "week"

      currentUser = App.request "get:current:user"

      App.execute "when:fetched", currentUser, =>
        plan = currentUser.get("plan_identifier")
        if plan is null or plan is "" or plan is "BASIC" or plan is "BASICYEAR"
          App.navigate "/", trigger: true
        else

          sites = App.request "site:entities"

          App.execute "when:fetched", sites, =>
            @wids = sites.pluck("id")
            all_sites = App.request "new:selector:site"
            all_sites.set name: "All Websites"
            sites.unshift(all_sites)

          @layout = @getLayout()
          agents = App.request "agents:entities", false

          self = @

          @listenTo @layout.conversationsRegion, "show", =>
            App.request "hide:preloader"


          App.execute "when:fetched", agents, (item)=>
            if agents.length > 1
              all_agent = App.request "new:agent:entity"
              all_agent.set name: "All Agents"
              agents.unshift(all_agent)

            @aids = agents.pluck("id")
            @date_scope = ""

            conversations = App.request "get:conversations:entitites", null, @aids, @wids

            App.commands.setHandler "get:conversations", (aids, page, wids) =>

              @aids = aids
              @wids = wids

              $(".section-overlay").removeClass("hide")
              conversations.fetch
                data: {aids: aids, wids: @wids, page: page, scope: @date_scope}
                dataType : "jsonp"
                processData: true
                reset: true
                success: =>
                  count = conversations.pop()
                  @total_entries = count.get("total_entries")

                  convos = self.organizeConversations(conversations)
                  self.layout.conversationsRegion.show self.getConversationsRegion(convos)

                  if conversations.length < 100 then $(".nav-link-inline").data("last", true) else $(".nav-link-inline").data("last", false)

                  if conversations.length is 0
                    frm_count = 0
                    to_count = 0
                  else
                    frm_count = (page * 100) - 99
                    to_count = (((page * 100) - 100) + conversations.length)

                  $(".history-scope").html("#{frm_count} - #{to_count} of #{@total_entries}")
                  $(".section-overlay").addClass("hide")

            App.commands.setHandler "conversations:fetch", (aids)=>
              $(".nav-link-inline").data("page", 1)
              App.execute "get:conversations", aids, 1, @wids

            App.execute "when:fetched", conversations, (item)=>

              App.commands.setHandler "filter:conversations", (date) =>

                $(".history-date-wrapper").toggleClass("hide")

                type = $('#historyDate').data("type")
                from   = moment(date[0]).format("MMM D, YYYY")
                to     = moment(date[1]).format("MMM D, YYYY")
                arType = { today: "Today", week: "This week", month: "This month",  custom: "#{from}  -  #{to}"}
                $(".calendar-scope").html(arType[type])

                @curDate.set
                  type: type
                  from: date[0]
                  to: date[1]

                @date_scope = date
                App.execute "get:conversations", @aids, 1, @wids


              @listenTo @layout, "show", =>
                count = conversations.pop()
                @total_entries = count.get("total_entries")

                @changeOnResize()

                convos = @organizeConversations(conversations)
                headerRegion = @getHeaderRegion(conversations)
                ids = []
                items = []

                @listenTo headerRegion, "show", =>
                  headerRegion.websitesRegion.show @getWebsitesFilter(sites)

                @listenTo headerRegion, "calendar:clicked", =>
                  if $(".history-date-wrapper").hasClass("hide")
                    @calendarClicked()

                  $(".history-date-wrapper").toggleClass("hide")

                @listenTo headerRegion, "remove:conversations:clicked", (item)->
                  r = confirm "Are you sure you want to delete the selected conversations?"
                  if r is true
                    _.each $(".table-row[data-checked='true']"), (item)->
                      ids.push $(item).data("id")

                    $.ajax
                      url: "#{gon.history_url}/convo/remove"
                      data: {ids: ids}
                      dataType : "jsonp"
                      processData: true
                      success: ->
                        conversations.each (item)->
                          if ($.inArray(item.get("_id"), ids) isnt -1)
                            item.trigger "destroy"
                      error: ->
                        App.request "hide:preloader"


                filter_view = @getFilterRegion(agents)

                @listenTo filter_view, "show", =>
                  $(".nav-link-inline").data("last", true) if conversations.length < 100
                  to_count = conversations.length
                  $(".history-scope").html("1 - #{to_count} of #{@total_entries}")

                @listenTo filter_view, "change:page:history", (page) =>
                  App.execute "get:conversations", @aids, page, @wids

                @layout.headerRegion.show headerRegion
                @layout.filterRegion.show filter_view
                @layout.conversationsRegion.show @getConversationsRegion(convos)
              @show @layout

            App.commands.setHandler "open:conversation:modal", (item)=>
              @getConversationModal(item)

        App.request "hide:preloader"

    getWebsitesFilter: (websites) =>
      website_filters_view = new Conversations.Websites
        collection: websites

      @listenTo website_filters_view, "childview:website:filter:selected", (item) =>
        btn_selector = $(item.el).closest(".btn-selector")
        btn_selector.find("span.current-selection").html(item.model.get("name"))
        btn_selector.removeClass("open").find(".active").removeClass("active")

        if item.model.get("name") is "All Websites"
          wids = websites.pluck("id")
        else
          wids = item.model.get("id")

        App.execute "get:conversations", @aids, 1, wids

      website_filters_view

    calendarClicked: =>
      current = moment().format("YYYY-MM-DD")
      $('#historyDate').html('').children().off()

      $(".current-scope").removeClass("active")

      switch @curDate.get("type")
        when "today"
          $(".date-today").addClass("active")
        when "week"
          $(".date-this-week").addClass("active")
        when "month"
          $(".date-this-week").addClass("active")
        else
          $(".current-scope").removeClass("active")


      $("#historyDate").DatePicker
        flat: true
        date: [@curDate.get("from"), @curDate.get("to")]
        current: current
        calendars: 3
        mode: "range"
        starts: 1
        onChange: (formated, dates) =>
          $(".current-scope").removeClass("active")
          $('#historyDate').data("type","custom")


    changeOnResize: ->
      $(window).resize =>
        h = $(window).height() - 246
        $(".table-history-viewer-content").attr("style","height:#{h}px")

    getLayout: ->
      new Conversations.Layout

    getConversationModal: (model)->
      visitor = App.request "get:visitor:info:entity", model.get("vid")
      messages = App.request "messeges:entities"

      visitor.generateGravatarSource()

      modalViewRegion = new Conversations.ChatsModalRegion
        model: model

      App.execute "when:fetched", visitor, (item) =>

        website_id = visitor.get("website_id")
        is_agent = App.request "is:current:user:agent", website_id

        modalRegionHeader = new Conversations.ChatModalHeader
          model: visitor

        modalViewRegion.headerRegion.show modalRegionHeader

        modalRegionBody = new Conversations.Chats
          collection: messages

        messages.url = "#{gon.history_url}/chats/#{model.get('token')}"
        messages.fetch
          dataType : "jsonp"
          processData: true
          reset: true

        modalViewRegion.bodyRegion.show modalRegionBody

        modalRegionFooter = new Conversations.ChatModalFooter
          model: model
          is_agent: is_agent

        @listenTo modalRegionFooter, "close:chats:modal", ->
          modalViewRegion.close()

        modalViewRegion.footerRegion.show modalRegionFooter

      @listenTo modalViewRegion, "close:chats:modal", ->
        modalViewRegion.close()

      App.modalRegion.show modalViewRegion

    getHeaderRegion: (conversations)->
      new Conversations.Header
        conversations: conversations

    getFilterView: (collection)->
      new Conversations.Filter
        collection: collection

    getFilterRegion: (collection)->
      filterView = @getFilterView(collection)

      @listenTo filterView, "show", =>
        filterView.agentsFilterRegion.show @getAgentFilters(collection)

      filterView

    getAgentFilters: (collection)->
      filters = new Conversations.Agents
        collection: collection

      @listenTo filters, "childview:agent:filter:selected", (item)->
        id = []
        if item.model.get("name") is "All Agents"
          collection.each (item)->
            id.push item.get("id")
        else
          id = [item.model.get("id")]

        App.execute "conversations:fetch", id
        btn_selector = $(item.el).closest(".btn-selector")
        btn_selector.find("span.current-selection").html(item.model.get("name"))
        btn_selector.removeClass("open").find(".active").removeClass("active")

      filters

    getConversationsRegion: (collection)->
      new Conversations.Groups
        collection: collection

    organizeConversations: (collection)->
      timestamps = _.uniq collection.pluck("created")
      convos = App.request "new:converstationgroups:entities"
      _.each timestamps, (item, i)->
        convos.add conversations: collection.where({created: item}), created: item, id: i
      convos