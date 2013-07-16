@Offerchat.module "SettingsApp.Style", (Style, App, Backbone, Marionette, $, _) ->
  class Style.Controller extends App.Controllers.Base

    initialize: (options) ->
      layout = @getLayoutView(options.currentSite)

      @listenTo layout, "style:color:clicked", (e) =>
        $("#controlColorContent a").removeClass("active")
        $(e.currentTarget).addClass("active")
        $("#widget-header").removeClass()
        $("#widget-header").addClass("widget-box widget-theme theme-#{$(e.currentTarget).attr('class')}").removeClass("active")

      @listenTo layout, "style:gradient:checked", (e) =>
        $(e.currentTarget).parent().parent().toggleClass("checked")
        $("#widget-header").children(":first").toggleClass("widget-gradient")


      formView = App.request "form:wrapper", layout
      layout.url = Routes.websites_path()
      @show formView

      # Get the widget's settings from the DB
      @initWidget(options.currentSite)

    initWidget: (website) ->
      console.log website
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