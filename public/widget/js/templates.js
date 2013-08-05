Templates = {
  init: function(options) {
    options       = options || {};
    this.params   = options.params;
    this.settings = options.settings;
    this.agents   = options.agents;
    this.website  = options.website;

    var _this = this;
    this.loadTemplates(function(){
      _this.layout.append();
      _this.header.append();
      _this.inputs.append();
      // _this.loader.append();

      if (_this.settings.pre_chat.enabled && !Offerchat.widget.prechat) {
        _this.prechat.replace();
        _this.inputs.destroy();
      } else if (Chats.messages.length > 0) {
        Chats.loadChats();
      }

    });
  },

  loadTemplates: function(callback) {
    var _this = this;

    this.layout = this.generateTemplate({
      section:   "body",
      template:  this.getLayout({
        gradient: this.settings.style.gradient ? "widget-gradient" : ""
      }),
      className: "widget-box widget-theme theme-" + this.settings.style.theme
    });

    this.header = this.generateTemplate({
      section:   "div.widget-head",
      template:  this.getHeader({
        agent_name:  this.agents[0].display_name,
        img:         this.agents[0].avatar,
        agent_label: _this.settings.online.agent_label
      }),
      tagName:   'span',
      events: {
        "click div.widget-head" : "toggleWidget",
      },
      toggleWidget: function() {
        $.postMessage({slide: true}, _this.params.current_url, parent);
        $(".tooltip-options").removeClass("open");
      }
    });

    this.inputs = this.generateTemplate({
      section:  "div#widget-input",
      template: this.getWidgetInputs(),
      // tagName:  'span',
      className: "widget-input",
      events:   {
        "click a.chat-settings"         : "toggleSettings",
        "click a.chat-rating"           : "toggleRating",
        "click input.widget-input-text" : "hideTooltips",
        "keyup input.widget-input-text" : "isTyping"
      },
      toggleSettings: function() {
        tooltip = $(".settings-options");
        if (tooltip.hasClass("open"))
          tooltip.removeClass("open");
        else{
          $(".tooltip-options").removeClass("open");
          tooltip.addClass("open");
        }
      },
      toggleRating: function() {
        tooltip = $(".rating-options");
        if (tooltip.hasClass("open"))
          tooltip.removeClass("open");
        else {
          $(".tooltip-options").removeClass("open");
          tooltip.addClass("open");
        }
      },
      hideTooltips: function() {
        $(".tooltip-options").removeClass("open");
      },
      isTyping: function(e) {
        Chats.sendChat(e, this);
      }
    });

    this.offline = this.generateTemplate({
      section:   "div.widget-chat-viewer",
      template:  this.getChatForms({
        description: this.settings.offline.description
      }),
      className: "widget-block",
      tagName:   "form",
      events: {
        "submit form.widget-block" : "submitOffline"
      },
      submitOffline: function(e) {
        _this.validateForms(this);
        return false;
      }
    });

    this.postchat = this.generateTemplate({
      section:   "div.widget-chat-viewer",
      template:  this.getChatForms({
        description: this.settings.post_chat.description
      }),
      className: "widget-block",
      tagName:   "form",
      events: {
        "submit form.widget-block" : "submitPostChat"
      },
      submitPostChat: function(e) {
        _this.validateForms(this);
        return false;
      }
    });

    this.prechat = this.generateTemplate({
      section:   "div.widget-chat-viewer",
      template:  this.getChatForms({
        description: this.settings.pre_chat.description,
        message_required: this.settings.pre_chat.message_required
      }),
      className: "widget-block",
      tagName:   "form",
      events: {
        "submit form.widget-block" : "submitPreChat"
      },
      submitPreChat: function(e) {
        var form = _this.validateForms(this);
        if (form) {
          // _this.loader.replace();
          _this.prechat.destroy();
          _this.inputs.replace();

          Offerchat.widget.prechat = true;
          localStorage.setItem("offerchat_widget", JSON.stringify(Offerchat.widget));
        }
        return false;
      }
    });


    this.loader = this.generateTemplate({
      section:   "div.widget-chat-viewer",
      template:  this.getConnecting(),
      className: "widget-connection-status"
    }, true);

    callback();
  },

  validateForms: function(form) {
    var data   = Helpers.unserialize($(form).serialize());
    var regex  = /^\s*$/;
    var retVal = true;
    $.each(data, function(key, value){
      val = decodeURIComponent(value).replace(/\+/g, " ");
      if (regex.test(val)) {
        $('[name=' + key + ']').parent().addClass("widget-field-error");
        retVal = false;
      }
      else {
        if(key == "email" && !Helpers.validateEmail(val)) {
          $('[name=' + key + ']').parent().addClass("widget-field-error");
          retVal = false;
        }
        else {
          $('[name=' + key + ']').parent().removeClass("widget-field-error");
          retVal = retVal ? true : false;
        }
      }
    });

    return retVal;
  },

  generateTemplate: function(options) {
    var obj = {
      options: options,

      init: function() {
        options           = this.options || {};
        options.tagName   = options.tagName ? options.tagName : "div";
        options.className = options.className ? ' class="' + options.className + '"' : "";
        options.template  = '<' + options.tagName  + options.className  + '>' + options.template + '</' + options.tagName + '>';

        if (options.events) {
          $.each(options.events, function(key, value){
            ev = key.split(" ");
            target = $.trim(ev[1]);
            evnt   = $.trim(ev[0]);
            $(document).on(evnt, target, options[value]);
          });
        }
      },

      destroy: function() {
        $(this.options.section + " > " + this.options.tagName).remove();
      },

      hide: function() {
        $(this.options.section + " > " + this.options.tagName).hide();
      },

      show: function() {
        $(this.options.section + " > " + this.options.tagName).show();
      },

      replace: function() {
        $(options.section).html(options.template);
      },

      append: function() {
        $(options.section).append(options.template);
      }
    };

    obj.init();

    return obj;
  },

  getLayout: function(data) {
    var data   = data || { gradient: "" };
    var layout = '<div class="widget-head widget-rounded-head group ' + data.gradient + '"></div>' +
                 '<div class="widget-body">' +
                 '  <div class="widget-chat-viewer"></div>' +
                 '  <div id="widget-input"></div>' +
                 '</div>';

    return layout;
  },

  getHeader: function(data) {
    var data   = data || {};
    var header = '<img alt="Agent-avatar1" class="agent-thumbnail" src="' + data.img + '">' +
                 // '<div class="widget-msg-count">' +
                 // '  <span>' + data.unread + '</span>' +
                 // '</div>' +
                 '<div class="widget-agent-name">' + data.agent_name + '</div>' +
                 '<div class="widget-welcome-msg">' + data.agent_label + '</div>';

    return header;
  },

  getWidgetInputs: function(data) {
    var inputs, data
    data   = data || { placeholder: "Type your question and hit enter" };
    inputs = '<ul class="tooltip-options settings-options">' +
             '  <li><a>Download transcript</a></li>' +
             '  <li><a>Turn off sound</a></li>' +
             '  <div class="footer-credits">powered by <a>Offerchat</a></div>' +
             '  <div class="caret"></div>' +
             '</ul>' +
             '<ul class="tooltip-options rating-options">' +
             '  <li><a><i class="widget icon icon-thumbs-up-green"></i></a></li>' +
             '  <li><a><i class="widget icon icon-thumbs-down-red"></i></a></li>' +
             '  <div class="caret"></div>' +
             '</ul>' +
             '<i class="widget icon icon-chat"></i>' +
             '<input class="widget-input-text" placeholder="' + data.placeholder + '" type="text">' +
             '<a class="chat-settings"><i class="widget icon icon-gear"></i></a>' +
             '<a class="chat-rating"><i class="widget icon icon-thumbs-up"></i></a>';

    return inputs;
  },

  getMessage: function(data) {
    var data = data || {};
    var msg  = '<div class="message-item">' +
               '  <div class="group">' +
               '    <div class="message-author agent-author">' + data.agent_name + '</div>' +
               '    <div class="message-date">' + data.time + '</div>' +
               '  </div>' +
               '  <div class="message">' + data.message + '</div>' +
               '</div>';

    return msg;
  },

  getConnecting: function(data) {
    var data = data || {message: "connecting you to an agent"};
    var conn = data.message +
               '<div class="widget-progress">' +
               '  <div class="widget-progress-bar"></div>' +
               '</div>';

    return conn;
  },

  getChatForms: function(data) {
    var data    = data || {};
    var forms   =  '<div class="widget-pre-message">' +
                      data.description +
                   '</div>' +
                   '<div class="widget-input-container">' +
                   '  <input placeholder="Name" name="name" type="text">' +
                   '</div>' +
                   '<div class="widget-input-container">' +
                   '  <input placeholder="Email" name="email" type="text">' +
                   '</div>';

    if (typeof data.message_required == "undefined" || data.message_required == true) {
      forms     += '<div class="widget-input-container">' +
                   '  <textarea name="message" placeholder="Message"></textarea>' +
                   '</div>';
    }

    forms       += '<div class="widget-input-container">' +
                   '  <button class="widget-button">Submit</button>' +
                   '</div>';

    return forms;
  },

  getMessageView: function(data) {
    var data = data || {};
    var message =  '  <div class="group">' +
                   '    <div class="message-author">' + data.sender + '</div>' +
                   '  </dvi>' +
                   '  <div class="message">' +
                   '    <div class="message-date">' + data.time + '</div>' +
                        data.message +
                   '  </div>';

    return message;
  }
};