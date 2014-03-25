@Offerchat.module "SettingsApp.AttentionGrabbers", (AttentionGrabbers, App, Backbone, Marionette, $, _) ->

  class AttentionGrabbers.Controller extends App.Controllers.Base

    initialize: (options) ->
      profile = App.request "get:current:profile"

      App.execute "when:fetched", profile, =>

        plan = profile.get("plan_identifier")

        if ["PRO", "PROTRIAL", "AFFILIATE", "PROYEAR", "PRO6MONTHS"].indexOf(plan) isnt -1

          App.request "show:preloader"
          { @currentSite, region, section } = options
          @currentUser     = App.request "get:current:profile"
          @currentSite.url = Routes.update_settings_website_path(@currentSite.get('id'))

          App.commands.setHandler "show:notification:message", (msg, type="success") =>
            @showNotification(msg, type)

          App.commands.setHandler "save:uploaded:grabber:image", (path) =>
            @settings.grabber.name = "Uploaded Attention Grabber"
            @settings.grabber.src = path
            @settings.grabber.uploaded = true

            img = new Image()
            img.onload = =>
              @settings.grabber.width = img.width
              @settings.grabber.height = img.height
              App.request "hide:preloader"
            img.src = path

          grabbers = App.request "get:default:attention:grabbers"

          App.execute "when:fetched", @currentUser, =>
            @settings = @currentSite.get('settings')

            @layout   = @getLayout()

            App.execute "when:fetched", grabbers, =>
              if @settings.grabber.src is null or @settings.grabber.src is ""
                first_grabber = grabbers.first()
                @settings.grabber.name = first_grabber.get("name")
                @settings.grabber.src = first_grabber.get("src")
                @settings.grabber.height = first_grabber.get("height")
                @settings.grabber.width = first_grabber.get("width")

                @currentSite.set settings: @settings
                @currentSite.save()

                $(".current-attention-grabber").attr("src", first_grabber.get("src"))

            @listenTo @layout, "show", =>
              $("#attention-grabber-toggle").addClass("toggle-off") unless @settings.grabber.enabled

              App.request "hide:preloader"

            @listenTo @layout, "browse:more:grabbers", =>
              modal = @getModalView()

              @listenTo modal, "show", =>
                grabbers.forEach (model, index) ->
                  src = model.get("src")
                  name = model.get("name")
                  w = model.get("width")
                  h = model.get("height")
                  gr = "<a class='ag-select' data-width='#{w}' data-height='#{h}'><img src='#{src}' alt='#{name}' /></a>"
                  $(".attention-grabber-container").append(gr)

              @listenTo modal, "set:attention:grabber", =>
                selected = $(".attention-grabber-container").find(".selected")
                grabber_width = selected.data("width")
                grabber_height = selected.data("height")
                grabber_src = selected.find("img").attr("src")
                grabber_name = selected.find("img").attr("alt")

                @settings.grabber.width = grabber_width
                @settings.grabber.height = grabber_height
                @settings.grabber.src = grabber_src
                @settings.grabber.name = grabber_name
                @settings.grabber.uploaded = false

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
                  @showNotification("Your changes have been saved.")

            $(window).resize =>
              h = $(window).height() - 45
              $(".main-content-view").attr("style","height:#{h}px")

            @show @layout

        else
          App.navigate Routes.root_path(), trigger: true


    getLayout: ->
      new AttentionGrabbers.Layout
        model: @currentSite

    getModalView: ->
      new AttentionGrabbers.Modal
        model: @currentSite

