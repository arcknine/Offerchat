Templates = {
  init: function(options) {
    options       = options || {};
    this.params   = options.params;
    this.settings = options.settings;
    this.agents   = options.agents;
    this.agent    = Offerchat.agent({website_id: Offerchat.website.id}).first();
    this.details  = Offerchat.details({id: Offerchat.website.id}).first();

    var _this = this;
    this.loadTemplates(function(){
      _this.layout.append();
      _this.header.append();
      _this.inputs.append();
      _this.footer.append();

      if (Offerchat.any_agents_online === false && !_this.agent) {
        _this.offline.replace();
        _this.inputs.hidden();
        Chats.disconnect();

        if (_this.settings.offline.enabled)
          $.postMessage({show: true}, Offerchat.params.current_url, parent);
      } else if (_this.settings.pre_chat.enabled && !_this.details.prechat) {
        _this.prechat.replace();
        _this.inputs.hidden();

        $.postMessage({show: true}, Offerchat.params.current_url, parent);
      } else {
        Chats.init();
        $.postMessage({show: true}, Offerchat.params.current_url, parent);
      }
    });
  },

  loadTemplates: function(callback) {
    var _this = this, agent;

    this.layout = this.generateTemplate({
      section:   "body",
      template:  this.getLayout({
        gradient: this.settings.style.gradient ? "widget-gradient" : ""
      }),
      className: "widget-box widget-theme theme-" + this.settings.style.theme
    });

    agent = this.agent ? this.agent : this.agents[0];

    this.header = this.generateTemplate({
      section:   "div.widget-head",
      template:  this.getHeader({
        agent_name:  agent.display_name,
        img:         agent.avatar,
        agent_label: _this.settings.online.agent_label
      }),
      tagName:   'span',
      events: {
        "click div.widget-head" : "toggleWidget"
      },
      toggleWidget: function() {
        $.postMessage({slide: true}, _this.params.current_url, parent);
        $(".tooltip-options").removeClass("open");

        return false;
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
        "keyup input.widget-input-text" : "isTyping",
        "click a[data-type=sound]"      : "toggleSound",
        "click a[data-type=transcript]" : "downloadTranscript",
        "click div.footer-credits a"    : "togglePoweredBy"
      },
      toggleSettings: function() {
        tooltip = $(".settings-options");
        if (tooltip.hasClass("open"))
          tooltip.removeClass("open");
        else{
          $(".tooltip-options").removeClass("open");
          tooltip.addClass("open");
        }

        /*var msg = "";
        $.each(Chats.messages, function(key, value){
          msg += "(" + value.time + ") "  + value.sender + ": " + value.message + "\n";
        });

        $('a[data-type=transcript]').attr('href', "data:text/octet-stream," + escape(msg));*/
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
      },
      toggleSound: function(e) {
        if ($(e.target).data("sound") == "on") {
          $(e.target).text("Turn on sound");
          $(e.target).data("sound", "off");
          Offerchat.details({id: Offerchat.website.id}).update({sound: false});
          $("#beep-notify").remove();
        } else {
          $(e.target).text("Turn off sound");
          $(e.target).data("sound", "on");
          $(e.target).parent().append('<audio id="beep-notify" src="//d3ocj2fkvch1xi.cloudfront.net/widget/images/sound.ogg"></audio>');
          Offerchat.details({id: Offerchat.website.id}).update({sound: true});
        }
      },
      downloadTranscript: function() {
        $("a.chat-settings").trigger("click");
        window.location.href = Offerchat.src.history + "/transcript/visitor/" + Offerchat.params.secret_token;
      },
      togglePoweredBy: function() {
        window.open('//www.offerchat.com/?utm_medium=Widget_banner&utm_campaign=offerchat_widget&utm_source=www.offerchat.com', '_blank');
        return true;
      }
    });

    this.footer = this.generateTemplate({
      section: "div#widget-footer",
      template: this.getFooter(),
      className: "widget-footer",
      events: {
        "click div.widget-footer" : "goToOfferchat"
      },
      goToOfferchat: function(ev) {
        window.open('//www.offerchat.com/?utm_medium=Widget_banner&utm_campaign=offerchat_widget&utm_source=www.offerchat.com', '_blank');
        return true;
      }
    });

    this.offline = this.generateTemplate({
      section:   "div.widget-chat-viewer",
      template:  this.getChatForms({
        description: this.settings.offline.description
      }),
      className: "widget-block offline",
      tagName:   "form",
      events: {
        "submit form.widget-block.offline" : "submitOffline"
      },
      submitOffline: function(e) {
        if (_this.validateForms(this)) {
          // $(this).serialize()
          $.ajax({
            type: "POST",
            url: Offerchat.src.api_url + "offline/" + Offerchat.params.api_key,
            data: $(this).serialize(),
            success: function(data) {
              if (data.status == "success") {
                _this.formSuccess.replace();
                return false;
              }
            }
          });
        }

        return false;
      }
    });

    this.postchat = this.generateTemplate({
      section:   "div.widget-chat-viewer",
      template:  this.getChatForms({
        description: this.settings.post_chat.description
      }),
      className: "widget-block postchat",
      tagName:   "form",
      events: {
        "submit form.widget-block.postchat" : "submitPostChat"
      },
      submitPostChat: function(e) {
        if(_this.validateForms(this)) {
          $.ajax({
            type: "POST",
            url: Offerchat.src.api_url + "post_chat/" + Offerchat.params.api_key,
            data: $(this).serialize(),
            success: function(data) {
              if (data.status == "success") {
                _this.formSuccess.replace();
                return false;
              }
            }
          });
        }
        return false;
      }
    });

    this.prechat = this.generateTemplate({
      section:   "div.widget-chat-viewer",
      template:  this.getChatForms({
        description: this.settings.pre_chat.description,
        message_required: this.settings.pre_chat.message_required,
        email_required: this.settings.pre_chat.email_required
      }),
      className: "widget-block prechat",
      tagName:   "form",
      events: {
        "submit form.widget-block.prechat" : "submitPreChat"
      },
      submitPreChat: function(e) {
        var form = _this.validateForms(this);
        if (form) {
          // _this.loader.replace();
          _this.prechat.destroy();
          _this.inputs.visible();

          var data = Helpers.unserialize($(this).serialize());

          Offerchat.details({id: Offerchat.website.id}).update({
            prechat: true,
            name: data.name,
            email: data.email,
            message: data.message ? data.message : null
          });

          _this.details.prechat = true;
          _this.details.name    = data.name;
          _this.details.email   = data.email;
          _this.details.message = data.message ? data.message : null;

          Chats.init();
        }
        return false;
      }
    });

    // getFormsSuccess
    this.formSuccess = this.generateTemplate({
      section:   "div.widget-chat-viewer",
      template: this.getFormsSuccess(),
      className: "widget-block"
    });

    this.loader = this.generateTemplate({
      section:   "div.widget-chat-viewer",
      template:  this.getConnecting(),
      className: "widget-connection-status"
    }, true);

    this.reconnect = this.generateTemplate({
      section:   "div#widget-overlay",
      template:  this.getReconnect(),
      className: "widget-overlay",
      events: {
        "click a.widget-btn" : "reconnect"
      },
      reconnect: function(e) {
        Offerchat.details({id: Offerchat.website.id}).update({connect: true});
        Chats.init();
        _this.reconnect.destroy();
        _this.loader.replace();
        $(".widget-input-text").attr("disabled", "disabled");
      }
    });

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

      hidden: function() {
        $(this.options.section + " > " + this.options.tagName).css("visibility", "hidden");
        $(this.options.section + " > " + this.options.tagName).css("opacity", 0);
      },

      visible: function() {
        $(this.options.section + " > " + this.options.tagName).css("visibility", "visible");
        $(this.options.section + " > " + this.options.tagName).css("opacity", 1);
      },

      show: function() {
        $(this.options.section + " > " + this.options.tagName).show();
      },

      replace: function() {
        options.template = '<' + options.tagName  + options.className  + '>' + options.template + '</' + options.tagName + '>';
        $(options.section).html(options.template);
      },

      append: function() {
        options.template = '<' + options.tagName  + options.className  + '>' + options.template + '</' + options.tagName + '>';
        $(options.section).append(options.template);
      }
    };

    obj.init();

    return obj;
  },

  getLayout: function(data) {
    data = data || { gradient: "" };
    var layout = '<div class="widget-head widget-rounded-head group ' + data.gradient + '"></div>' +
                 '<div class="widget-body">' +
                 '  <div id="widget-overlay"></div>' +
                 '  <div class="widget-chat-viewer"></div>' +
                 '  <div id="widget-input"></div>' +
                 '  <div id="widget-footer"></div>' +
                 '</div>';

    return layout;
  },

  getHeader: function(data) {
    data = data || {};
    var header = '<img alt="Agent-avatar1" class="agent-thumbnail" src="' + data.img + '">' +
                 // '<div class="widget-msg-count">' +
                 // '  <span>' + data.unread + '</span>' +
                 // '</div>' +
                 '<div class="widget-agent-name">' + data.agent_name + '</div>' +
                 '<div class="widget-welcome-msg">' + data.agent_label + '</div>';

    return header;
  },

  getWidgetInputs: function(data) {
    var inputs;
    data   = data || { placeholder: "Type your question and hit enter" };
    inputs = '<ul class="tooltip-options settings-options">' +
             '  <li><a data-type="transcript">Open transcript</a></li>';

    if (this.details.sound) {
      inputs += '<li>' +
                '  <a data-type="sound" data-sound="on">Turn off sound</a>' +
                '  <audio id="beep-notify" src="//d3ocj2fkvch1xi.cloudfront.net/widget/images/sound.ogg"></audio>' +
                '</li>';
    }
    else
      inputs += '  <li><a data-type="sound" data-sound="off">Turn on sound</a></li>';

    inputs += '  <div class="footer-credits">powered by <a>Offerchat</a></div>' +
             '  <div class="caret"></div>' +
             '</ul>' +
             '<ul class="tooltip-options rating-options">' +
             '  <li><a><i class="widget icon icon-thumbs-up-green"></i></a></li>' +
             '  <li><a><i class="widget icon icon-thumbs-down-red"></i></a></li>' +
             '  <div class="caret"></div>' +
             '</ul>' +
             '<i class="widget icon icon-chat"></i>' +
             '<input class="widget-input-text" placeholder="' + data.placeholder + '" type="text">' +
             '<a class="chat-settings"><i class="widget icon icon-gear"></i></a>';
             // '<a class="chat-rating"><i class="widget icon icon-thumbs-up"></i></a>';

    return inputs;
  },

  getMessage: function(data) {
    data = data || {};
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
    data = data || { message: "connecting you to an agent" };
    var conn = data.message +
               '<div class="widget-progress">' +
               '  <div class="widget-progress-bar"></div>' +
               '</div>';

    return conn;
  },

  getChatForms: function(data) {
    data = data || {};
    var forms   =  '<div class="widget-pre-message">' +
                      data.description +
                   '</div>' +
                   '<div class="widget-input-container">' +
                   '  <input placeholder="Name" name="name" type="text">' +
                   '</div>';
    if (typeof data.email_required == "undefined" || data.email_required === true) {
      forms     += '<div class="widget-input-container">' +
                   '  <input placeholder="Email" name="email" type="text">' +
                   '</div>';
    }

    if (typeof data.message_required == "undefined" || data.message_required === true) {
      forms     += '<div class="widget-input-container">' +
                   '  <textarea name="message" placeholder="Message"></textarea>' +
                   '</div>';
    }

    forms       += '<div class="widget-input-container">' +
                   '  <button class="widget-button">Submit</button>' +
                   '</div>';

    return forms;
  },

  getFormsSuccess: function(data) {
    data = data || { message: "Your message has been sent", description: "Thank you! We will get back to you as soon as we can." };
    var success =  '<div class="widget-pre-message">' +
                   '  <h3>' +
                   '    <i class="widget icon icon-check-large"></i>' + data.message +
                   '  </h3>' +
                      data.description +
                   '</div>';

    return success;
  },

  getMessageView: function(data) {
    data = data || {};
    var message =  '  <div class="group">' +
                   '    <div class="message-author">' + data.sender + '</div>' +
                   '  </dvi>' +
                   '  <div class="message">' +
                   '    <div class="message-date">' + data.time + '</div>' +
                        data.message +
                   '  </div>';

    return message;
  },

  getFooter: function(data) {
    data = data || {};
    var footer = '<div class="footer-logo"></div>' +
                 '<div class="widget-footer-desc">' +
                 '  Powered by <strong><a>Offerchat</a></strong>' +
                 '</div>';

    return footer;
  },

  getReconnect: function(data) {
    data  = data || { message: "Your chat has been idle for more than 5 minutes.", button: "Connect" };
    var recon = '<div class="widget-confirmation">' +
                ' <p>' + data.message + '</p>' +
                ' <a class="widget-btn">' + data.button + '</a>' +
                '</div>';

    return recon;
  }
};