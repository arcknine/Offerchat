@Offerchat.module "WebsitesApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.Controller extends App.Controllers.Base

    initialize: ->
      sites = App.request "site:entities"

      App.execute "when:fetched", sites, =>
        sitesView = @getWebsitesView sites

        @listenTo sitesView, "childview:click:delete:website", (site) =>
          if confirm("Are you sure you want to delete this website?")
            site.model.destroy()

        App.mainRegion.show sitesView

    getWebsitesView: (sites) ->
      new List.Websites
        collection: sites
