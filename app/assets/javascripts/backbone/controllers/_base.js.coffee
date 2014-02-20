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

    showNotification: (message, type="success", sec=3) ->
      $(".block-message").removeClass("success").removeClass("warning")
      $(".block-message").find("span").html(message)
      $(".block-message").addClass(type).fadeIn()

      setTimeout ->
        $(".block-message").fadeOut()
      , sec * 1000

    showSettingsNotification: (message, type="success") ->
      $("#setting-notification").find("span").html(message)
      $("#setting-notification").addClass(type).fadeIn()

      setTimeout ->
        $("#setting-notification").fadeOut()
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