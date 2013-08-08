@Offerchat.module "AccountsApp.Profile", (Profile, App, Backbone, Marionette, $, _) ->

  class Profile.Layout extends App.Views.Layout
    template: "accounts/profile/layout"
    tagName: "span"

    regions:
      accountSidebarRegion:                       "#accounts-sidebar-region"
      accountRegion:                              "#accounts-main-region"

  class Profile.Navs extends App.Views.ItemView
    template: "accounts/profile/sidebar"
    triggers:
      "click a" :                                 "nav:clicked"
      "click a.profile" :                         "nav:accounts:clicked"
      "click a.password" :                        "nav:password:clicked"
      "click a.invoices" :                        "nav:invoices:clicked"
      #"click a.notifications" :                   "nav:notifications:clicked"

  class Profile.View extends App.Views.Layout
    template: "accounts/profile/profile"
    regions:
      uploadPhotoRegion:                          "#upload-photo-profile-region"
      editProfileRegion:                          "#edit-profile-region"
    events:
      "click .block-message a.close" :  "closeNotification"

    closeNotification: (e) ->
      $(e.currentTarget).parent("div").fadeOut()

  class Profile.Photo extends App.Views.ItemView
    template: "accounts/profile/upload_photo"
    className: "form"
    
    events:
      "click input.file-input": (e)->
        App.execute "hide:avatar:dropdown"

    triggers:
      "click div.btn-action-selector"   : "change:photo:clicked"
      "click a.remove"                  : "remove:photo:clicked"
      
    modelEvents:
      "change"                          : "render"
    form:
      buttons:
        nosubmit: false
        primary: false
        cancel: false

    onShow: ->
      self = @
      @$el.fileupload
        url: Routes.update_avatar_profiles_path()
        formData: {authenticity_token: App.request("csrf-token")}
        add: (e, data) ->
          types = /(\.|\/)(jpe?g|png)$/i
          file = data.files[0]
          App.request "show:preloader"
          if types.test(file.type) || types.test(file.name)
            data.submit().done( (e,data)->
              self.model.set e
              App.execute "avatar:change", e.avatar
              App.request "hide:preloader"
              self.trigger "show:notification", "Your avatar have been saved!"
            ).fail (jqXHR, textStatus, errorThrown)->
              if JSON.parse(jqXHR.responseText).errors.avatar_file_size.length > 0
                self.trigger "show:notification", "File size is too large. Please choose a smaller avatar"
              App.request "hide:preloader"
          else
            self.trigger "show:notification", "#{file.name} is not a jpeg, or png image file"
            App.request "hide:preloader"


  class Profile.Edit extends App.Views.ItemView
    template: "accounts/profile/edit"
    className: "form"
    form:
      buttons:
        nosubmit: false
        primary: "Save Changes"
        cancel: false