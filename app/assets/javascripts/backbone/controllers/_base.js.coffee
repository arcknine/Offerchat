@Offerchat.module "Controllers", (Controllers, App, Backbone, Marionette, $, _) ->

  class Controllers.Base extends Marionette.Controller

    constructor: (options = {}) ->
      @region = options.region or App.request "default:region"
      super options
      @_instance_id = _.uniqueId("controller")
      App.execute "register:instance", @, @_instance_id

    close: (args...) ->
      delete @region
      delete @options
      super args
      App.execute "unregister:instance", @, @_instance_id

    show: (view) ->
      @listenTo view, "close", @close
      @region.show view

    showNotification: (message) ->
      $(".block-message").find("span").html(message)
      $(".block-message").fadeIn()

      setTimeout ->
        $(".block-message").fadeOut()
      , 3000

    connectionSend: (stanza, to) ->
      connection = App.xmpp.connection
      connection.send stanza

      setTimeout (=>
        attr = new Object({type: 'chat'})
        if to then attr.to = to

        active = $msg(attr).c('active', {xmlns: 'http://jabber.org/protocol/chatstates'})
        connection.send active
      ), 100