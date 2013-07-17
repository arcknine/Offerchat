@Offerchat.module "SettingsApp.TriggersList", (TriggersList, App, Backbone, Marionette, $, _) ->

  class TriggersList.Controller extends App.Controllers.Base

    initialize: (options) ->
      console.log options.currentSite
      triggers = App.request "get:user:triggers"

      @layout = @getLayoutView()

      @listenTo @layout, "show", =>
        @showTriggersList triggers

      @listenTo @layout, "add:trigger:clicked", (e) ->
        trigger = App.request "new:trigger"

        formView = @getFormView trigger
        @removeInlineForms e.target

        $(e.target).addClass("hide")
        $(e.target).parent("div").append(formView.render().$el)

      @show @layout

    showTriggersList: (triggers) ->
      triggersView = @getTriggersView triggers
      @layout.triggersRegion.show triggersView

      @listenTo triggersView, "childview:trigger:item:clicked", (e) ->
        triggerForm = @getFormView e.model
        @removeInlineForms e.el

        $(e.el).parents("#triggers-region").find("a.btn").removeClass "hide"
        $(e.el).append(triggerForm.render().$el)

    removeInlineForms: (item) ->
      $(item).parents("#triggers-region").find(".form-inline").parent("div").remove()

    getTriggersView: (triggers) ->
      new TriggersList.Triggers
        collection: triggers

    getLayoutView: ->
      new TriggersList.Layout

    getFormView: (model) ->
      new TriggersList.Form
        model: model