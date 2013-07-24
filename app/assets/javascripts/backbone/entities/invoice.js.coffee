@Offerchat.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.Invoice extends Entities.Model

  class Entities.InvoicesCollection extends Entities.Collection
    model: Entities.Invoice
    # url: Routes.invoices_path()

  API =
    getInvoices: ->
      invoices = new Entities.InvoicesCollection
      App.request "init:preloader", "show"
      invoices.fetch
        reset: true
        success: ->
          App.request "init:preloader", "hide"
        error: ->
          App.request "init:preloader", "hide"
      invoices

  App.reqres.setHandler "get:user:invoices", ->
    API.getInvoices()