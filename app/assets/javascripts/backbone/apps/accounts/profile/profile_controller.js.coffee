@Offerchat.module "AccountsApp.Profile", (Profile, App, Backbone, Marionette, $, _) ->

  class Profile.Controller extends App.Controllers.Base
    
    initialize: (options)->

      profile = App.request "get:current:profile"
      
      @listenTo profile, "updated", (item) ->
        @showNotification "Your changes have been saved!"
      
      App.execute "when:fetched", profile, =>
        @layout = @getLayoutView()
        
        @listenTo @layout, "show", =>
          @sidebarRegion(options.section)
          @getProfileRegion(profile)

        @show @layout

    sidebarRegion: (section)->
      navView = @getSidebarNavs()

      @listenTo navView, "nav:accounts:clicked", (item) =>
        App.navigate Routes.profiles_path(), trigger: true

      @listenTo navView, "nav:password:clicked", (item) =>
        App.navigate '#profiles/passwords', trigger: true

      @layout.accountSidebarRegion.show navView

    getProfileRegion: (profile) ->
      @profileLayout = @getProfileLayout(profile)
      
      @listenTo @profileLayout, "show", (item) =>
        @uploadPhotoRegion(profile)
        @editProfileRegion(profile)

      profile.url = Routes.profiles_path()
      @layout.accountRegion.show @profileLayout 

    getEditProfileRegion: (model)->
      new Profile.Edit
        model: model

    getProfileLayout: ->
      new Profile.View

    getProfileView: ->
      new Profile.View

    getSidebarNavs: ->
      new Profile.Navs

    getLayoutView: ->
      new Profile.Layout

    getUploadPhotoRegion: (model)->
      new Profile.Photo
        model: model

    uploadPhotoRegion: (profile)->
      uploadPhotoView = @getUploadPhotoRegion profile
      formView = App.request "form:wrapper", uploadPhotoView
      formView.$el.addClass "upload-avatar"
      
      @listenTo uploadPhotoView, "show:notification", (item) =>
        @showNotification item
      
      @listenTo uploadPhotoView , "change:photo:clicked", (item) =>
        params =
          element: item
          openClass: "btn-selector"
          activeClass: "btn-action-selector"

        uploadPhotoView.toggleDropDown params

      @listenTo uploadPhotoView , "upload:button:change", (item) =>
        params =
          element: item
          openClass: "btn-selector"
          activeClass: "btn-action-selector"

        uploadPhotoView.toggleDropDown params

      @listenTo uploadPhotoView , "upload:button:blur", (item) =>
        console.log "blur"

      @profileLayout.uploadPhotoRegion.show formView
    
    editProfileRegion: (model)->
      profileView = @getEditProfileRegion(model)
      formView = App.request "form:wrapper", profileView
      
      @profileLayout.editProfileRegion.show formView
