@Offerchat.module "ResponsesApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.Layout extends App.Views.Layout
    template: "responses/list/layout"
    regions:
      qrRegion: "#quick-responses"

    triggers:
      "click .cancel-new-qr"  : "cancel:new:qr"

    events:
      "click .new-qr"     : "showNewQRForm"
      "click .save-qr"  : "saveNewQR"

    saveNewQR: (e) ->
      @trigger "save:new:qr", e

    showNewQRForm: (e) ->
      $(e.target).closest(".new-qr-actions").addClass("hide")
      $(".new-qr-form").removeClass("hide")

  class List.QuickResponse extends App.Views.ItemView
    template: "responses/list/quick_response"

    triggers:
      "click button.save-edit-qr"    : "edit:save:quick:response"
      "click .remove-qr"            : "remove:qr:clicked"

    events:
      "click label.checkbox"  : "toggleCheckbox"
      "click .qr-item"      : "qrClicked"
      "click .cancel-edit-qr"  : "cancelEdit"

    cancelEdit: (e) ->
      $(e.target).closest("div.edit-qr").addClass("hide")

    qrClicked: (e) ->
      target = $(e.target)
      if !target.hasClass("icon-check")
        qr_item = target.closest("div.qr-item").next(".edit-qr")
        if qr_item.hasClass("hide")
          $(".edit-qr").addClass "hide"
          qr_item.removeClass "hide"
        else
          qr_item.addClass "hide"

    toggleCheckbox: (e) ->
      target = $(e.currentTarget)
      if target.hasClass("checked")
        target.removeClass("checked")
      else
        target.addClass("checked")

  class List.QuickResponses extends App.Views.CompositeView
    template: "responses/list/quick_responses"
    itemView: List.QuickResponse

    collectionEvents:
      "all"   : "render"
