@Offerchat.module "AccountsApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Layout extends App.Views.Layout
    template: "accounts/show/layout"
    tagName: "span"

    regions:
      accountSidebarRegion:                       "#accounts-sidebar-region"
      accountRegion:                              "#accounts-main-region"

  class Show.Navs extends App.Views.ItemView
    template: "accounts/show/navs"
    triggers:
      "click a" :                                 "nav:clicked"
      "click a.profile" :                         "nav:accounts:clicked"
      "click a.password" :                        "nav:password:clicked"
      "click a.instructions" :                    "nav:instructions:clicked"

  class Show.Profile extends App.Views.ItemView
    template: "accounts/show/profile"
    triggers:
      "click div.btn-action-selector"   : "change:photo:clicked"
      "change input.file-input"         : "upload:button:change"
      "blur input.file-input"           : "upload:button:blur"
    form:
      attributes:
        method: "POST"
        action: "test/action"

    events:
      "click .block-message a.close" :  "closeNotification"

    closeNotification: (e) ->
      $(e.currentTarget).parent("div").fadeOut()

    onShow: ->
      @$el.fileupload
        url: Routes.update_avatar_profiles_path()
        formData: {authenticity_token: App.request("csrf-token")}
        add: (e, data) ->
          types = /(\.|\/)(gif|jpe?g|png)$/i
          file = data.files[0]
          if types.test(file.type) || types.test(file.name)
            data.context = $(tmpl("#template-upload", file))
            $('.upload-avatar').append(data.context)
            data.submit().done (e,data)->
          else
            self.showNotification "#{file.name} is not a gif, jpeg, or png image file"

  class Show.Password extends App.Views.ItemView
    template: "accounts/show/password"

    events:
      "click .block-message a.close" :  "closeNotification"

    closeNotification: (e) ->
      $(e.currentTarget).parent("div").fadeOut()

  class Show.Notifications extends App.Views.ItemView
    template:  "accounts/show/notifications"
    className: "column-content-container"

    triggers:
      "click label.checkbox" :                    "notification:checkbox:clicked"


  class Show.Invoice extends App.Views.ItemView
    template:   "accounts/show/invoice"
    tagName:    "div"
    className:  "table-row group"

  class Show.Invoices extends App.Views.CompositeView
    template: "accounts/show/invoices"
    itemViewContainer: "div"
    className: "table-history-viewer-content"
    itemView: Show.Invoice