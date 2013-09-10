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

        @text_counter "input[name=display_name]", ".text-limit-counter", 32

    sidebarRegion: ->
      navView = @getSidebarNavs()

      @listenTo navView, "nav:accounts:clicked", (item) =>
        App.navigate Routes.profiles_path(), trigger: true

      @listenTo navView, "nav:password:clicked", (item) =>
        App.navigate '#profiles/passwords', trigger: true

      @listenTo navView, "nav:invoices:clicked", (item) =>
        App.navigate '#profiles/invoices', trigger: true
      
      @listenTo navView, "nav:instructions:clicked", (item) =>
        App.navigate '#profiles/instructions', trigger: true

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
      
      @listenTo uploadPhotoView, "change:photo:clicked", (item) =>
        params =
          element: item
          openClass: "btn-selector"
          activeClass: "btn-action-selector"

        uploadPhotoView.toggleDropDown params
      
      @listenTo uploadPhotoView, "remove:photo:clicked", (item) =>
        App.request "show:preloader"
        profile.set
          avatar_remove: true
        profile.save {},
          success: (data)->
            App.execute "avatar:change", data.get("avatar")

      App.commands.setHandler "hide:avatar:dropdown", (item)->
        uploadPhotoView.$el.find(".btn-selector").removeClass("open").attr("disabled", true)
        uploadPhotoView.$el.find(".btn-action-selector").removeClass("active")
        

      @profileLayout.uploadPhotoRegion.show formView
    
    editProfileRegion: (model)->
      profileView = @getEditProfileRegion(model)
      formView = App.request "form:wrapper", profileView
      
      @profileLayout.editProfileRegion.show formView 

    text_counter: (input, target, max) ->
      init_text = $(input).val()
      init_count = max - init_text.length
      $(target).text init_count + " characters left"
      $(input).bind 'input propertychange', ->
        text = $(input).val()
        count = max - text.length
        if count<1
          count=0
          $(input).val $(input).val().substr(0, max)
        $(target).text count + " characters left"


