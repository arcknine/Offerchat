@Offerchat.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.Invoice extends Entities.Model

  class Entities.InvoicesCollection extends Entities.Collection
    model: Entities.Invoice
    # url: Routes.invoices_path()

  API =
    getInvoices: ->
      invoices = new Entities.InvoicesCollection
      invoices.fetch
        reset: true
      invoices

  App.reqres.setHandler "get:user:invoices", ->
    API.getInvoices()