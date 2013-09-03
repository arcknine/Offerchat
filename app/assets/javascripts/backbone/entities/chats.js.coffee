@Offerchat.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.VisitorInfo extends App.Entities.Model
    urlRoot: Routes.visitors_path()
    generateGravatarSource: ->
      @set { gravatar: "https://www.gravatar.com/avatar/#{ MD5.hexdigest($.trim(@get("email")).toLowerCase()) }?s=100&d=mm" }

  class Entities.Visitor extends App.Entities.Model

    defaults:
      jid: "Visitor"
      unread: null
      active: null
      newClass: null
      new_chat: null
      bounce: null
      email: "piki_pare_erap@yahoo.com"
      gravatar: null

    generateGravatarSource: ->
      @set { gravatar: "https://www.gravatar.com/avatar/#{ MD5.hexdigest($.trim(@get("email")).toLowerCase()) }?s=100&d=mm" }

  class Entities.VisitorsCollection extends App.Entities.Collection
    model: Entities.Visitor

    comparator: (visitor) ->
      -visitor.get("unread")

  class Entities.Message extends App.Entities.Model

  class Entities.MessagesCollection extends App.Entities.Collection
    model: Entities.Message

  # class Entities.Message extends App.Entities.Model

  # class Entities.ChatLogCollection extends App.Entities.Collection
  #   model: Entities.Message
  #   url: "http://history.offerchat.com:9292/chats/nABOEJ0eFjJDXdNte-XW6A"

  class Entities.WindowHeight extends App.Entities.Model
    defaults:
      height: $(window).height()
      str_h:  ($(window).height() - 256)  + "px"

  class Entities.SelectedVisitor extends App.Entities.Model

  class Entities.Transcript extends App.Entities.Model

  class Entities.TotalUnreadMsgs extends App.Entities.Model
    defaults:
      read: 0
      unread: 0

  API =
    setVisitor: ->
      new Entities.Visitor

    getVisitorInfo: (id)->
      visitor = new Entities.VisitorInfo
      visitor.set id: id
      visitor.fetch
        id: id
        reset: true
      visitor

    visitors: ->
      new Entities.VisitorsCollection

    setMessage: (message) ->
      new Entities.Message message

    messages: ->
      new Entities.MessagesCollection

    windowHeight: ->
      new Entities.WindowHeight

    selectedVisitor: ->
      new Entities.SelectedVisitor

    getChatLogs: (chatlogs)->
      console.log "awa"
      chatlogs = new Entities.MessagesCollection
      chatlogs.url = "http://history.offerchat.com:9292/chats/nABOEJ0eFjJDXdNte-XW6A"
      chatlogs.fetch
        dataType : "jsonp"
        processData: true
        success: ->
          console.log "success...."
      chatlogs

    setTranscript: ->
      new Entities.Transcript

    totalUnreadMsgs: ->
      new Entities.TotalUnreadMsgs

  App.reqres.setHandler "visitor:entity", ->
    API.setVisitor()

  App.reqres.setHandler "visitors:entities", ->
    API.visitors()

  App.reqres.setHandler "message:entity", (message) ->
    API.setMessage message

  App.reqres.setHandler "messeges:entities", ->
    API.messages()

  App.reqres.setHandler "get:chat:window:height", ->
    API.windowHeight()

  App.reqres.setHandler "get:visitor:info:entity", (id)->
    API.getVisitorInfo(id)

  App.reqres.setHandler "get:chat:logs", (chatlogs)->
    API.getChatLogs(chatlogs)

  App.reqres.setHandler "transcript:entity", ->
    API.setTranscript()

  App.reqres.setHandler "total:unread:messages", ->
    API.totalUnreadMsgs()

