@Offerchat.module "SettingsApp.TriggersList", (TriggersList, App, Backbone, Marionette, $, _) ->

  class TriggersList.Controller extends App.Controllers.Base

    initialize: (options) ->
      triggers = App.request "get:website:triggers", options.currentSite.get("id")

      @layout = @getLayoutView()

      @listenTo @layout, "show", =>
        @showTriggersList triggers, options.currentSite.get("id")

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

    removeInlineForms: (item) ->
      $(item).parents("#triggers-region").find(".form-inline").parent("div").remove()

    getTriggersView: (triggers) ->
      new TriggersList.Triggers
        collection: triggers

    getLayoutView: ->
      new TriggersList.Layout

    getFormView: (model, wid) ->
      the_form = @createForm model

      @listenTo model, "updated", (trigger) ->
        console.log trigger

      @listenTo the_form, "save:trigger:clicked", (item) ->
        @saveEntry item, wid

      @listenTo the_form, "remove:trigger:clicked", (item) ->
        if confirm("Are you sure you want to delete this trigger?")
          item.model.destroy()

      @listenTo the_form, "rule:changed", (e) ->
        this_elem = $(e.target)
        elem_parent = this_elem.parents(".form-inline")
        rule = this_elem.val()

        elem_parent.find(".input-container").removeClass("hide")

        switch rule
          when "1"  # time only
            elem_parent.find("#url").addClass("hide")
          # when "2"  # time and url
          when "3"  # url only
            elem_parent.find("#time").addClass("hide")

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
          if $(elem).val() is ""
            @showError("time", "can't be blank!")
            noError = false
          else if !@is_number $(elem).val()
            @showError("time", "is invalid!")
            noError = false
          else
            obj.time = $(elem).val()

        if $(elem).attr("name") is "url"
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

      if noError then item.model.save(obj)

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