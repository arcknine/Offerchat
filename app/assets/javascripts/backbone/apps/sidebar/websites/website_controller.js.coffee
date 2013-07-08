@Offerchat.module "SidebarApp.Website", (Website, App, Backbone, Marionette, $, _) ->
  
  class Website.Controller extends App.Controllers.Base
    
    initialize: ->
      sites = App.request "site:entities"
      
      App.execute "when:fetched", sites, =>
        site = sites.first()
        @layout = @getLayoutView()
        
        @listenTo @layout, "show", ->
          @initSelectedSiteRegion(site)
        
        @show @layout