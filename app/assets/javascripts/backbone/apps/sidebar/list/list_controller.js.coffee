@Offerchat.module "SidebarApp.List", (List, App, Backbone, Marionette, $, _) ->
  
  class List.Controller extends App.Controllers.Base
    
    initialize: (options)->
      sites = App.request "site:entities"
      App.execute "when:fetched", sites, =>
        
        @layout = @getLayoutView()
        
        @listenTo @layout, "show", =>
          @siteSelectorRegion()
          @visitorsRegion()

        console.log @show @layout
    
    visitorsRegion: ->
      visitorsView = @getVisitorsView()
      @layout.visitorsRegion.show visitorsView
    
    siteSelectorRegion: (sites)->
      siteSelectorView = @getSiteSelectorView sites

      @listenTo siteSelectorView, "siteselector:clicked", (child) ->
        $(child.view.el).parent().toggleClass('open')
        console.log $(child.view.el).find('.site-selector').toggleClass('active')
        #$(child.view.el).find('.site-selector').toggleClass('active')
      @layout.siteSelectorRegion.show(siteSelectorView)
      
    getVisitorsView: ->
      new List.Visitors
      
    getSiteSelectorView: (sites)->
      new List.SiteSelector
        collection: sites
        
    getLayoutView: ->
      new List.Layout