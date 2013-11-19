(function() {
  var Widget, defaults, src, version;

  defaults = {
    version: '2.0.0',
    src: {
      api_url: '//local.offerchat.com:3000/api/v1/widget/',
      assets:  'http://local.offerchat.com:3000',
      cdn:     '//local.offerchat.com:3000',
      widget:  '//local.offerchat.com:3000/widget/widget-new.html'
    }
  };

  // staging
  /*defaults = {
    version: '2.0.0',
    src: {
      api_url: '//staging.offerchat.com/api/v1/widget/',
      assets:  'https://staging.offerchat.com',
      cdn:     '//staging.offerchat.com',
      widget:  '//staging.offerchat.com/widget/widget-staging.html'
    }
  };*/

  // production
 /* defaults = {
    version: '2.0.0',
    src: {
      api_url: '//new.offerchat.com/api/v1/widget/',
      assets:  'https://new.offerchat.com',
      cdn:     '//d1cpaygqxflr8n.cloudfront.net',
      widget:  'https://new.offerchat.com/widget/widget.html'
    }
  };*/

  src     = defaults.src;
  version = defaults.version;

  Widget = {
    info: {
      state:    "hide",
      referrer: document.referrer,
      position: "right",
      footer:   true,
      token:    null,
      version:  defaults.version
    },

    init: function() {
      var _this = this;
      this.initPostMessage();
      this.loadStorage();
      this.getPosition(function(){
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
          _this.toggleWidget();
        } else if (data.new_msg == 'true') {
          if(_this.info.state == 'hide'){
            height = _this.info.footer ? '421px' : '400px';
            // $ofc('#offerchatbox').animate({height: height}, 100);
            $ofc('#offerchatbox').css("height", height);
            _this.info.state = 'show';
          }
        }
      }, src.assets);
    },

    toggleWidget: function() {
      if (this.info.state == "show") {
        // $ofc('#offerchatbox').animate({height: '45px'}, 100);
        $ofc('#offerchatbox').css("height", "45px");
        this.info.state = 'hide';
      } else {
        height = this.info.footer ? '421px' : '400px';
        // $ofc('#offerchatbox').animate({height: height}, 100);
        $ofc('#offerchatbox').css("height", height);
        this.info.state = 'show';
      }

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
          version:  defaults.version,
          api_key:  ofc_key
        };
        localStorage.setItem("ofc-widget-info", JSON.stringify(this.info));
      } else {
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
      var build, height, path, title;

      if (this.info.footer)
        height = this.info.state == "show" ? "421px" : "45px";
      else
        height = this.info.state == "show" ? "400px" : "45px";

      build = '<div id="offerchatbox" style="position: fixed; bottom: 0; ' + this.info.position + ': 20px; margin: 0;  padding: 0; background-color: transparent; overflow: hidden; z-index: 99999999; height: ' + height + '; width: 306px; display: none">' +
              ' <iframe scrolling="0" name="offerchat_frame" frameBorder="0" id="offerchatFrameContainer" src="" style="background-color: transparent;vertical-align: text-bottom; overflow: hidden; position: relative;width: 100%;height: 100%;margin: 0px; z-index: 999999;"></iframe>' +
              '</div>';
      $ofc('body').append(build);

      path = src.widget;
      title = encodeURI($ofc("head > title").text());
      // path = "http://10.10.1.22:3000/widget"

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
    }

  };

  $ofc(document).ready(function(){
    Widget.init();
  });
})();