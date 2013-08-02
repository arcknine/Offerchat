Offerchat = {
  settings: {},
  widget:   {},

  // taffy db
  details:  TAFFY(),

  init: function(options) {
    var _this = this;
    this.params = options.params || {};

    this.details.store('details');

    if (this.params.api_key && this.params.secret_token) {
      this.loadAllAssets(function(){

        Templates.init({
          params:   _this.params,
          settings: _this.settings
        });

        $.postMessage({show: true}, _this.params.current_url, parent);
      });
    }
  },

  loadAllAssets: function(callback) {
    var _this = this, details;
    this.loadSettings(function(){
      var details = _this.details({ id: _this.settings.website.id }).first();
      if (!details) {
        _this.details.insert({
          id:       _this.settings.website.id,
          api_key:  _this.settings.website.api_key,
          location: null,
          city:     null,
          code:     null,
          browser:  BrowserDetect.browser,
          version:  BrowserDetect.version,
          OS:       BrowserDetect.OS
        });
      }

      // overwrite for ie
      _this.settings.style.gradient = BrowserDetect.browser == "Internet Explorer" ? false : _this.settings.style.gradient;

      _this.loadLocation(function(){
        callback();
      });

    });

    return true;
  },

  loadSettings: function(callback) {
    this.settings = {
      "style": {
        "theme":"lightgoldenrod2",
        "position":"left",
        "rounded":false,
        "gradient":true
      },
      "online": {
        "header":"Chat with us",
        "agent_label":"Got a question? We can help.",
        "greeting":"Hi, I am",
        "placeholder":"Type your message and hit enter"
      },
      "pre_chat": {
        "enabled":false,
        "message_required":true,
        "header":"Let me get to know you!",
        "description":"Fill out the form to start the chat. fdsafsdaf"
      },
      "post_chat": {
        "enabled":true,
        "header":"Chat with me, I'm here to help",
        "description":"Please take a moment to rate this chat session !!!!!",
        "email":"keenan@offerchat.com"
      },
      "offline": {
        "enabled":true,
        "header":"Contact Us",
        "description":"Offline message here!",
        "email":"keenan@offerchat.com"
      },
      "website": {
        "id": 1,
        "api_key": "api key here"
      }
    };

    callback();
  },

  loadLocation: function(callback) {
    var _this   = this,
        details = this.details({ id: this.settings.website.id }).first();

    if (!details.location) {
      $.ajax({
        url:      "//j.maxmind.com/app/geoip.js",
        dataType: "script",
        success: function(data) {
          _this.details({id: _this.settings.website.id}).update({
            location: geoip_country_name(),
            city:     geoip_city(),
            code:     geoip_country_code()
          });
          callback();
        },
        error: function(XMLHttpRequest, textStatus, errorThrown) {
          _this.details({id: _this.settings.website.id}).update({
            location: null,
            city:     null,
            code:     null
          });
          callback();
        }
      });

    } else {
      callback();
    }

    return true;
  }
};