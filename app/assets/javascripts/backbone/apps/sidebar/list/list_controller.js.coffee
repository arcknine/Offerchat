@Offerchat.module "SidebarApp.List", (List, App, Backbone, Marionette, $, _) ->
  
  class List.Controller extends App.Controllers.Base
    
    initialize: ->
      sites = App.request "site:entities"
      console.log sites 
      
      @layout = @getLayoutView
      
      @listenTo @layout, "show", =>
        @siteSelectorRegion sites
        #@groupsRegion()
        #@visitorsRegion()

      @show @layout
    
    siteSelectorRegion: (sites)->
      