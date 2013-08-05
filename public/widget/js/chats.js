Chats = {
  connection: null,
  messages:   JSON.parse(localStorage.getItem("ofc-messages")) || [],

  init: function() {
    // this.connect();
    // console.log(Offerchat.src);
    console.log(Offerchat.params);
    this.getAvailableRoster(function(){
      // sud dri?
    });
  },

  getAvailableRoster: function(callback) {
    console.log("test?");
    $.ajax({
      type: "GET",
      url:  Offerchat.src.api_url + "checkin/" + Offerchat.params.secret_token + ".jsonp",
      dataType: "jsonp",
      success: function(data) {
        if (typeof data.error == "undefined") {
          console.log(data);
          callback();
        }
      }
    });
  },

  connect: function() {
    console.log("test")
    var _this, jid, password, bosh_url;
    _this    = this;
    bosh_url = Offerchat.src.bosh_url;
    // jid      = _this.widget.visitor.jabber_id + _this.defaults.server + "/" + Ofc_helpers.randomString();
    // password = _this.widget.visitor.password;

    jid      = Offerchat.src.server.replace("@", "");
    password = null;

    _this.connection = new Strophe.Connection(bosh_url);
    _this.connection.connect(jid, password, function(status) {
      if (status === Strophe.Status.CONNECTED) {
        _this.reconnect = true;
        // _this.connected();
        _this.connection.send($pres({to: "21373250856@local.offerchat.com"}));
      }
      else if (status === Strophe.Status.DISCONNECTED && _this.reconnect == true) {
        _this.disconnect();
        _this.connect();
      }
    });
  },

  loadChats: function() {
    var _this = this;
    var msg   = this.messages.slice();
    var keys  = [];

    for(var i = this.messages.length - 1; i >= 0; i--) {
      var time_diff = Math.ceil((new Date().getTime() - msg[i].created_at) / 1000);
      console.log(time_diff);
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
    });

    localStorage.setItem("ofc-messages", JSON.stringify(this.messages));
  },

  sendChat: function(ev, input) {
    var message = $(input).val();

    if (ev.keyCode == 13) {
      var cur = this.messages.length;
      var d = new Date();

      if (cur != 0 && this.messages[cur - 1].sender == "You") {
        var cur_msg = {
          web_id:     Offerchat.website.id,
          message:    message,
          sender:     "You",
          child:      true,
          class:      " group-author-item",
          time:       moment().format('hh:mma'),
          created_at: d.getTime()
        };
      } else {
        var cur_msg = {
          web_id:     Offerchat.website.id,
          message:    message,
          sender:     "You",
          child:      false,
          class:      "",
          time:       moment().format('hh:mma'),
          created_at: d.getTime()
        };
      }

      console.log(cur_msg)
      this.messages.push(cur_msg);
      var chat = Templates.generateTemplate({
        section:   "div.widget-chat-viewer",
        template:  Templates.getMessageView(cur_msg),
        className: "message-item" + cur_msg.class
      });

      localStorage.setItem("ofc-messages", JSON.stringify(this.messages));
      chat.append();

      $(input).val("");
    } else {

    }
  }
};