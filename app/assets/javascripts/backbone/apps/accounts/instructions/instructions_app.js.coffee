@Offerchat.module "AccountsApp.Instructions", (Instructions, App, Backbone, Marionette, $, _) ->

  class Instructions.Layout extends App.Views.Layout
    template: "accounts/instructions/layout"
    tagName: "span"

    regions:
      accountSidebarRegion:                       "#accounts-sidebar-region"
      accountRegion:                              "#accounts-main-region"
      
    events:
      "click input" : "highlight"
      
    highlight: (e) ->
      e.currentTarget.select()
     
    serializeData: ->
      user: @options.model.toJSON()

  class Instructions.Navs extends App.Views.ItemView
    template: "accounts/instructions/sidebar"
    triggers:
      "click a" :                                 "nav:clicked"
      "click a.profile" :                         "nav:accounts:clicked"
      "click a.password" :                        "nav:password:clicked"
      "click a.invoices" :                        "nav:invoices:clicked"
      "click a.instructions" :                    "nav:instructions:clicked"