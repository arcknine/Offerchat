@Offerchat.module "AgentsApp.Manage", (Manage, App, Backbone, Marionette, $, _) ->

  class Manage.Controller extends App.Controllers.Base

    initialize: ->
      user = App.request "get:current:user"
      unless user.get "plan_identifier"
        App.navigate Routes.root_path(), trigger: true
      else

        @layout       = @getLayoutView()
        @current_user = App.request "get:current:profile"
        @agents       = App.request "agents:only:entities"
        @websites     = App.request "owned:sites:entities"
        online_agents = App.request "get:online:agents"
        plans        = App.request "get:plans"

        App.execute "when:fetched", @websites , =>
          if @websites.length is 0
            console.log "You are doom!!!"

        App.execute "when:fetched", @agents , =>
          @setAgentStatus online_agents, @agents

          @listenTo online_agents, "all", =>
            @setAgentStatus online_agents, @agents

        @listenTo @layout, "show", =>
          App.execute "when:fetched", @current_user, =>
            App.execute "when:fetched", plans, =>
              @plan = plans.findWhere plan_identifier: @current_user.get("plan_identifier")
              @showAgents()

        @show @layout

    setAgentStatus: (online_agents, agents) ->
      online_agents.each (agent, key) ->
          online_agent = agents.findWhere { jabber_user: agent.get("token") }
          online_agent.set "status", agent.get("status") if online_agent

    showAgents: ->
      agentsView = @getAgentsView()
      plan       = @current_user.get "plan_identifier"

      @listenTo agentsView, "show", =>
        if ["AFFILIATE"].indexOf(plan) isnt -1
          $(".agent-selection-new").remove()

      @listenTo agentsView, "new:agent:clicked", (item) =>
        if ["AFFILIATE"].indexOf(plan) isnt -1
          @showNotification "You are not allowed to add any agent.", "warning"
        else

          @websites.each (site, index) ->
            site.set "agentChecked", ""

          agent        = App.request "new:agent:entity"
          addAgentView = @getAddAgentLayout agent
          modalSites   = @getModalSites @websites
          modalLayout  = App.request "modal:wrapper", addAgentView
          websites     = []
          self         = @

          @websites.each (site, key) ->
            websites.push
              website_id:   site.get("id")
              url:          site.get("url")
              name:         site.get("name")
              role:         0
              agentChecked: ""

          App.modalRegion.show modalLayout
          addAgentView.sitesRegion.show modalSites

          @listenTo modalSites, "childview:modal:check:site", (obj, result) =>
            $.each websites, (index, site) ->
              if site.website_id is result.id
                site.role = result.role

          @listenTo modalLayout, "modal:cancel", (item) ->
            modalLayout.close()

          @listenTo modalLayout, "modal:unsubmit", (obj) =>
            agent.set websites: websites
            # check if user what plan is being used
            if ["PRO", "BASIC", "PROTRIAL", "PROYEAR", "PRO6MONTHS", "BASICYEAR", "BASIC6MONTHS", "OFFERFREE"].indexOf(plan) isnt -1
              errors = @getErrors agent
              modalLayout.$el.find(".field-error").removeClass("field-error")
              modalLayout.$el.find(".block-text-message").remove()
              App.request "modal:hide:message"

              errCount = 0
              $.each errors, (key, error) ->
                errCount++
                el = modalLayout.$el.find("input[name='#{key}']")
                sm = $("<div>", class: 'block-text-message').text(error)
                el.closest("fieldset").addClass("field-error")
                el.parent().append(sm)

                if key is "websites"
                  App.request "modal:error:message", error

              # if no error is found
              if errCount is 0
                modalLayout.close()
                @addPlanQty agent
            else
              @addAgent agent, modalLayout


      @listenTo agentsView, "show:owner:modal", (item) ->
        item.model.set "is_admin", true
        manageAgentView = @getManageAgentLayout item.model
        modalLayout     = App.request "modal:wrapper", manageAgentView

        App.modalRegion.show modalLayout

        @listenTo modalLayout, "modal:cancel", (item)->
          modalLayout.close()

        @listenTo modalLayout, "modal:unsubmit", (ob)->
          modalLayout.close()

      @listenTo agentsView, "childview:agent:selection:clicked", (item) =>
        agent       = item.model
        agent_sites = agent.get("websites")

        $.each agent_sites, (index, site) =>
          website = @websites.findWhere { id: site.id }
          unless site.role is 0
            website.set "agentChecked", "checked"
          else
            website.set "agentChecked", ""

        manageAgentView = @getManageAgentLayout item.model
        modalSites      = @getModalSites @websites
        modalLayout     = App.request "modal:wrapper", manageAgentView

        App.modalRegion.show modalLayout
        manageAgentView.sitesRegion.show modalSites

        @listenTo manageAgentView, "remove:agent:clicked", (item) =>
          if confirm "Are you sure you want to remove this agent?"
            modalLayout.close()

            processView   = @getDeleteProcessModal @plan
            processLayout = App.request "modal:wrapper", processView
            App.modalRegion.show processLayout

            processLayout.$el.find(".modal-footer").remove()
            processLayout.$el.find(".close").remove()

            agent.destroy
              success: (model, response) =>
                @showNotification("Your changes have been saved!")
                processLayout.close()

        @listenTo modalSites, "childview:modal:check:site", (obj, result) =>
          $.each agent_sites, (index, site) =>
            if site.id is result.id
              site.role = result.role

        @listenTo modalLayout, "modal:cancel", (item) ->
          modalLayout.close()

        @listenTo modalLayout, "modal:unsubmit", (obj) =>
          errors = @getErrors agent
          modalLayout.$el.find(".field-error").removeClass("field-error")
          modalLayout.$el.find(".block-text-message").remove()
          App.request "modal:hide:message"

          errCount = 0
          $.each errors, (key, error) ->
            errCount++
            if key is "websites"
              App.request "modal:error:message", error

          if errCount is 0
            agent.save
              success: (model, response) =>
                @showNotification("Your changes have been saved!")
                modalLayout.close()
              error: ->
                console.log "error"

            @showNotification("Your changes have been saved!")
            modalLayout.close()

      @layout.agentsRegion.show agentsView

    getErrors: (model) ->
      errors   = {}
      site_err = 0
      name     = model.get("display_name")
      email    = model.get("email")
      regex    = /\S+@\S+\.\S+/

      errors['display_name'] = "should not be blank" unless name
      errors['email']        = "invalid email" if email and !regex.test(email)
      errors['email']        = "should not be blank" unless email

      $.each model.get("websites"), (index, site) ->
        if site.role isnt 0
          site_err++
      errors['websites'] = "Please select website" if site_err is 0

      errors

    addAgent: (agent, modal) ->
      agent.save agent.attributes,
        success: (model) =>
          @agents.add model
          @showNotification("Invitation sent!")
          modal.close()
        error: (data, response) =>
          if response.status == 422
            errs = []
            errors  = $.parseJSON(response.responseText).errors
            for attribute, messages of errors
              if attribute isnt "base"
                errs.push "#{attribute.charAt(0).toUpperCase()}#{attribute.slice(1)} #{message}" for message in messages
              else
                errs.push "#{message}" for message in messages
            @showNotification _.first(errs), 'warning'

          modal.close()

    addPlanQty: (agent) ->
      # add 2 for owner and new agent
      total = @plan.get("price") * (@agents.length + 2)
      # @plan.set
      #   agents: @agents.length + 2
      #   total:  (if total is 0 then "Free" else "$" + total.toFixed(2).replace(/(\d)(?=(\d{3})+\.)/g, '$1,'))
      @plan.set
        agents: @agents.length + 2
        total:  "$#{@plan.get("price").toFixed(2).replace(/(\d)(?=(\d{3})+\.)/g, '$1,')}"

      agent.set(total_agents: @agents.length + 2)

      updatePlanView = @getModalUpdatePlan @plan
      modalLayout    = App.request "modal:wrapper", updatePlanView

      App.modalRegion.show modalLayout

      @listenTo updatePlanView, "click:change:plan", ->
        modalLayout.close()
        App.navigate "upgrade", trigger: true

      @listenTo modalLayout, "modal:cancel", (item) ->
        modalLayout.close()

      @listenTo modalLayout, "modal:unsubmit", (obj) =>
        modalLayout.close()

        if @plan.get("plan_identifier") isnt "PROTRIAL"
          processView   = @getProcessModal @plan
          processLayout = App.request "modal:wrapper", processView
          App.modalRegion.show processLayout

          processLayout.$el.find(".modal-footer").remove()
          processLayout.$el.find(".close").remove()

          @addAgent agent, processLayout
        else
          @addAgent agent, modalLayout

    getProcessModal: (plan) ->
      new Manage.ProcessPayment
        model: plan

    getDeleteProcessModal: (plan) ->
      new Manage.ProcessDelete
        model: plan

    getModalUpdatePlan: (plan) ->
      new Manage.UpdatePlan
        model: plan

    getModalSites: (website) ->
      new Manage.Sites
        collection: website

    getManageAgentLayout: (model) ->
      new Manage.UpdateLayout
        model: model

    getAddAgentLayout: (model) ->
      new Manage.NewLayout
        model: model

    getLayoutView: ->
      new Manage.Layout

    getAgentsView: ->
      new Manage.Agents
        model:      @current_user
        collection: @agents