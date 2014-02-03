@Offerchat.module "SettingsApp.AttentionGrabbers", (AttentionGrabbers, App, Backbone, Marionette, $, _) ->

  class AttentionGrabbers.Layout extends App.Views.Layout
    template:  "settings/attention_grabbers/layout"
    className: "column-content-container"

    triggers:
      "click .save-attention-grabber" : "save:attention:grabber"
      "click .browse-more"            : "browse:more:grabbers"

    events:
      "click #attention-grabber-toggle" :  "toggleAttentionGrabber"

    toggleAttentionGrabber: (e) ->
      target = $(e.currentTarget)
      if target.hasClass("toggle-off")
        target.removeClass("toggle-off")
      else
        target.addClass("toggle-off")

    serializeData: ->
      settings = @options.model.get("settings")
      grabber_src: settings.grabber.src
      grabber_name: settings.grabber.name

    onShow: ->
      site_id = @options.model.get("id")
      self = @
      @$el.fileupload
        url: Routes.update_attention_grabber_website_path(site_id)
        formData: {authenticity_token: App.request("csrf-token")}
        add: (e, data) ->
          file_too_large_error = "File size is too large."
          types = /(\.|\/)(jpe?g|png)$/i
          file = data.files[0]
          $(".section-overlay").removeClass("hide")
          if file.size < 1000000
            if types.test(file.type) || types.test(file.name)
              data.submit().done( (e, data) ->
                $(".current-attention-grabber").attr("src", e.attention_grabber)
                App.execute "save:uploaded:grabber:image", e.attention_grabber
                $(".section-overlay").addClass("hide")
              ).fail (jqXHR, textStatus, errorThrown)->
                App.execute "show:notification:message", "Something went wrong while trying to upload your file. Please try again later.", "warning"
                $(".section-overlay").addClass("hide")
            else
              App.execute "show:notification:message", "#{file.name} is not a jpeg, or png image file", "warning"
              $(".section-overlay").addClass("hide")

          else
            App.execute "show:notification:message", file_too_large_error, "warning"
            $(".section-overlay").addClass("hide")

  class AttentionGrabbers.Modal extends App.Views.ItemView
    template: "settings/attention_grabbers/modal"
    className: "modal-backdrop"

    events:
      "click a.close" : "closeModal"
      "click a.ag-select" : "selectGrabber"
      "click .cancel-set-attention-grabber" : "closeModal"
      "click .set-attention-grabber"  : "setGrabber"

    closeModal: ->
      $(".modal-backdrop").remove()

    selectGrabber: (e) ->
      $(".ag-select").removeClass("selected")
      $(e.currentTarget).addClass("selected")

    setGrabber: ->
      @trigger "set:attention:grabber"
      @closeModal()