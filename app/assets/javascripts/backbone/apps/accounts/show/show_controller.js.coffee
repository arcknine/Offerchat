@Offerchat.module "AccountsApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Controller extends App.Controllers.Base
    
    initialize: ->
      account = App.request "get:current:profile"
      App.execute "when:fetched", account, =>
        @layout = @getLayoutView()
        
        @listenTo @layout, "show", =>
          @sidebarRegion()
          @getProfileRegion(account)

        @show @layout
      
    sidebarRegion: ->
      navView = @getSidebarNavs()
      @layout.accountSidebarRegion.show navView
  
    getProfileRegion: (model)->
      profileView = @getProfileView(model)
      console.log profileView
      @layout.accountRegion.show profileView
    
    getProfileView: (model)->
      new Show.Profile
        model: model

    getSidebarNavs: ->
      new Show.Navs
      
    getLayoutView: ->
      new Show.Layout