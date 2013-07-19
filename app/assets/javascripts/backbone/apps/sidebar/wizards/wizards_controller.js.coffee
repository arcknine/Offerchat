@Offerchat.module "SidebarApp.Wizards", ( Wizards, App, Backbone, Marionette, $, _) ->
  class Wizards.Controller extends App.Controllers.Base
    initialize: ->
      newWizardView = @getWizardView()
      @show newWizardView

    getWizardView: ->
      new Wizards.Preview
