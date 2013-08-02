@Offerchat.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.Visitor extends App.Entities.Model

    defaults:
      jid: "Visitor"
      unread: null
      active: null
      new_chat: null
      bounce: null
      email: "piki_pare_erap@yahoo.com"
      gravatar: null

    addUnread: ->
      if @get('unread') is null then @set new_chat: 'bounce1', bounce: 'bounce'
      @set unread: @get('unread') + 1

      setTimeout (=>
        @set {new_chat: null}
      ), 1000

      setTimeout (=>
        @set {bounce: null}
      ), 10000

    generateGravatarSource: ->
      @set { gravatar: "https://www.gravatar.com/avatar/#{ MD5.hexdigest($.trim(@get("email")).toLowerCase()) }?s=100&d=mm" }

  class Entities.VisitorsCollection extends App.Entities.Collection
    model: Entities.Visitor

    comparator: (visitor) ->
      -visitor.get("unread")

  class Entities.Message extends App.Entities.Model

  class Entities.MessagesCollection extends App.Entities.Collection
    model: Entities.Message

  API =
    setVisitor: ->
      new Entities.Visitor

    visitors: ->
      new Entities.VisitorsCollection

    setMessage: (message) ->
      new Entities.Message message

    messages: ->
      new Entities.MessagesCollection

  App.reqres.setHandler "visitor:entity", ->
    API.setVisitor()

  App.reqres.setHandler "visitors:entities", ->
    API.visitors()

  App.reqres.setHandler "message:entity", (message) ->
    API.setMessage message

  App.reqres.setHandler "messeges:entities", ->
    API.messages()
