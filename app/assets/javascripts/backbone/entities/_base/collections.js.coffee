@Offerchat.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.Collection extends Backbone.Collection

    updateModels: (attr, value) ->
      @forEach (model, index) ->
        obj = new Object()
        obj[attr] = value
        model.set obj