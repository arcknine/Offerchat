(function() {
  function load_js(link) {
    var oc, s;
    oc = document.createElement("script");
    oc.src = ('https:' == document.location.protocol ? 'https://' : 'http://') + link;
    oc.type = 'text/javascript';
    oc.async = true;
    s = document.getElementsByTagName('script')[0];
    s.parentNode.insertBefore(oc, s);
  }

  load_js("d3ocj2fkvch1xi.cloudfront.net/widget/js/lib/widget_lib.js");

  checkReady = function(callback) {
    if (window.$ofc)
      callback($ofc);
    else
      window.setTimeout(function() { checkReady(callback); }, 20);
  };

  checkReady(function () {
    var Widget, defaults, src, version;

    defaults = {
      version: '2.0.0',
      src: {
        api_url: '//local.offerchat.com:3000/api/v1/widget/',
        assets:  'http://local.offerchat.com:3000',
        cdn:     'http://local.offerchat.com:3000'
      }
    };

    src     = defaults.src;
    version = defaults.version;

    Widget = {
      info: {
        state:    "hide",
        referrer: document.referrer,
        position: "right",
        token:    null
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
          }
        }, src.assets);
      },

      toggleWidget: function() {
        if (this.info.state == "show") {
          $ofc('#offerchatbox').animate({height: '45px'}, 100);
          this.info.state = 'hide';
        } else {
          $ofc('#offerchatbox').animate({height: '421px'}, 100);
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
        if (info) {
          // console.log(info);
          this.info = {
            token:    info.token ? info.token : null,
            referrer: document.referrer ? document.referrer : info.referrer,
            position: info.position ? info.position : "right",
            state:    info.state ? info.state : "show",
            api_key:  ofc_key
          };
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

        height = this.info.state == "show" ? "421px" : "45px";
        build = '<div id="offerchatbox" style="position: fixed; bottom: 0; ' + this.info.position + ': 20px; margin: 0;  padding: 0; background-color: transparent; overflow: hidden; z-index: 99999999; height: ' + height + '; width: 306px; display: none">' +
                ' <iframe scrolling="0" name="offerchat_frame" frameBorder="0" id="offerchatFrameContainer" src="" style="background-color: transparent;vertical-align: text-bottom; overflow: hidden; position: relative;width: 100%;height: 100%;margin: 0px; z-index: 999999;"></iframe>' +
                '</div>';
        $ofc('body').append(build);

        path = src.assets + "/widget/widget-development.html";
        title = $ofc("head > title").text();

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
  });
})();