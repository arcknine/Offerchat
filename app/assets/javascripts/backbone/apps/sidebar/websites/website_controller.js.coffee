@Offerchat.module "SidebarApp.Website", (Website, App, Backbone, Marionette, $, _) ->

  class Website.Controller extends App.Controllers.Base

    initialize: ->
      sites = App.request "site:entities"
      @currentUser = App.request "get:current:user:json"

      App.execute "when:fetched", sites, =>

        App.reqres.setHandler "site:entities", =>
          sites

        site = sites.first()
        @layout = @getLayoutView()

        @listenTo @layout, "show", ->
          @initSelectedSiteRegion(site)

        @show @layout

