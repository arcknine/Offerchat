@Offerchat.module "SettingsApp.TriggersList", (TriggersList, App, Backbone, Marionette, $, _) ->

  class TriggersList.Controller extends App.Controllers.Base

    initialize: (options) ->
      @currentSite = options.currentSite

      @triggers = App.request "get:website:triggers", options.currentSite.get("id")

      @layout = @getLayoutView()

      @listenTo @layout, "show", =>
        @showTriggersList @triggers, options.currentSite.get("id")

      @listenTo @triggers, "all", (ev) =>
        @showEmptyView @triggers

      App.commands.setHandler "show:trigger:items", ->
        $(".trigger-item").show()

      @listenTo @layout, "add:trigger:clicked", (e) ->
        trigger = App.request "new:trigger"
        formView = @getFormView trigger, options.currentSite.get("id")

        @removeInlineForms e.target

        $(e.target).addClass("hide")
        add_remove_form  = formView.render().$el
        $(e.target).parent("div").append(formView.render().$el)

      @show @layout

    showTriggersList: (triggers, wid) ->
      triggersView = @getTriggersView triggers
      @layout.triggersRegion.show triggersView

      @listenTo triggersView, "childview:trigger:item:clicked", (e) ->
        triggerForm = @getFormView e.model, wid
        @removeInlineForms e.el

        $(e.el).parents("#triggers-region").find("a.btn").removeClass "hide"
        $(e.el).append(triggerForm.render().$el)

    showEmptyView: (triggers) ->
      if triggers.length is 0
        emptyView = @getEmptyView triggers
        @layout.emptyRegion.show emptyView

    getEmptyView: (triggers) ->
      new TriggersList.Empty
        collection: triggers

    removeInlineForms: (item) ->
      if item
        $(item).parents("#triggers-region").find(".form-inline").parent("div").remove()
      else
        $("#triggers-region").find(".form-inline").parent("div").remove()
        $("#addTriggerBtn").removeClass("hide")

    getTriggersView: (triggers) ->
      new TriggersList.Triggers
        collection: triggers

    getLayoutView: ->
      new TriggersList.Layout
        model: @currentSite

    getFormView: (model, wid) ->
      the_form = @createForm model

      @listenTo model, "created", (trigger) =>
        @removeInlineForms()
        @triggers.add trigger
        @showNotification("Your new trigger has been created")

      @listenTo model, "updated", (trigger) ->
        @showNotification("Your changes have been saved")

      @listenTo the_form, "save:trigger:clicked", (item) ->
        @saveEntry item, wid

      @listenTo the_form, "cancel:trigger:clicked", (item) ->
        @removeInlineForms()
        App.execute "show:trigger:items"

      @listenTo the_form, "remove:trigger:clicked", (item) ->
        if confirm("Are you sure you want to delete this trigger?")
          item.model.destroy()

      @listenTo the_form, "rule:changed", (e) ->
        this_elem = $(e.target)
        elem_parent = this_elem.parents(".form-inline")
        rule = this_elem.val()

        elem_parent.find(".input-container").removeClass("hide")

        if rule is "1" then elem_parent.find("#url").addClass("hide")       # time only
        # else if rule is "2"                                               # time and url
        else if rule is "3" then elem_parent.find("#time").addClass("hide") # url only

      @listenTo the_form, "render", (view) =>
        if view.model.get("rule_type")
          rule_type = view.model.get("rule_type")
          $(view.el).find("option").removeAttr("selected")
          $(view.el).find("option[value='"+rule_type+"']").attr("selected","selected")

          $(view.el).find(".input-container").removeClass("hide")

          if rule_type is 1 then $(view.el).find("#url").addClass("hide")
          else if rule_type is 3 then $(view.el).find("#time").addClass("hide")

      the_form


    saveEntry: (item, wid) ->
      @removeErrors()

      obj = new Object()
      obj.website_id = wid
      noError = true

      $.each $("[name]").filter(":input"), (key, elem) =>
        if $(elem).attr("name") is "rule_type"
          if $(elem).val() is ""
            @showError("rule_type", "can't be blank!")
            noError = false
          else
            obj.rule_type = $(elem).val()

        if $(elem).attr("name") is "time"
          if obj.rule_type is "1" or obj.rule_type is "2"
            if $(elem).val() is ""
              @showError("time", "can't be blank!")
              noError = false
            else if !@is_number $(elem).val()
              @showError("time", "is invalid!")
              noError = false
            else if $(elem).val() < 5
              @showError("time", "should be at least 5 seconds!")
              noError = false
            else
              obj.time = $(elem).val()

        if $(elem).attr("name") is "url"
          if obj.rule_type is "2" or obj.rule_type is "3"
            if $(elem).val() is ""
              @showError("url", "can't be blank!")
              noError = false
            else if !@isValidUrl $(elem).val()
              @showError("url", "is invalid!")
              noError = false
            else
              obj.url = $(elem).val()

        if $(elem).attr("name") is "message"
          if $(elem).val() is ""
            @showError("message", "can't be blank!")
            noError = false
          else
            obj.message = $(elem).val()

      if noError
        item.model.save(obj, { error: (model, response) =>
          @handleSaveError(response)
        })

    handleSaveError: (response) ->
      $.each response.responseJSON.errors, (key, value) =>
        @showError(key, value)

    showError: (elname, msg) ->
      $("[name='"+elname+"']").closest("fieldset").addClass("field-error").find("label").append("<span class='inline-label-message'>"+msg+"</span>")

    createForm: (model) ->
      new TriggersList.Form
        model: model

    removeErrors: ->
      $("span.inline-label-message").remove()
      $("fieldset.field-error").removeClass("field-error")

    is_number: (value) ->
      value.match /^\d+$/

    isValidUrl: (url) ->
      if /^(https?|ftp):\/\/(((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&amp;'\(\)\*\+,;=]|:)*@)?(((\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5]))|((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.?)(:\d*)?)(\/((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&amp;'\(\)\*\+,;=]|:|@)+(\/(([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&amp;'\(\)\*\+,;=]|:|@)*)*)?)?(\?((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&amp;'\(\)\*\+,;=]|:|@)|[\uE000-\uF8FF]|\/|\?)*)?(\#((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&amp;'\(\)\*\+,;=]|:|@)|\/|\?)*)?$/i.test(url)
        true
      else
        false