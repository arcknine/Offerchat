@Offerchat.module "SettingsApp.AttentionGrabbers", (AttentionGrabbers, App, Backbone, Marionette, $, _) ->

  class AttentionGrabbers.Controller extends App.Controllers.Base

    initialize: (options) ->
      { @currentSite, region, section } = options
      @currentUser     = App.request "get:current:profile"
      @currentSite.url = Routes.update_settings_website_path(@currentSite.get('id'))

      grabbers = App.request "get:default:attention:grabbers"

      App.execute "when:fetched", @currentUser, =>
        @settings = @currentSite.get('settings')

        @layout   = @getLayout()

        @listenTo @layout, "show", =>
          $("#attention-grabber-toggle").addClass("toggle-off") unless @settings.grabber.enabled

        @listenTo @layout, "browse:more:grabbers", =>
          modal = @getModalView()

          @listenTo modal, "show", =>
            grabbers.forEach (model, index) ->
              src = '//' + model.get("src")
              name = model.get("name")
              w = model.get("width")
              h = model.get("height")
              gr = "<a class='ag-select' data-width='#{w}' data-height='#{h}'><img src='#{src}' alt='#{name}' /></a>"
              $(".attention-grabber-container").append(gr)

          @listenTo modal, "set:attention:grabber", =>
            selected = $(".attention-grabber-container").find(".active")
            grabber_width = selected.data("width")
            grabber_height = selected.data("height")
            grabber_src = selected.find("img").attr("src")
            grabber_name = selected.find("img").attr("alt")

            @settings.grabber.width = grabber_width
            @settings.grabber.height = grabber_height
            @settings.grabber.src = grabber_src
            @settings.grabber.name = grabber_name

            $(".current-attention-grabber").attr("src", grabber_src)


          App.modalRegion.show modal

        @listenTo @layout, "save:attention:grabber", =>
          enabled = true
          if $("#attention-grabber-toggle").hasClass("toggle-off")
            enabled = false

          @settings.grabber.enabled = enabled
          @currentSite.set settings: @settings
          @currentSite.save {},
            success: (data) =>
              @showNotification("Your changes have been saved!")

        @show @layout


    getLayout: ->
      new AttentionGrabbers.Layout
        model: @currentSite

    getModalView: ->
      new AttentionGrabbers.Modal
        model: @currentSite

