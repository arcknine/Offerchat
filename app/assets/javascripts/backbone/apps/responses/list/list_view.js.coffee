@Offerchat.module "ResponsesApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.Layout extends App.Views.Layout
    template: "responses/list/layout"
    regions:
      qrRegion: "#quick-responses"

    triggers:
      "click .cancel-new-qr"  : "cancel:new:qr"
      "click .delete-selected-qrs" : "delete:selected:qrs"

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
      edit_qr = $(e.target).closest("div.edit-qr")
      edit_qr.addClass "hide"
      edit_qr.parent().find(".qr-item").removeClass "hide"

    qrClicked: (e) ->
      target = $(e.target)
      if !target.hasClass("icon-check")
        qr_item = target.closest("div.qr-item")
        edit_qr = qr_item.next(".edit-qr")
        if edit_qr.hasClass("hide")
          $(".edit-qr").addClass "hide"
          edit_qr.removeClass "hide"

          $(".qr-item").removeClass "hide"
          qr_item.addClass "hide"
        else
          edit_qr.addClass "hide"
          qr_item.removeClass "hide"

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
