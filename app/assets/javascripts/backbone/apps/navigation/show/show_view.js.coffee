@Offerchat.module "NavigationApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Nav extends App.Views.ItemView
    template: "navigation/show/nav"
    className: "header-wrapper-inner"
    modelEvents:
      "change"                           : "render"

    triggers:
      "click a#root-path-link"           : "root:path:clicked"
      "click li.profile-status"          : "profile:status:toggled"
      "click li.profile-settings"        : "profile:settings:toggled"
      "click li.history-menu-link"       : "history:menu:clicked"
      "click li.reports-menu-link"       : "reports:menu:clicked"
      "click a.add-more-btn"             : "upgrade:menu:clicked"
      "click a#settings-menu-link"       : "settings:menu:clicked"
      "click a#websites-menu-link"       : "websites:menu:clicked"
      "click a#account-menu-link"        : "account:menu:clicked"
      "click a#agent-menu-link"          : "agent:menu:clicked"
      "click li.responses-menu-link"     : "responses:menu:clicked"

    events:
      "click a[data-status=logout]"      : "logout"
      "click a#changeStatus"             : "changeStatus"

    logout: ->
      try
        conn = App.xmpp.connection
        conn.sync = true
        conn.flush()
        conn.disconnect()
        conn = null

      $("#connecting-region").remove()
      App.xmpp.status = "logout"

      setTimeout (->
        location.href = Routes.destroy_user_session_path()
      ), 200

    changeStatus: (e) ->
      @trigger "change:user:status", e

    serializeData: ->
      profile: @options.model.toJSON()
      is_pro_acct: if ["PRO", "PROTRIAL", "AFFILIATE", "PROYEAR", "PRO6MONTHS", "OFFERFREE"].indexOf(@options.model.get("plan_identifier")) is -1 then false else true
      not_basic: @options.model.get("plan_identifier") isnt "BASIC" and @options.model.get("plan_identifier") isnt "BASICYEAR" and @options.model.get("plan_identifier") isnt "BASIC6MONTHS"
      trial_days_valid: @options.model.get("trial_days_left") >= 0