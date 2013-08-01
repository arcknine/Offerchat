@Offerchat.module "Views", (Views, App, Backbone, Marionette, $, _) ->

  _remove = Marionette.View::remove

  _.extend Marionette.View::,

    addOpacityWrapper: (init = true) ->
      @closeDropDown()

      @$el.toggleWrapper
        className: "opacity"
      , init

    setInstancePropertiesFor: (args...) ->
      for key, val of _.pick(@options, args...)
        @[key] = val

    toggleDropDown: (options) ->
      open_elem = $(options.element.view.el).find("."+options.openClass)

      @closeDropDown open_elem
      @setActiveObject options

    closeDropDown: (elem) ->
      if elem
        if elem.hasClass "open"
          if elem.has("ul").length then elem.removeClass("open") # only remove open class if has dropdown
        else
          $(".open").removeClass("open")

          $.each elem.find(".active"), (key,value) ->
            $(value).removeClass("active")

          elem.addClass "open"
      else
        $(".open").removeClass("open")

    setActiveObject: (options) ->
      if options.activeClass
        active_elem = $(options.element.view.el).find("."+options.activeClass)
        active_elem.toggleClass "active"

    remove: (args...) ->
      # console.log "removing", @
      if @model?.isDestroyed?()

        wrapper = @$el.toggleWrapper
          className: "opacity"
          backgroundColor: "red"

        wrapper.fadeOut 400, ->
          $(@).remove()

        @$el.fadeOut 400, =>
          _remove.apply @, args
      else
        _remove.apply @, args

    templateHelpers: ->

      linkTo: (name, url, options = {}) ->
        _.defaults options,
          external: false

        url = "#" + url unless options.external

        "<a href='#{url}'>#{@escape(name)}</a>"