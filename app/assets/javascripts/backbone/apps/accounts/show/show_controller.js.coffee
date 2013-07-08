@Offerchat.module "AccountsApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Controller extends App.Controllers.Base

    initialize: (options)->
      @account = App.request "get:current:profile"
        
      App.execute "when:fetched", @account, =>
        @layout = @getLayoutView()

        @listenTo @layout, "show", =>
          @sidebarRegion(options.section)
          @getMainRegion(options.section)
          
        @show @layout

    sidebarRegion: (section)->
      navView = @getSidebarNavs()

      @listenTo navView, "show", (item) =>
        @setSelectedNav(navView, section)

      @listenTo navView, "nav:accounts:clicked", (item) =>
        App.navigate Routes.profiles_path(), trigger: true

      @listenTo navView, "nav:password:clicked", (item) =>
        App.navigate '#profiles/passwords', trigger: true

      @listenTo navView, "nav:notifications:clicked", (item) =>
        App.navigate '#profiles/notifications', trigger: true

      @listenTo navView, "nav:invoices:clicked", (item) =>
        App.navigate '#profiles/invoices', trigger: true

      #  
      #@listenTo navView, "agents", (item) =>
      #  App.navigate '#profiles/agents', trigger: true
      #  
      #@listenTo navView, "websites", (item) =>
      #  App.navigate '#profiles/websites', trigger: true
      #  
      #@listenTo navView, "invoices", (item) =>
      #  App.navigate '#profiles/invoices', trigger: true
      #
      @layout.accountSidebarRegion.show navView
      

    getMainRegion: (section) ->
      if section is "profile"
        @getProfileRegion()
      else if section is "password"
        @getPasswordRegion()
      else if section is "notifications"
        @getNotificationsRegion()
      else if section is "invoices"
        @getInvoicesRegion()

    getInvoicesRegion: ->
      @invoices = App.request "get:user:invoices"

      App.execute "when:fetched", @invoices, =>
        invoicesView = @getInvoicesView()
        @layout.accountRegion.show invoicesView

    getInvoicesView: ->
      new Show.Invoices
        collection: @invoices


    getNotificationsRegion: ->
      notificationsView = @getNotificationsView()
      @listenTo notificationsView, "notification:checkbox:clicked", (item) =>
        # handle checkbox click event
        console.log item

      @layout.accountRegion.show notificationsView

    getNotificationsView: ->
      new Show.Notifications
        model: @account

    getProfileRegion: ->
      profileView = @getProfileView()
      @listenTo profileView, "account:profile:form:submit", (item) =>
        console.log item
        item.model.save()
      @layout.accountRegion.show profileView

    getProfileView: ->
      new Show.Profile
        model: @account


    getPasswordRegion: ->
      passwordView = @getPasswordView()
      formView = App.request "form:wrapper", passwordView
      passwordView.model.url = Routes.passwords_path()
      @layout.accountRegion.show formView
      
    getPasswordView: ->
     new Show.Password
       model: @account
    
    getProfileView: ->
      new Show.Profile
        model: @account

    getSidebarNavs: ->
      new Show.Navs

    getLayoutView: ->
      new Show.Layout

    setSelectedNav: (nav, section) ->
      $(nav.el).find("ul li a").removeClass("selected")
      $(nav.el).find("ul li a." + section).addClass("selected")