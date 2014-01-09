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
    triggers:
      "click .agent-selection-new" : "new:agent:clicked"
      "click #account-owner"       : "show:owner:modal"

  class Manage.NewLayout extends App.Views.Layout
    template:  "agents/manage/modal_new"
    regions:
      sitesRegion: "#new-agent-sites-region"
    form:
      buttons:
        nosubmit: "Next →"
        primary: false
        cancel: false
        placement: "right"
      title: "Add a new agent"

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

  class Manage.Site extends App.Views.ItemView
    template:  "agents/manage/site"
    tagName:   "li"
    className: "group"

  class Manage.Sites extends App.Views.CompositeView
    template:  "agents/manage/sites"
    tagName:   "ul"
    className: "block-list manage-agent-modal-list"
    itemView:  Manage.Site