@Offerchat.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.Coupon extends Entities.Model

  class Entities.CouponsCollection extends Entities.Collection
    model: Entities.Coupon
    url: Routes.retrieve_coupons_path()

  API =
    getCoupons: ->
      coupons = new Entities.CouponsCollection
      coupons.fetch
        reset: true
      coupons

  App.reqres.setHandler "get:coupons", ->
    API.getCoupons()