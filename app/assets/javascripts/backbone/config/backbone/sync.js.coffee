do (Backbone) ->
  _sync = Backbone.sync

  Backbone.sync = (method, entity, options = {}) ->
    
    _.defaults options,
      beforeSend: _.bind(methods.beforeSend,   entity)
      complete:    _.bind(methods.complete,    entity)
    
    sync = _sync(method, entity, options)
    if !entity._fetch and method is "read"
      entity._fetch = sync
  
  methods =
    beforeSend: (xhr)->
      xhr.setRequestHeader('X-CSRF-Token', $("meta[name='csrf-token']").attr('content'))
      @trigger "sync:start", @
    
    complete: ->
      @trigger "sync:stop", @