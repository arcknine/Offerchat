@Offerchat.module "AgentsApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.Layout extends App.Views.Layout
    template: "agents/list/layout"
    regions:
      seatsRegion:  "#seats-region"
      agentsRegion: "#agents-region"

  class List.Agent extends App.Views.ItemView
    template:  "agents/list/agent"
    tagName:   "a"
    className: "agent-selection-item"
    triggers:
      "click":      "agent:selection:clicked"
    modelEvents:
      "add" : "render"
      "change" : "render"
      "update" : "render"

  class List.Agents extends App.Views.CompositeView
    template:          "agents/list/agents"
    className:         "block large group"
    itemView:          List.Agent
    itemViewContainer: "div#agent-list"
    triggers:
      "click .agent-selection-new": "new:agent:clicked"

  class List.Seats extends App.Views.CompositeView
    template:  "agents/list/seats"
    className: "go-right align-right"

  class List.Show extends App.Views.ItemView
    template:  "agents/list/show"
    className: "group"
    triggers:
      "click .remove-agent" : "remove:agent:clicked"
    form:
      buttons:
        primary: "Save Changes"
        cancel: false
        placement: "right"
      title: "Manage Agent"

  class List.New extends App.Views.ItemView
    template: "agents/list/new"
    # tagName: "fieldset"
    className: "form form-inline invite-user-form"
    events:
      "blur input[name=email]" : "update_email_field"

    # initialize: ->
    #   console.log @model

    update_email_field: (e)->
      @model.set
        email: $(e.target).val()

  class List.NewLayout extends App.Views.Layout
    template:  "agents/list/new_layout"
    regions:
      agentRegion: "#new-agent-region"
      sitesRegion: "#new-agent-sites-region"
    form:
      buttons:
        nosubmit: "Next →"
        primary: false
        cancel: false
        placement: "right"
      title: "Add a new agent"

  class List.ShowLayout extends App.Views.Layout
    template:  "agents/list/new_layout"
    className: "invite-user-form"
    regions:
      agentRegion: "#new-agent-region"
      sitesRegion: "#new-agent-sites-region"
    form:
      buttons:
        nosubmit: "Save Changes"
        primary: false
        cancel: false
        placement: "right"
      title: "Manage agent"

  class List.Site extends App.Views.ItemView
    template: "agents/list/site"
    tagName: "li"
    className: "group"
    modelEvents:
      "updated" : "render"

    initialize: ->
      @listenTo @, "show", ->
        # console.log @model
        if @model.get('role') is 2
          # console.log $("label.admin")
          @$("label.admin").addClass "adminchecked"
          @$("label.agent").addClass "agentchecked"
        else if @model.get('role') is 3
          @$("label.agent").addClass "agentchecked"

    events:
      "click label.checkbox[data-for=admin]"   : "toggleAdminCheckbox"
      "click label.checkbox[data-for=website]" : "toggleWebsiteCheckbox"

    toggleAdminCheckbox: (e) ->
      if @$(e.currentTarget).hasClass "adminchecked"
        @$(e.currentTarget).removeClass "adminchecked"
        @model.set role: 3
      else
        $(e.currentTarget).addClass "adminchecked"
        @$("label.agent").addClass "agentchecked"
        @model.set role: 2

    toggleWebsiteCheckbox: (e)->
      if $(e.currentTarget).hasClass "agentchecked"
        $(e.currentTarget).removeClass "agentchecked"
        @$("label.admin").removeClass "adminchecked"
        @model.set role: 0
      else
        $(e.currentTarget).addClass "agentchecked"
        @model.set role: 3
      App.execute "check:selected:sites"

  class List.Sites extends App.Views.CompositeView
    template: "agents/list/sites"
    itemView: List.Site
    className: "block-list manage-agent-modal-list"
    tagName: "ul"
