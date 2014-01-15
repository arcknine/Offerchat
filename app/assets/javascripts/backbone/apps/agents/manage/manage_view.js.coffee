@Offerchat.module "AgentsApp.Manage", (Manage, App, Backbone, Marionette, $, _) ->

  class Manage.Layout extends App.Views.Layout
    template: "agents/manage/layout"
    regions:
      agentsRegion: "#agents-region"

  class Manage.Agent extends App.Views.ItemView
    template:  "agents/manage/agent"
    tagName:   "a"
    className: "agent-selection-item"
    modelEvents:
      "change" : "render"
    triggers:
      "click" : "agent:selection:clicked"

  class Manage.Agents extends App.Views.CompositeView
    template:          "agents/manage/agents"
    className:         "block large group"
    itemView:          Manage.Agent
    itemViewContainer: "div#agent-list"
    collectionEvents:
      "change" : "render"
      "add"    : "render"
    # modelEvents:
    #   "change" : "render"
    triggers:
      "click .agent-selection-new" : "new:agent:clicked"
      "click #account-owner"       : "show:owner:modal"

  class Manage.NewLayout extends App.Views.Layout
    template:  "agents/manage/modal_new"
    regions:
      sitesRegion: "#new-agent-sites-region"
    form:
      buttons:
        nosubmit: (if ["PRO", "BASIC", "PROTRIAL"].indexOf(gon.current_user.plan_identifier) is -1 then "Invite Agent" else "Next →")
        primary: false
        cancel: false
        placement: "right"
      title: "Add a new agent"
    events:
      "blur input" : "updateInputField"

    updateInputField: (ev) ->
      val  = $(ev.currentTarget).val()
      attr = $(ev.currentTarget).attr("name")
      obj  = {}
      obj[attr] = val
      @model.set obj

  class Manage.UpdateLayout extends App.Views.Layout
    template: "agents/manage/modal_manage"
    regions:
      sitesRegion: "#new-agent-sites-region"
    form:
      buttons:
        nosubmit: "Save Changes"
        primary: false
        cancel: false
        placement: "right"
      title: "Manage Agent"
    triggers:
      "click .remove-agent" : "remove:agent:clicked"

  class Manage.Site extends App.Views.ItemView
    template:  "agents/manage/site"
    tagName:   "li"
    className: "group"
    modelEvents:
      "updated" : "render"
    events:
      "click label.inline.checkbox" : "toggleCheckbox"

    toggleCheckbox: (e) ->
      checkbox = $(e.currentTarget)

      if checkbox.hasClass("checked")
        checkbox.removeClass("checked")
        role = 0
      else
        checkbox.addClass("checked")
        role = 3

      @trigger "modal:check:site", { id: checkbox.data("website"), role: role }

  class Manage.Sites extends App.Views.CompositeView
    template:  "agents/manage/sites"
    tagName:   "ul"
    className: "block-list manage-agent-modal-list"
    itemView:  Manage.Site

  class Manage.UpdatePlan extends App.Views.ItemView
    template:  "agents/manage/update_plan"
    className: "block large"
    form:
      buttons:
        nosubmit: (if gon.current_user.plan_identifier is "PROTRIAL" then "Add" else "Purchase")
        primary: false
        cancel: "Cancel"
        placement: "right"
      title: "Add a new agent"
