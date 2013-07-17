@Offerchat.module "SettingsApp.Style", (Style, App, Backbone, Marionette, $, _) ->
  class Style.Controller extends App.Controllers.Base

    initialize: (options) ->
      layout = @getLayoutView(options.currentSite)

      options.currentSite.url = Routes.update_settings_website_path(options.currentSite.get("id"))
      settings = options.currentSite.get("settings")

      @listenTo layout, "style:color:clicked", (e) =>
        @changeColor(e)
        settings.style.theme = $(e.currentTarget).removeClass("active").attr('class')
        options.currentSite.set settings: settings

      @listenTo layout, "style:gradient:checked", (e) =>
        @changeGradient(e)
        if $(e.currentTarget).parent().parent().hasClass("checked")
          settings.style.gradient = true
          options.currentSite.set settings: settings
        else
          settings.style.gradient = false
          options.currentSite.set settings: settings

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

    changeColor: (e) ->
      $("#controlColorContent a").removeClass("active")
      $(e.currentTarget).addClass("active")
      $("#widget-header").removeClass()
      $("#widget-header").addClass("widget-box widget-theme theme-#{$(e.currentTarget).attr('class')}").removeClass("active")

    changeGradient: (e) ->
      $(e.currentTarget).parent().parent().toggleClass("checked")
      $("#widget-header").children(":first").toggleClass("widget-gradient")
