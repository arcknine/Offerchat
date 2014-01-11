@Offerchat.module "NavigationApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Controller extends App.Controllers.Base

    initialize: ->
      @connection = App.xmpp.connection

      user_json = App.request "get:current:user:json"
      user = App.request "set:current:user", user_json
      @profile = App.request "get:current:profile"

      App.execute "when:fetched", user, =>
        App.execute "when:fetched", @profile, =>
          trial = @profile.get("plan_identifier") == "PREMIUM" ? true : false
          pro   = @profile.get("plan_identifier") == "PROTRIAL" ? true : false
          @profile.set trial: trial, pro: pro, status: user.get("status")

          App.commands.setHandler "plan:changed", (new_plan) =>
            pro = if new_plan isnt "PROTRIAL" then false else true
            @profile.set { plan_identifier: new_plan, pro: pro }

        navView = @getNavView @profile

        @listenTo navView, "change:user:status", (elem) ->
          @changeStatus elem

        @listenTo navView, "profile:status:toggled", (child) ->
          @toggleActiveMenu(navView, child, "profile-status")

        @listenTo navView, "responses:menu:clicked", (child) ->
          @toggleActiveMenu(navView, child, "responses-menu-link")
          App.navigate "quick-responses", trigger: true

        @listenTo navView, "root:path:clicked", (child) ->
          App.navigate Routes.root_path(), trigger: true
          navView.closeDropDown()

        @listenTo navView, "account:menu:clicked", (child) ->
          App.navigate Routes.profiles_path(), trigger: true
          navView.closeDropDown()

        @listenTo navView, "websites:menu:clicked", (child) ->
          App.navigate Routes.websites_path(), trigger: true
          navView.closeDropDown()

        @listenTo navView, "agent:menu:clicked", (child) ->
          App.navigate Routes.agents_path(), trigger: true
          @hideDropdowns child

        @listenTo navView, "history:menu:clicked", (child) ->
          @toggleActiveMenu(navView, child, "history-menu-link")
          App.navigate "history", trigger: true

        @listenTo navView, "reports:menu:clicked", (child) ->
          @toggleActiveMenu(navView, child, "reports-menu-link")
          App.navigate "reports", trigger: true

        @listenTo navView, "agent:menu:clicked", (child) ->
          navView.closeDropDown()

        @listenTo navView, "settings:menu:clicked", (child) ->
          App.navigate Routes.settings_path(), trigger: true
          navView.closeDropDown()

        @listenTo navView, "upgrade:menu:clicked", (child) ->
          # App.navigate Routes.plans_path(), trigger: true
          App.navigate "upgrade", trigger: true
          navView.closeDropDown()

        @listenTo navView, "show", ->
          @initPreLoader()

          App.reqres.setHandler "show:preloader", ->
            $("#canvas-loader").show()
            NProgress.start()

          App.reqres.setHandler "hide:preloader", ->
            $("#canvas-loader").hide()
            NProgress.done()

        App.commands.setHandler "avatar:change", (avatar) ->
          user.set avatar: avatar
          $(".profile-image").find("img").attr("src", avatar)
          App.request "hide:preloader"

        App.navigationRegion.show navView

    toggleActiveMenu: (view, elem, class_elem) ->
      params =
        element: elem
        openClass: class_elem
        activeClass: false
      view.toggleDropDown(params)

    changeStatus: (elem) ->
      status_elem = $(elem.currentTarget).find("#current-status")
      status = $.trim(status_elem.text())

      if status is "Away"
        status_elem.text("Online")
        $(elem.currentTarget).find(".status").addClass("online")
        $(".profile-status > a").find(".status").removeClass("online")
        pres_status = $pres().c('show').t('away').up().c('priority').t('0').up().c('status').t("I'm away from my desk")
      else
        status_elem.text("Away")
        $(elem.currentTarget).find(".status").removeClass("online")
        $(".profile-status > a").find(".status").addClass("online")
        pres_status = $pres().c('priority').t('1').up().c('status').t("Online")

      @connection.send pres_status

      setTimeout (=>
        active = $msg({type: 'chat'}).c('active', {xmlns: 'http://jabber.org/protocol/chatstates'})
        @connection.send active
      ), 100

    getNavView: (profile)->
      new Show.Nav
        model: profile

    hideDropdowns: (child) ->
      childViews = $(child.view.el)
      dropdowns  = childViews.find(".dropdowns")

      $.each dropdowns, (key, value) ->
        unless $(value).hasClass("hide")
          $(value).addClass("hide")
          $(value).prev().removeClass("active")

    initPreLoader: ->
      # load loader js
      cl = new CanvasLoader("canvas-loader")
      cl.setColor "#ebebeb"
      cl.setDiameter 19
      cl.setRange 0.8
      cl.setFPS 30
      cl.show()

      loaderObj = document.getElementById("canvasLoader")
      loaderObj.style.position = "absolute"