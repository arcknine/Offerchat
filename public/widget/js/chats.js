Chats = {
  connection: null,
  reconnect:  false,
  is_attach:  false,
  reload_app: null,
  has_conversation: false,

  messages: JSON.parse(localStorage.getItem("ofc-messages")) || [],
  agents:   JSON.parse(sessionStorage.getItem("offerchat_agents")) || [],

  init: function() {
    var _this = this, attach, details;

    this.agent    = Offerchat.agent({website_id: Offerchat.website.id}).first();
    this.roster   = Offerchat.roster({website_id: Offerchat.website.id}).first();
    this.details  = Offerchat.details({id: Offerchat.website.id}).first();
    this.visitor  = Offerchat.visitor({website_id: Offerchat.website.id}).first();
    this.settings = Offerchat.website.settings;

    if (this.details.connect !== false) {
       Templates.loader.replace();
      $(".widget-input-text").attr("disabled", "disabled");

      this.getAvailableRoster(function(){
        attach  = JSON.parse(sessionStorage.getItem("offerchat-credential"));
        if (attach && attach.jid && attach.rid && attach.sid)
          _this.attach();
        else
          _this.connect();
      });
    } else {
      console.log(this.details);
      if (this.details.chatend === true) {
        var reconnect = Templates.reconnect;
        reconnect.options.template = Templates.getReconnect({
          message: "Your chat session has ended",
          button:  "Connect"
        });
        reconnect.replace();
      } else {
        Templates.reconnect.replace();
      }
      this.loadChats();
    }

  },

  getAvailableRoster: function(callback) {
    var _this = this, roster, info;
    roster  = this.roster;
    visitor = this.roster;
    info    = this.details;

    if (!roster) {
      loc = [info.city, info.location];
      $.ajax({
        type: "GET",
        url:  Offerchat.src.api_url + "checkin/" + Offerchat.params.secret_token + ".jsonp",
        data: { name: info.name, browser: info.browser, location: loc.join(", ", loc), email: info.email, operating_system: info.OS, country_code: info.code },
        dataType: "jsonp",
        success: function(data) {
          if (typeof data.error == "undefined") {
            $(".widget-input-text").removeAttr("disabled");
            data.roster.last_used = new Date().getTime();
            Offerchat.roster.insert(data.roster);

            if (!visitor)
              Offerchat.visitor.insert(data.visitor);
            else
              Offerchat.visitor({website_id: Offerchat.website.id}).update(data.visitor);

            _this.roster  = data.roster;
            _this.visitor = data.visitor;

            Templates.loader.destroy();
            callback();
          } else if (data.error == "Offline") {
            setTimeout(function(){
              _this.getAvailableRoster(callback);
            }, 20000);
          }
        }
      });
    } else {
      var time_now  = new Date().getTime();
      var attach    = JSON.parse(sessionStorage.getItem("offerchat-credential"));
      var time_diff = Math.ceil((time_now - roster.last_used) / 1000);

      if (time_diff > 600 && !attach) {
        Offerchat.roster({website_id: Offerchat.website.id}).remove();
        this.getAvailableRoster(callback);
      } else {
        $(".widget-input-text").removeAttr("disabled");
        Templates.loader.destroy();
        callback();
      }
    }
  },

  connect: function() {
    var _this, jid, password, bosh_url, roster;

    _this    = this;
    roster   = this.roster;
    bosh_url = Offerchat.src.bosh_url;
    jid      = roster.jabber_user + Offerchat.src.server + "/" + Helpers.randomString();
    password = roster.jabber_password;

    this.connection = new Strophe.Connection(bosh_url);
    this.connection.connect(jid, password, function(status) {
      if (status === Strophe.Status.CONNECTED) {
        _this.reconnect = true;
        _this.connected();
      }
      else if (status === Strophe.Status.DISCONNECTED && _this.reconnect === true) {
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
      else if (status === Strophe.Status.DISCONNECTED && _this.reconnect === true) {
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
    this.sendPreChatMsg();
  },

  sendPreChatMsg: function() {
    var _this = this;

    var details = Offerchat.details({id: Offerchat.website.id}).first();
    if (this.details.prechat === true && details.message) {
      this.getAgent(function(agent) {
        if (agent) {
          _this.xmppSendMsg(_this.details.message, agent, "You");
          _this.details.message = null;

          Offerchat.details({id: Offerchat.website.id}).remove();
          Offerchat.details.insert(_this.details);
        } else {
          Templates.offline.replace();
          Templates.inputs.hidden();
          _this.disconnect();
        }
      });
    }
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
    widget  = this.details;
    roster  = this.roster;
    visitor = this.visitor;
    agent   = this.agent;

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
        status: agent ? true : agent,
        agent:  agent ? agent.jabber_user : "",
        name:   agent ? agent.display_name : ""
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

    agent  = Chats.agent;
    roster = Chats.roster;

    if (node != roster.jabber_user) {
      if (node == agent.node)
        clearInterval(Chats.reload_app);

      if (agent.node == node && type == "unavailable") {
        index = $.inArray(node, Chats.agents);
        if (index > -1) Chats.agents.splice(index, 1);

        Chats.reload_app = setTimeout(function(){
          Offerchat.agent({website_id: Offerchat.website.id}).remove();
          Chats.agent = Offerchat.agent({website_id: Offerchat.website.id}).first();

          clearInterval(Chats.reload_app);
        }, 15000);
      } else if (type == "unavailable" || show == "away") {
        index = $.inArray(node, Chats.agents);
        if (index > -1) Chats.agents.splice(index, 1);
      }

      if (!type && node != agent.jabber_user && (!show || show == 'chat' || show == 'online') && $.inArray(node, Chats.agents) < 0) {
        Chats.agents.push(node);
      }

      sessionStorage.setItem("offerchat_agents", JSON.stringify(Chats.agents));
    }

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
      if (Chats.settings.post_chat.enabled) {
        Templates.postchat.replace();
        Templates.inputs.hidden();
      } else {
        var reconnect = Templates.reconnect;
        reconnect.options.template = Templates.getReconnect({
          message: "Your chat session has ended",
          button:  "Connect"
        });
        reconnect.replace();
      }

      Offerchat.details({id: Offerchat.website.id}).update({connect: false, chatend: true});
      Offerchat.roster({website_id: Offerchat.website.id}).remove();
      Offerchat.agent({website_id: Offerchat.website.id}).remove();

      Chats.roster  = Offerchat.roster({website_id: Offerchat.website.id}).first();
      Chats.agent   = Offerchat.agent({website_id: Offerchat.website.id}).first();
      Chats.details = Offerchat.details({id: Offerchat.website.id}).first();
      // Chats.details.connect = false;
      // Chats.details.chatend = true;

      // _this.disconnect();
    } else if (body.length > 0) {
      var a = Chats.agent;
      console.log(a);
      if (!a || a.jabber_user != agent) {
        var agents = Offerchat.website.agents;
        $.each(agents, function(key, value){
          if (agent == value.jabber_user) {
            a = value;
            a.website_id = Offerchat.website.id;

            Offerchat.agent({website_id: Offerchat.website.id}).remove();
            Offerchat.agent.insert(a);
            Chats.agent = Offerchat.agent({website_id: Offerchat.website.id}).first();

            var header = Templates.header;
            header.options.template = Templates.getHeader({
              agent_name:  Chats.agent.display_name,
              img:         Chats.agent.avatar,
              agent_label: Offerchat.website.settings.online.agent_label
            });

            header.replace();

            //create chat history conversation
            $.ajax({
              type: "GET",
              url: Offerchat.src.history + "/chats/create/" + Offerchat.params.secret_token,
              dataType: "jsonp",
              data: {url: Offerchat.params.current_url, aid: Chats.agent.id, vname: Chats.visitor.name},
            });
          }
        });
      }

      var msg = Chats.generateMessage(body, a.display_name);

      try {
        var sound = document.getElementById("beep-notify");
        if (sound)
          sound.play();
      } catch(e) {}

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
        if (typeof this.messages[i + 1] != "undefined" && this.messages[i + 1].child === true) {
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
    });

    $(".widget-chat-viewer").animate({ scrollTop: $('.widget-chat-viewer')[0].scrollHeight}, 300);
    localStorage.setItem("ofc-messages", JSON.stringify(this.messages));
  },

  sendChat: function(ev, input) {
    var message = $(input).val();
    if (ev.keyCode == 13) {
      var _this = this;

      this.getAgent(function(agent) {
        if (agent) {
          _this.xmppSendMsg(message, agent, "You");
        } else {
          Templates.offline.replace();
          Templates.inputs.hidden();
          _this.disconnect();
        }
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
    var agent = this.agent;
    if (!agent) {
      selected_agent = this.agents[Math.floor(Math.random() * this.agents.length)];
      $.each(Offerchat.website.agents, function(key, value){
        if (value.jabber_user == selected_agent) {
          agent = value;
          agent.website_id = Offerchat.website.id;
          Offerchat.agent.insert(value);

          //create chat history conversation
          $.ajax({
            type: "GET",
            url: Offerchat.src.history + "/chats/create/" + Offerchat.params.secret_token,
            dataType: "jsonp",
            data: {url: Offerchat.params.current_url, aid: Chats.agent.id, vname: Chats.visitor.name},
          });
        }
      });

      $(".widget-input-text").attr("disabled", "disabled");
      Templates.loader.replace();

      setTimeout(function(){
        Templates.loader.destroy();
        $(".widget-input-text").removeAttr("disabled");

        var header = Templates.header;
        header.options.template = Templates.getHeader({
          agent_name:  agent.display_name,
          img:         agent.avatar,
          agent_label: Offerchat.website.settings.online.agent_label
        });

        header.replace();

        _this.loadChats();
        _this.agent = agent;
        callback(agent);
      }, 2000);
    } else {
      callback(agent);
    }
  },

  generateMessage: function(message, sender) {
    var cur, msg, d, chat, classTag;
    cur = this.messages.length;
    d   = new Date();

    message = message.replace("!trigger ", "");

    classTag = sender != "You" ? " agent-message" : "";
    if (cur !== 0 && this.messages[cur - 1].sender == sender) {
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


    this.initChatHistory(sender, message);
    return msg;
  },

  initChatHistory: function(sender, message) {
    var a_name = this.agent.name ? this.agent.name : this.agent.display_name;
    var name   = sender == "You" ? this.visitor.name : a_name;

    $.ajax({
      type: "GET",
      url: Offerchat.src.history + "/chats/" + Offerchat.params.secret_token,
      dataType: "jsonp",
      data: { sender: name, msg: message }
    });

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
          var message = "!trigger ";
          switch(value.rule_type) {
            case 1:
              if (!rule2 && !rule3 && _this.messages.length === 0) {
                _this.getAgent(function(agent) {
                  _this.xmppSendMsg(message + value.message, agent, agent.display_name);
                });
              }
              break;
            case 2:
              if (!rule3 && value.params.url == Offerchat.params.current_url && _this.messages.length === 0) {
                _this.getAgent(function(agent) {
                  _this.xmppSendMsg(message + value.message, agent, agent.display_name);
                });
              }
              break;
            case 3:
              if (value.params.url == Offerchat.params.current_url && _this.messages.length === 0) {
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
    roster    = Offerchat.roster({website_id: Offerchat.website.id}).first();

    interval = setInterval( function() {
      last_used = roster.last_used;
      last_msg  = _this.messages.length > 0 ? _this.messages[_this.messages.length - 1].created_at : null;

      time = last_msg && last_msg > last_used ? last_msg : last_used;
      now  = new Date().getTime();
      time_diff = Math.ceil((now - time) / 1000);


      // will disconnect on 5mins
      if (time_diff > 420 && _this.connection !== null) {
        Offerchat.details({id: Offerchat.website.id}).update({connect: false});
        Offerchat.roster({website_id: Offerchat.website.id}).remove();
        Offerchat.agent({website_id: Offerchat.website.id}).remove();

        this.roster  = Offerchat.roster({website_id: Offerchat.website.id}).first();
        this.agent   = Offerchat.agent({website_id: Offerchat.website.id}).first();
        this.details = Offerchat.details({id: Offerchat.website.id}).first();
        // this.details.connect = false;

        _this.disconnect();
        Templates.reconnect.replace();
        clearInterval(interval);
      } else if (_this.connection === null)
        clearInterval(interval);
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