@Offerchat.module "NavigationApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Controller extends App.Controllers.Base

    initialize: ->
      @connection = App.xmpp.connection

      user_json = App.request "get:current:user:json"
      user = App.request "set:current:user", user_json

      navView = @getNavView user

      @listenTo navView, "change:user:status", (elem) ->
        @changeStatus elem

      @listenTo navView, "profile:status:toggled", (child) ->
        params =
          element: child
          openClass: "profile-status"
          activeClass: false

        navView.toggleDropDown(params)

      @listenTo navView, "profile:settings:toggled", (child) ->
        params =
          element: child
          openClass: "profile-settings"
          activeClass: false

        navView.toggleDropDown(params)

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
        # params =
        #   element: child
        #   openClass: "history-menu-link"
        #   activeClass: false
        # navView.toggleDropDown(params)
        App.navigate "history", trigger: true

        # @hideDropdowns child

      @listenTo navView, "reports:menu:clicked", (child) ->
        params =
          element: child
          openClass: "reports-menu-link"
          activeClass: false
        navView.toggleDropDown(params)

      @listenTo navView, "agent:menu:clicked", (child) ->
        navView.closeDropDown()

      @listenTo navView, "settings:menu:clicked", (child) ->
        App.navigate Routes.settings_path(), trigger: true
        navView.closeDropDown()

      @listenTo navView, "upgrade:menu:clicked", (child) ->
        App.navigate Routes.plans_path(), trigger: true

      # @listenTo navView, "knowlegdebase:menu:clicked", (child) ->
      #   console.log child

      # @listenTo navView, "integrations:menu:clicked", (child) ->
      #   console.log child

      # @listenTo navView, "labs:menu:clicked", (child) ->
      #   console.log child

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
        App.request "hide:preloader"

      App.navigationRegion.show navView

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
        pres_status = $pres().c('show').t('online').up().c('priority').t('1').up().c('status').t("Online")

      @connection.send pres_status

      setTimeout (=>
        active = $msg({type: 'chat'}).c('active', {xmlns: 'http://jabber.org/protocol/chatstates'})
        @connection.send active
      ), 100



    getNavView: (user)->
      new Show.Nav
        model: user

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
