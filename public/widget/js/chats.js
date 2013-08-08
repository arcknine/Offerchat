Chats = {
  connection: null,
  reconnect:  false,
  is_attach:  false,
  reload_app: null,

  messages: JSON.parse(localStorage.getItem("ofc-messages")) || [],
  roster:   TAFFY(),
  visitor:  TAFFY(),
  agent:    TAFFY(),
  agents:   JSON.parse(sessionStorage.getItem("offerchat_agents")) || [],

  init: function() {
    var _this = this, attach, details;

    Templates.loader.replace();
    $(".widget-input-text").attr("disabled", "disabled");

    this.roster.store('roster_db');
    this.visitor.store('visitor_db');
    this.agent.store('agent_db');

    details = Offerchat.details({id: Offerchat.website.id}).first();
    if (details.connect != false) {
      this.getAvailableRoster(function(){
        attach  = JSON.parse(sessionStorage.getItem("offerchat-credential"));
        if (attach && attach.jid && attach.rid && attach.sid)
          _this.attach();
        else
          _this.connect();
      });
    } else {
      Templates.reconnect.replace();
    }


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
            $(".widget-input-text").removeAttr("disabled");
            data.roster.last_used = new Date().getTime();
            _this.roster.insert(data.roster);

            if (!visitor)
              _this.visitor.insert(data.visitor);
            else
              _this.visitor({website_id: Offerchat.website.id}).update(data.visitor);

            Templates.loader.destroy();
            callback();
          } else if (data.error == "Offline") {
            setTimeout(function(){
              _this.getAvailableRoster(callback);
            }, 20000)
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
        $(".widget-input-text").removeAttr("disabled");
        Templates.loader.destroy();

        // this.roster({website_id: Offerchat.website.id}).update({last_used: time_now});
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

  disconnect: function () {
    // Switch to using synchronous requests since this is typically called onUnload.
    this.reconnect = false;

    try {
      this.connection.sync = true;
      this.connection.flush();
      this.connection.disconnect();
      this.connection = null;

      sessionStorage.removeItem("offerchat-credential");
    }
    catch (e) {}
  },

  connected: function() {
    var _this = this;
    this.connection.roster.init(this.connection);
    this.connection.vcard.init(this.connection);
    this.connection.addHandler(this.onPresence, null, "presence");
    this.connection.addHandler(this.onPrivateMessage, null, "message", "chat");
    // this.connection.addHandler(this.on_message, null, "message");
    // this.connection.addHandler(this.on_iq, null, "iq");

    // show chats if connected
    $(".widget-input-text").removeAttr("disabled");
    Templates.loader.destroy();

    this.sendPresence();
    this.initTriggers();
    this.initTimeOut();
    this.loadChats();
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

    details = {
      api_key:  Offerchat.params.api_key,
      url:      Offerchat.params.current_url,
      token:    Offerchat.params.secret_token,
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
    var pres, from, type, show, jid, node, agent, index, current_agent;
    pres = $(presence);
    from = pres.attr('from');
    type = pres.attr('type');
    show = pres.find('show').text();
    jid  = Strophe.getBareJidFromJid(from);
    node = Strophe.getNodeFromJid(from);
    res  = Strophe.getResourceFromJid(from);

    agent = Chats.agent({website_id: Offerchat.website.id}).first();

    if (!type && node != agent.jabber_user && (!show || show == 'chat') && $.inArray(jid, node) < 0) {
      Chats.agents.push(node);
    }
    sessionStorage.setItem("offerchat_agents", JSON.stringify(Chats.agents));

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

    // console.log("wtf??");

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

    // console.log(this.messages);

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
      var _this = this;

      this.getAgent(function(agent) {
        _this.xmppSendMsg(message, agent, "You");
      });

      $(input).val("");
    } else {

    }
  },

  xmppSendMsg: function(message, agent, sender) {
    var msg, to, active, conn;
    conn   = this.connection;
    msg    = this.generateMessage(message, sender);
    to     = agent.jabber_user + Offerchat.src.server + "/ofc-widget";
    msg    = $msg({to: to, type: "chat", id: conn.getUniqueId("chat")}).c("body").t(message).up().c("active", {xmlns: "http://jabber.org/protocol/chatstates"});
    active = $msg({to: to, type: "chat", id: conn.getUniqueId("active")}).c("active", {xmlns: "http://jabber.org/protocol/chatstates"});

    conn.send(msg.tree());
    setTimeout(function() {
      conn.send(active.tree());
    }, 100);
  },

  getAgent: function(callback) {
    var _this = this;
    var agent = Chats.agent({website_id: Offerchat.website.id}).first();
    if (!agent) {
      selected_agent = this.agents[Math.floor(Math.random() * this.agents.length)];
      $.each(Offerchat.website.agents, function(key, value){
        if (value.jabber_user == selected_agent) {
          agent = value;
          agent.website_id = Offerchat.website.id;
          _this.agent.insert(value);
        }
      });

      $(".widget-input-text").attr("disabled", "disabled");
      Templates.loader.replace();

      setTimeout(function(){
        Templates.loader.destroy();
        $(".widget-input-text").removeAttr("disabled");

        callback(agent);
      }, 2000)
    } else {
      // console.log($(Templates.inputs.options.template).find("input.widget-input-text").attr("placeholder"));
      // console.log("template", Templates.inputs.options.template);
      callback(agent);
    }
  },

  generateMessage: function(message, sender) {
    var cur, msg, d, chat, classTag;
    cur = this.messages.length;
    d   = new Date();

    message = message.replace("/me chat-trigger: ", "");

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
  },

  initTriggers: function() {
    var _this    = this,
        triggers = Offerchat.website.settings.triggers,
        rule2    = false,
        rule3    = false,
        conn     = this.connection;

    $.each(triggers, function(key, value) {

      if (value.rule_type == 2 && value.params.url == Offerchat.params.current_url)
        rule2 = true;
      else if (value.rule_type == 3 && value.params.url == Offerchat.params.current_url)
        rule3 = true;

      var time = value.rule_type == 3 ? 10000 : parseInt(value.params.time) * 1000;

      if ( value.status == 1 ) {
        setTimeout(function(){
          var message = "/me chat-trigger: ";
          switch(value.rule_type) {
            case 1:
              if (!rule2 && !rule3 && _this.messages.length == 0) {
                _this.getAgent(function(agent) {
                  _this.xmppSendMsg(message + value.message, agent, agent.display_name);
                });
              }
              break;
            case 2:
              if (!rule3 && value.params.url == Offerchat.params.current_url && _this.messages.length == 0) {
                _this.getAgent(function(agent) {
                  _this.xmppSendMsg(message + value.message, agent, agent.display_name);
                });
              }
              break;
            case 3:
              if (value.params.url == Offerchat.params.current_url && _this.messages.length == 0) {
                _this.getAgent(function(agent) {
                  _this.xmppSendMsg(message + value.message, agent, agent.display_name);
                });
              }
              break;
          }
        }, time);

      } // end if

    }); // end each

  },

  initTimeOut: function() {
    var roster, last_used, last_msg, time, now, time_diff, _this = this;
    roster    = this.roster({website_id: Offerchat.website.id}).first();

    interval = setInterval( function() {
      last_used = roster.last_used;
      last_msg  = _this.messages.length > 0 ? _this.messages[_this.messages.length - 1].created_at : null;

      time = last_msg && last_msg > last_used ? last_msg : last_used;
      now  = new Date().getTime();
      time_diff = Math.ceil((now - time) / 1000);

      // will disconnect on 5mins
      if (time_diff > 300) {
        Offerchat.details({id: Offerchat.website.id}).update({connect: false});
        _this.roster({website_id: Offerchat.website.id}).remove();
        localStorage.removeItem("offerchat_roster")
        _this.disconnect();

        Templates.reconnect.replace();
        clearInterval(interval);
      }
    }, 5000);
  }
};

$(window).bind("unload", function(e) {
  Chats.setCredentials();
});

window.onbeforeunload = function(e) {
  $(window).unbind("unload");

  Chats.setCredentials();
};