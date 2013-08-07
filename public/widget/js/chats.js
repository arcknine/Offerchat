Chats = {
  connection: null,
  reconnect:  false,
  is_attach:  false,
  reload_app: null,

  messages: JSON.parse(localStorage.getItem("ofc-messages")) || [],
  roster:   TAFFY(),
  visitor:  TAFFY(),
  agent:    TAFFY(),
  agents:   [],

  init: function() {
    var _this = this, attach;
    console.log(Offerchat);


    this.roster.store('roster');
    this.visitor.store('visitor');
    this.agent.store('agent');
    this.loadChats();

    this.getAvailableRoster(function(){
      // sud dri?
      attach = JSON.parse(sessionStorage.getItem("offerchat-credential"));
      if (attach && attach.jid && attach.rid && attach.sid)
        _this.attach();
      else
        _this.connect();
    });
  },

  getAvailableRoster: function(callback) {
    var _this = this, roster, info;
    roster  = this.roster({website_id: Offerchat.website.id}).first();
    visitor = this.visitor({website_id: Offerchat.website.id}).first();
    info    = Offerchat.details({id: Offerchat.website.id}).first();
    if (!roster) {
      loc = [info.city, info.location];
      $.ajax({
        type: "GET",
        url:  Offerchat.src.api_url + "checkin/" + Offerchat.params.secret_token + ".jsonp",
        data: { browser: info.browser, location: loc.join(", ", loc), browser: info.browser },
        dataType: "jsonp",
        success: function(data) {
          if (typeof data.error == "undefined") {
            data.roster.last_used = new Date().getTime();
            _this.roster.insert(data.roster);

            if (!visitor)
              _this.visitor.insert(data.visitor);
            else
              _this.visitor({website_id: Offerchat.website.id}).update(data.visitor);

            callback();
          }
        }
      });
    } else {
      var time_now  = new Date().getTime();
      var attach    = JSON.parse(sessionStorage.getItem("offerchat-credential"));
      var time_diff = Math.ceil((time_now - roster.last_used) / 1000);

      if (time_diff > 600 && !attach) {
        this.roster({website_id: Offerchat.website.id}).remove();
        this.getAvailableRoster(callback);
      } else {
        this.roster({website_id: Offerchat.website.id}).update({last_used: time_now});
        callback();
      }
    }
  },

  connect: function() {
    var _this, jid, password, bosh_url, roster;

    _this    = this;
    roster   = this.roster({website_id: Offerchat.website.id}).first()
    bosh_url = Offerchat.src.bosh_url;
    jid      = roster.jabber_user + Offerchat.src.server + "/" + Helpers.randomString();
    password = roster.jabber_password;

    this.connection = new Strophe.Connection(bosh_url);
    this.connection.connect(jid, password, function(status) {
      if (status === Strophe.Status.CONNECTED) {
        _this.reconnect = true;
        _this.connected();
      }
      else if (status === Strophe.Status.DISCONNECTED && _this.reconnect == true) {
        _this.disconnect();
        _this.connect();
      }
    });
  },

  attach: function() {
    var _this, bosh_url, attach;
    _this    = this;
    bosh_url = Offerchat.src.bosh_url;
    attach   = JSON.parse(sessionStorage.getItem("offerchat-credential"));

    _this.connection = new Strophe.Connection(bosh_url);
    _this.connection.attach(attach.jid, attach.sid, attach.rid, function(status) {
      if (status === Strophe.Status.ATTACHED) {
        _this.is_attach = true;
        _this.reconnect = true;
        _this.connected();
      }
      else if (status === Strophe.Status.DISCONNECTED && _this.reconnect == true) {
        // _this.disconnect();
        _this.connect();
      }
    });
  },

  connected: function() {
    var _this = this;
    this.connection.roster.init(this.connection);
    this.connection.vcard.init(this.connection);
    this.connection.addHandler(this.onPresence, null, "presence");
    this.connection.addHandler(this.onPrivateMessage, null, "message", "chat");
    // this.connection.addHandler(this.on_message, null, "message");
    // this.connection.addHandler(this.on_iq, null, "iq");

    this.connection.xmlInput = function (data) {
      // console.log(data);
      // _this.onPresence($(data).find("presence"))
    };

    this.sendPresence();
  },

  setCredentials: function() {
    var credentials;
    if (this.connection && this.reconnect === true) {
      credentials = {
        jid: this.connection.jid,
        rid: this.connection.rid,
        sid: this.connection.sid
      };
      sessionStorage.setItem('offerchat-credential', JSON.stringify(credentials));
    }
    else
      sessionStorage.removeItem('offerchat-credential');
  },

  sendPresence: function() {
    var details, widget, roster, visitor, client_details;
    widget  = Offerchat.details({id: Offerchat.website.id}).first()
    roster  = this.roster({website_id: Offerchat.website.id}).first();
    visitor = this.visitor({website_id: Offerchat.website.id}).first();

    console.log(Offerchat.params);

    details = {
      api_key:  Offerchat.params.api_key,
      url:      Offerchat.params.current_url,
      title:    (Offerchat.params.page_title).replace(/\+/g," "),
      referrer: Offerchat.params.referrer,
      location: [widget.city, widget.location].join(", "),
      ccode:    widget.code,
      browser:  widget.browser,
      version:  widget.version,
      OS:       widget.OS,
      IP:       visitor.ipaddress,
      name:     visitor.name,
      email:    visitor.email,
      chatting: {
        status: true,
        agent:  "keenan@local.offerchat.com",
        name:   "Keenan"
      }
    };

    client_details = "Online\nViewing: " + details.url +
                     "\nLocation: " + details.location +
                     "\nOS: " + details.OS +
                     "\nBrowser: " + details.browser + ' ' + details.version;

    if (details.chatting.status)
      client_details += "\nChatting with: " + details.chatting.name;

    details = JSON.stringify(details);
    pres    = $pres().c('priority').t('1').up().c('status').t(client_details).up().c('offerchat').t(details);
    this.connection.send(pres.tree());

    return true;
  },

  onPresence: function(presence) {
    var pres, from, type, show, jid, node, agent, index;
    pres = $(presence);
    from = pres.attr('from');
    type = pres.attr('type');
    show = pres.find('show').text();
    jid  = Strophe.getBareJidFromJid(from);
    node = Strophe.getNodeFromJid(from);
    res  = Strophe.getResourceFromJid(from);

    // console.log(type);

    // agent = Offerchat.agent({website_id: Offerchat.widget.website.id}).first();

    return true;
  },

  onPrivateMessage: function(message) {
    var agent, body, comp, ended, from, html, paused, trnsfr;

    from   = $(message).attr("from");
    comp   = $(message).find("composing");
    paused = $(message).find("paused");
    ended  = $(message).find("inactive");
    trnsfr = $(message).find("transfer");
    body   = $(message).find("body").text();
    html   = $(message).find("html > body").html();
    body   = html || body;
    agent  = Strophe.getNodeFromJid(from);

    if (comp.length > 0) {
      // composing chat codes
    } else if (paused.length > 0) {
      // paused chat codes
    } else if (trnsfr.length > 0 || body == '!transfer') {
      // transfer chat codes
    } else if (ended.length || body == "!endchat") {
      // chat ened code
    } else if (body.length > 0) {
      var a = Chats.agent({website_id: Offerchat.website.id, jabber_user: agent}).first();
      if (!a) {
        var agents = Offerchat.website.agents
        $.each(agents, function(key, value){
          if (agent == value.jabber_user) {
            a = value;
            a.website_id = Offerchat.website.id;

            Chats.agent({website_id: Offerchat.website.id}).remove();
            Chats.agent.insert(a);
          }
        });
      }

      var msg = Chats.generateMessage(body, a.display_name);
    }

    return true;
  },

  loadChats: function() {
    var _this = this;
    var msg   = this.messages.slice();
    var keys  = [];

    for(var i = this.messages.length - 1; i >= 0; i--) {
      var time_diff = Math.ceil((new Date().getTime() - msg[i].created_at) / 1000);
      if (time_diff > 259200) {
        if (typeof this.messages[i + 1] != "undefined" && this.messages[i + 1].child == true) {
          this.messages[i + 1].child = false;
          this.messages[i + 1].class = "";
        }
        this.messages.splice(i, 1);
      }
    }

    $.each(this.messages, function(key, value){
      var chat = Templates.generateTemplate({
        section:   "div.widget-chat-viewer",
        template:  Templates.getMessageView(value),
        className: "message-item" + value.class
      });

      chat.append();
      $(".widget-chat-viewer").scrollTop($('.widget-chat-viewer')[0].scrollHeight);
    });

    localStorage.setItem("ofc-messages", JSON.stringify(this.messages));
  },

  sendChat: function(ev, input) {
    var message = $(input).val();
    if (ev.keyCode == 13) {
      var msg, from, to, conn, active, agent;
      agent = this.agent({website_id: Offerchat.website.id}).first();
      msg   = this.generateMessage(message, "You");
      conn  = this.connection;

      to     = agent.jabber_user + Offerchat.src.server + "/ofc-widget";
      msg    = $msg({to: to, type: "chat", id: conn.getUniqueId("chat")}).c("body").t(message).up().c("active", {xmlns: "http://jabber.org/protocol/chatstates"});
      active = $msg({to: to, type: "chat", id: conn.getUniqueId("active")}).c("active", {xmlns: "http://jabber.org/protocol/chatstates"});

      conn.send(msg.tree());
      setTimeout(function() {
        conn.send(active.tree());
      }, 100);

      $(input).val("");
    } else {

    }
  },

  generateMessage: function(message, sender) {
    var cur, msg, d, chat, classTag;
    cur = this.messages.length;
    d   = new Date();
    classTag = sender != "You" ? " agent-message" : "";
    if (cur != 0 && this.messages[cur - 1].sender == sender) {
      msg = {
        web_id:     Offerchat.website.id,
        message:    message,
        sender:     sender,
        child:      true,
        class:      " group-author-item" + classTag,
        time:       moment().format('hh:mma'),
        created_at: d.getTime()
      };
    } else {
      msg = {
        web_id:     Offerchat.website.id,
        message:    message,
        sender:     sender,
        child:      false,
        class:      "" + classTag,
        time:       moment().format('hh:mma'),
        created_at: d.getTime()
      };
    }

    this.messages.push(msg);
    localStorage.setItem("ofc-messages", JSON.stringify(this.messages));

    chat = Templates.generateTemplate({
      section:   "div.widget-chat-viewer",
      template:  Templates.getMessageView(msg),
      className: "message-item" + msg.class
    });

    chat.append();

    $(".widget-chat-viewer").animate({ scrollTop: $('.widget-chat-viewer')[0].scrollHeight}, 300);
    return msg;
  }
};

$(window).bind("unload", function(e) {
  Chats.setCredentials();
});

window.onbeforeunload = function(e) {
  $(window).unbind("unload");

  Chats.setCredentials();
};