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
    tagName: "fieldset"
    events:
      "blur input[name=email]" : "update_email_field"
    
    update_email_field: (e)->
      @model.set
        email: $(e.target).val()

  class List.NewLayout extends App.Views.Layout
    template:  "agents/list/new_layout"
    className: "form form-inline invite-user-form"
    regions:
      agentRegion: "#new-agent-region"
      sitesRegion: "#new-agent-sites-region"
    form:
      buttons:
        nosubmit: "Send Invite"
        primary: false
        cancel: false
        placement: "right"
      title: "Invite a user to be an agent"

  class List.ShowLayout extends App.Views.Layout
    template:  "agents/list/new_layout"
    className: "form form-inline invite-user-form"
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

    events:
      "click label.checkbox[data-for=admin]"   : "toggleAdminCheckbox"
      "click label.checkbox[data-for=website]" : "toggleWebsiteCheckbox"

    toggleAdminCheckbox: (e) ->
      unless $(e.currentTarget).hasClass "adminchecked"
        $(e.currentTarget).addClass "adminchecked"
        @$("#websitecheckbox" + $(e.currentTarget).data("id")).attr('checked', 'checked')
        @$("label[data-for=website]").addClass "agentchecked"
        @trigger "account:role:admin:checked"
      else
        $(e.currentTarget).removeClass "adminchecked"
        @trigger "account:role:admin:unchecked"
        
    toggleWebsiteCheckbox: (e)->
      unless $(e.currentTarget).hasClass "agentchecked"
        $(e.currentTarget).addClass "agentchecked"
        @trigger "account:role:agent:checked"
      else
        $(e.currentTarget).removeClass "agentchecked"
        @$("label[data-for=admin]").removeClass "adminchecked"
        @$("#admincheckbox" + $(e.currentTarget).data("id")).attr('checked', false)
        @trigger "account:role:agent:unchecked"

  class List.Sites extends App.Views.CompositeView
    template: "agents/list/sites"
    itemView: List.Site
    className: "block-list manage-agent-modal-list"
    tagName: "ul"
