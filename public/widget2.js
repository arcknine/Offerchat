(function() {
  var Widget, defaults, src, version;

  defaults = {
    src: {
      api_url: '//local.offerchat.com:3000/api/v1/widget/',
      assets:  'http://local.offerchat.com:3000',
      cdn:     '//local.offerchat.com:3000',
      widget:  '//local.offerchat.com:3000/widget/widget-new.html',
      grabber: '//local.offerchat.com:3000/widget/attention-grabber.html'
    }
  };

  // staging
  /*defaults = {
    src: {
      api_url: '//staging.offerchat.com/api/v1/widget/',
      assets:  'https://staging.offerchat.com',
      cdn:     '//staging.offerchat.com',
      widget:  '//staging.offerchat.com/widget/widget-staging.html'
    }
  };*/

  // production
 /* defaults = {
    src: {
      api_url: '//app.offerchat.com/api/v1/widget/',
      assets:  'https://app.offerchat.com',
      cdn:     '//d1cpaygqxflr8n.cloudfront.net',
      widget:  'https://app.offerchat.com/widget/widget.html',
      grabber: 'https://app.offerchat.com/widget/attention-grabber.html'
    }
  };*/
  src     = defaults.src;
  version = defaults.version = '2.1.3';

  Widget = {
    info: {
      state:    "hide",
      hasAgent: false,
      referrer: document.referrer,
      position: "right",
      footer:   true,
      token:    null,
      version:  defaults.version,
      grabbers: false
    },

    init: function() {
      var _this = this;
      this.loadStorage();
      this.getPosition(function(){
        _this.initPostMessage();
        _this.register();
      });
    },

    initPostMessage: function(callback) {
      var _this = this;
      $ofc.receiveMessage( function(e) {
        var data = _this.unserialize(e.data);
        if (data.show == 'true') {
          $ofc("#offerchatbox").show();
        } else if (data.slide == 'true') {
          _this.toggleWidget(data.has_agent);
        } else if (data.new_msg == 'true') {
          if(_this.info.state == 'hide'){
            height = _this.info.footer ? '421px' : '400px';
            // $ofc('#offerchatbox').animate({height: height}, 100);
            $ofc('#offerchatbox').css("height", height);
            _this.info.state = 'show';
          }
        } else if (data.has_agent == "true") {
          $ofc("#ofc-attention-grabber").css("bottom", "45px");
        } else if (data.any_agents_online == "true" && (_this.info.grabbers !== false && _this.info.grabbers.enabled)) {
          _this.generateAttentionGrabber();
        }
      }, src.assets);
    },

    toggleWidget: function(has_agent) {
      if (this.info.state == "show") {
        hide_height = has_agent == "true" ? "45px" : "33px";
        // $ofc('#offerchatbox').animate({height: '45px'}, 100);
        $ofc('#offerchatbox').css("height", hide_height);
        if (this.info.grabbers.display != "none") $ofc('#ofc-attention-grabber').show();
        this.info.state = 'hide';
      } else {
        height = this.info.footer ? '421px' : '400px';
        // $ofc('#offerchatbox').animate({height: height}, 100);
        $ofc('#offerchatbox').css("height", height);
        if (this.info.grabbers.display != "none") $ofc('#ofc-attention-grabber').hide();
        this.info.state = 'show';
      }

      this.info.hasAgent = has_agent;
      localStorage.setItem("ofc-widget-info", JSON.stringify(this.info));
    },

    unserialize: function(p) {
      var ret = {},
      seg = p.replace(/^\?/,'').split('&'),

      len = seg.length, i = 0, s;
      for (;i<len;i++) {
        if (!seg[i]) { continue; }
        s = seg[i].split('=');
        ret[s[0]] = s[1];
      }
      return ret;
    },

    loadStorage: function() {
      var info = JSON.parse(localStorage.getItem("ofc-widget-info"));
      if (info && info.version == defaults.version) {
        this.info = {
          token:    info.token ? info.token : null,
          referrer: info.referrer ? info.referrer : document.referrer,
          position: info.position ? info.position : "right",
          footer:   info.footer === false ? info.footer : true,
          state:    info.state ? info.state : "show",
          hasAgent: info.hasAgent ? info.hasAgent : false,
          version:  defaults.version,
          grabbers: info.grabbers !== false ? info.grabbers : false,
          api_key:  ofc_key
        };
        localStorage.setItem("ofc-widget-info", JSON.stringify(this.info));
      } else {
        sessionStorage.removeItem("ofc-widget-position");
        localStorage.setItem("ofc-widget-info", JSON.stringify(this.info));
      }
    },

    getPosition: function(callback) {
      var _this = this, position;
      position  = sessionStorage.getItem("ofc-widget-position");
      if (position === null) {
        $ofc.ajax({
          type: "GET",
          url:  src.api_url + "position/" + ofc_key + ".jsonp",
          dataType: "jsonp",
          success: function(data) {
            if (typeof data.error == "undefined") {
              _this.info.position = data.position;
              _this.info.footer   = data.footer;
              _this.info.grabbers = data.grabber;

              localStorage.setItem("ofc-widget-info", JSON.stringify(_this.info));
              sessionStorage.setItem("ofc-widget-position", data.position);
              callback();
            }
          }
        });
      } else {
        this.info.position = position;
        localStorage.setItem("ofc-widget-info", JSON.stringify(_this.info));
        callback();
      }
    },

    register: function() {
      var _this = this;
      if (this.info.token === null && this.info.api_key != ofc_key) {
        $ofc.ajax({
          type: "GET",
          url:  src.api_url + "token/" + ofc_key + ".jsonp",
          dataType: "jsonp",
          success: function(data) {
            if (typeof data.error == "undefined") {
              _this.info.token = data.token;
              localStorage.setItem("ofc-widget-info", JSON.stringify(_this.info));
              _this.generateIframeWrapper();
            }
          }
        });
      } else {
        this.generateIframeWrapper();
      }
    },

    generateIframeWrapper: function() {
      var build, height, path, title, closeHeight;
      closeHeight = this.info.hasAgent == "true" ? "45px" : "33px";

      if (this.info.footer)
        height = this.info.state == "show" ? "421px" : closeHeight;
      else
        height = this.info.state == "show" ? "400px" : closeHeight;

      build = '<div id="offerchatbox" style="position: fixed; bottom: 0; ' + this.info.position + ': 20px; margin: 0;  padding: 0; background-color: transparent; overflow: hidden; z-index: 99999999; height: ' + height + '; width: 306px; display: none">' +
              ' <iframe scrolling="0" name="offerchat_frame" frameBorder="0" id="offerchatFrameContainer" src="" style="background-color: transparent;vertical-align: text-bottom; overflow: hidden; position: relative;width: 100%;height: 100%;margin: 0px; z-index: 999999;"></iframe>' +
              '</div>';
      $ofc('body').append(build);

      path = src.widget;
      title = encodeURI($ofc("head > title").text());

      $ofc("<form action='" + path + "' method='GET' target='offerchat_frame'></form>")
      .append($ofc("<input type='hidden' name='api_key' />").attr('value', ofc_key))
      .append($ofc("<input type='hidden' name='secret_token' />").attr('value', this.info.token))
      .append($ofc("<input type='hidden' name='current_url' />").attr('value', document.location.href))
      .append($ofc("<input type='hidden' name='page_title' />").attr('value', title))
      .append($ofc("<input type='hidden' name='referrer' />").attr('value', this.info.referrer))
      .append($ofc("<input type='hidden' name='_r' />").attr('value', Math.random()))
      .appendTo('body')
      .submit()
      .remove();
    },

    generateAttentionGrabber: function() {
      var build, height, display, grabber, w_widget, bot_pos, position, _this = this;
      grabber = this.info.grabbers.src;
      height  = this.info.grabbers.height;
      width   = this.info.grabbers.width;
      display = this.info.grabbers.display ? this.info.grabbers.display : "block";

      w_width  = 306;
      bot_pos  = this.info.hasAgent == "true" ? 45 : 33;
      position = (w_width / 2) - (width / 2) + 20;

      build = '<div id="ofc-attention-grabber" style="position: fixed; bottom: ' + bot_pos + 'px; ' + this.info.position + ': ' + position + 'px; margin: 0;  padding: 0; background-color: transparent; overflow: hidden; z-index: 9999999; height: ' + height + 'px; width: ' + width + 'px; display: ' + display + '">' +
              ' <iframe scrolling="0" name="ofc_attention_grabber" frameBorder="0" id="ofc-attention-grabber-iframe" src="" style="background-color: transparent;vertical-align: text-bottom; overflow: hidden; position: relative;width: 100%;height: 100%;margin: 0px; z-index: 9999;"></iframe>' +
              ' <div id="ofc-click-me" style="background-color: transparent;vertical-align: text-bottom; overflow: hidden; position: absolute;width: 100%;height: 100%;margin: 0px; z-index: 999999; top: 0; cursor: pointer"></div>' +
              ' <strong title="close" id="ofc-ag-close" style="font-weight: strong; font-size: 20px; display: none; position: absolute; top: 0; right: 0; z-index: 999999; cursor: pointer">&times;</strong>'
              '</div>';
      $ofc('body').append(build);

      path = src.grabber;
      $ofc("<form action='" + path + "' method='GET' target='ofc_attention_grabber'></form>")
      .append($ofc("<input type='hidden' name='attention_grabber' />").attr('value', grabber))
      // .append($ofc("<input type='hidden' name='_r' />").attr('value', Math.random()))
      .appendTo('body')
      .submit()
      .remove();

      if (this.info.state == "show") $ofc('#ofc-attention-grabber').hide();

      $ofc(document).on("click", "#ofc-click-me", function() {
        _this.toggleWidget(_this.info.hasAgent);
      });

      $ofc(document).on("mouseover", "#ofc-attention-grabber", function(){
        $ofc("#ofc-ag-close").show();
      });

      $ofc(document).on("mouseout", "#ofc-attention-grabber", function(){
        $ofc("#ofc-ag-close").hide();
      });

      $ofc(document).on("click", "#ofc-ag-close", function(){
        $ofc("#ofc-attention-grabber").hide();
        _this.info.grabbers.display = "none";
        localStorage.setItem("ofc-widget-info", JSON.stringify(_this.info));
      });
    }

  };

  $ofc(document).ready(function(){
    Widget.init();
  });
})();