@Offerchat.module "ResponsesApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.Controller extends App.Controllers.Base

    initialize: ->
      @layout = @getLayoutView()

      App.request "show:preloader"

      @listenTo @layout, "show", =>
        App.execute "set:window:height"

        $(window).resize =>
          App.execute "set:window:height"

        @showQuickResponses()

        App.request "hide:preloader"

      @qrs = App.request "get:qrs"
      App.execute "when:fetched", @qrs, =>
        App.reqres.setHandler "get:qrs", =>
          @qrs

        App.commands.setHandler "set:window:height", =>
          win_height = $(window).height() - 163
          $(".responses-content").attr("style","height:#{win_height}px")

        App.mainRegion.show @layout

    cleanError: (elem) ->
      elem.parent("fieldset").removeClass("field-error").find(".block-text-message").remove()

    showError: (elem, err_msg) ->
      err = "<div class='block-text-message'>#{err_msg}</div>"
      elem.parent("fieldset").addClass("field-error").append(err)

    checkValidQR: (content, elem) ->
      arr = content.split(" ")
      shortcut = arr[0]
      arr.splice(0,1)
      message = arr.join(" ")

      @cleanError elem

      if content is ""
        @showError elem, "You cant leave this blank."
        return false

      if arr.length < 1 or content.charAt(0) isnt "/" or shortcut.length <= 1
        @showError elem, "Invalid formatting. Format should be '/shortcut message'"
        return false

      true

    showQuickResponses: ->
      qrView = @getQRView()

      @listenTo qrView, "childview:remove:qr:clicked", (e) =>
        if confirm("Are you sure you want to delete this quick response?")
          e.model.destroy()

      @listenTo qrView, "childview:edit:save:quick:response", (e) =>
        textarea = $(e.el).find(".edit-qr-textarea")
        content = textarea.val()

        if @checkValidQR(content, textarea)
          arr = content.split(" ")
          shortcut = arr[0]
          arr.splice(0,1)
          message = arr.join(" ")

          qr = e.model
          qr.set
            message: message
            shortcut: shortcut
          qr.save()

      @listenTo @layout, "delete:selected:qrs", (e) =>
        if confirm("Are you sure you want to delete the selected quick responses?")
          $.each $(".checked"), (key, value) =>
            qr = @qrs.findWhere id: parseInt($(value).attr("qid"))
            qr.destroy()

          App.execute "set:window:height"

      @listenTo @layout, "cancel:new:qr", (e) ->
        $(".new-qr-actions").removeClass("hide")
        $(".new-qr-form").addClass("hide")
        $(".new-qr-text").val("")

      @listenTo @layout, "save:new:qr", (e) ->
        qr  = App.request "new:qr"

        frm = $(e.currentTarget).parents(".new-qr-form")
        qr_elem = frm.find(".new-qr-text")
        qr_text = qr_elem.val()

        if @checkValidQR(qr_text, qr_elem)
          arr = qr_text.split(" ")
          shortcut = arr[0]
          arr.splice(0,1)
          message = arr.join(" ")

          qr.set message: message, shortcut: shortcut
          qr.url = "/quick_responses"
          qr.type = "POST"
          qr.save {},
            success: (data) =>
              new_qrs =
                id: data.get("id")
                message: message
                shortcut: shortcut
              @qrs.add new_qrs
              App.execute "set:window:height"

          @layout.trigger "cancel:new:qr"

      @layout.qrRegion.show qrView

    getQRView: ->
      new List.QuickResponses
        collection: @qrs

    getLayoutView: ->
      new List.Layout
