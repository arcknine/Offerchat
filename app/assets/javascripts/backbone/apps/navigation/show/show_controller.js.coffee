@Offerchat.module "NavigationApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Controller extends App.Controllers.Base

    initialize: ->
      user_json = App.request "get:current:user:json"
      user = App.request "set:current:user", user_json

      navView = @getNavView user

      @listenTo navView, "profile:status:toggled", (child) ->
        @toggleDropdowns(child, ".profile-status-dropdown")
        @toggleActive(child, "#profile-status-toggle")

      @listenTo navView, "profile:settings:toggled", (child) ->
        @toggleDropdowns(child, ".settings-dropdown")
        @toggleActive(child, "#settings-dropdown-toggle")

      @listenTo navView, "root:path:clicked", (child) ->
        App.navigate Routes.root_path(), trigger: true
        @hideDropdowns child

      @listenTo navView, "account:menu:clicked", (child) ->
        App.navigate Routes.profiles_path(), trigger: true
        @hideDropdowns child

      @listenTo navView, "websites:menu:clicked", (child) ->
        App.navigate Routes.websites_path(), trigger: true
        @hideDropdowns child

      @listenTo navView, "history:menu:clicked", (child) ->
        @hideDropdowns child

      @listenTo navView, "agent:menu:clicked", (child) ->
        @hideDropdowns child

      # @listenTo navView, "knowlegdebase:menu:clicked", (child) ->
      #   console.log child

      # @listenTo navView, "integrations:menu:clicked", (child) ->
      #   console.log child

      # @listenTo navView, "labs:menu:clicked", (child) ->
      #   console.log child



      App.navigationRegion.show navView

    getNavView: (user)->
      new Show.Nav
        model: user

    toggleDropdowns: (child, className)->
      childViews = $(child.view.el)
      dropdowns = childViews.find(".dropdowns")

      dropdown = childViews.find(className)

      if dropdown.hasClass("hide")
        dropdowns.addClass("hide")
        dropdown.removeClass("hide")
      else
        dropdowns.addClass("hide")
        dropdown.addClass("hide")

    toggleActive: (child, id) ->
      childViews = $(child.view.el)
      anchorTags = childViews.find(".header-inline-list.primary-user-nav > li > a")

      unless $(id).hasClass("active")
        anchorTags.removeClass("active")
        $(id).addClass("active")
      else
        $(id).removeClass("active")

    hideDropdowns: (child) ->
      childViews = $(child.view.el)
      dropdowns  = childViews.find(".dropdowns")

      $.each dropdowns, (key, value) ->
        unless $(value).hasClass("hide")
          $(value).addClass("hide")
          $(value).prev().removeClass("active")