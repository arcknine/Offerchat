@Offerchat.module "SettingsApp.Style", (Style, App, Backbone, Marionette, $, _) ->
  class Style.Controller extends App.Controllers.Base

    initialize: (options) ->
      @currentUser = App.request "set:current:user", App.request "get:current:user:json"

      layout = @getLayoutView(options.currentSite)

      options.currentSite.url = Routes.update_settings_website_path(options.currentSite.get("id"))
      settings = options.currentSite.get("settings")

      @listenTo layout, "style:color:clicked", (e) =>
        @changeColor(e)
        klass = $(e.currentTarget).attr('class')
        settings.style.theme = $.trim(klass.replace("active",""))
        options.currentSite.set settings: settings

      @listenTo layout, "style:gradient:checked", (e) =>
        @changeGradient(e)
        if $(e.currentTarget).hasClass("checked")
          settings.style.gradient = true
          options.currentSite.set settings: settings
        else
          settings.style.gradient = false
          options.currentSite.set settings: settings

      @listenTo layout, "style:hide:footer", =>
        @hideFooter()
        settings.footer.enabled = false
        options.currentSite.set settings: settings

      @listenTo layout, "style:show:footer", =>
        @showFooter()
        settings.footer.enabled = true
        options.currentSite.set settings: settings

      @listenTo options.currentSite, "updated", (site) =>
        @showNotification("Your changes have been saved!")

      @listenTo layout, "hide:notification", =>
        $("#setting-notification").fadeOut()

      @listenTo layout, "redirect:upgrade", =>
        App.navigate Routes.plans_path(), trigger: true

      formView = App.request "form:wrapper", layout
      layout.url = Routes.websites_path()
      @show formView

      # Get the widget's settings from the DB
      @initWidget(options.currentSite)

    initWidget: (website) ->
      $("#controlColorContent a").removeClass("active")
      $("#controlColorContent a.#{website.attributes.settings.style.theme}").addClass("active")
      $("#widget-header").removeClass()
      $("#widget-header").addClass("widget-box widget-theme theme-#{website.attributes.settings.style.theme}")

      if website.attributes.settings.style.gradient
        $("#widget-header").children(":first").addClass("widget-gradient")
        $(".checkbox.inline").addClass("checked")

    getLayoutView: (website) ->
      new Style.Layout
        model: website
        user:  @currentUser
        classname: if website.get("settings").footer.enabled then "" else "no-branding"
        paid: if @currentUser.get("plan_identifier") == "FREE" then false else true

    changeColor: (e) ->
      $("#controlColorContent a").removeClass("active")
      $(e.currentTarget).addClass("active")
      $("#widget-header").removeClass()
      $("#widget-header").addClass("widget-box widget-theme theme-#{$(e.currentTarget).attr('class')}").removeClass("active")

    changeGradient: (e) ->
      $(e.currentTarget).toggleClass("checked")
      $("#widget-header").children(":first").toggleClass("widget-gradient")

    hideFooter: ->
      $(".widget-preview-sample").addClass("no-branding")

    showFooter: ->
      $(".widget-preview-sample").removeClass("no-branding")

