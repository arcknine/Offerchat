@Offerchat.module "SelectorApp.Show", (Show, App, Backbone, Marionette, $, _) ->
  
  class Show.Controller extends App.Controllers.Base
    
    initialize: ->
      sites = App.request "site:entities"

      App.execute "when:fetched", site, =>
        site = sites.first()
        @layout = @getView(site)

        @show @layout
        
    getView: (model)->
      new Show.View
        model: model