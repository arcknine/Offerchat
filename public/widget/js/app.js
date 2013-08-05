Offerchat = {
  settings: {},
  widget:   {},
  website:  {},
  agents:   [],

  version: global.version,
  src:     global.local,

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
          settings: _this.settings,
          agents:   _this.agents,
          website:  _this.website
        });

        Chats.init();
        $.postMessage({show: true}, _this.params.current_url, parent);
      });
    }
  },

  loadAllAssets: function(callback) {
    var _this = this, details;
    this.loadSettings(function(){
      var details = _this.details({ id: _this.website.id }).first();
      if (!details) {
        _this.details.insert({
          id:       _this.website.id,
          api_key:  _this.website.api_key,
          location: null,
          city:     null,
          code:     null,
          browser:  BrowserDetect.browser,
          version:  BrowserDetect.version,
          OS:       BrowserDetect.OS
        });
      }

      _this.widget = JSON.parse(localStorage.getItem("offerchat_widget")) || {};

      // overwrite for ie
      _this.settings.style.gradient = BrowserDetect.browser == "Internet Explorer" ? false : _this.settings.style.gradient;

      _this.loadLocation(function(){
        callback();
      });

    });

    return true;
  },

  loadSettings: function(callback) {
    var _this = this, settings;
    data = JSON.parse(sessionStorage.getItem("ofc-settings"));
    if (data == null) {
      $.ajax({
        type: "GET",
        url:  this.src.api_url + "settings/" + this.params.api_key + ".jsonp",
        dataType: "jsonp",
        success: function(data) {
          if (typeof data.error == "undefined") {
            _this.settings = data.settings;
            _this.agents   = data.agents;
            _this.website  = data.website;

            sessionStorage.setItem("ofc-settings", JSON.stringify(data));
            callback();
          }
        }
      });
    } else {
      this.settings = data.settings;
      this.agents   = data.agents;
      this.website  = data.website;
      callback();
    }
  },

  loadLocation: function(callback) {
    var _this   = this,
        details = this.details({ id: this.website.id }).first();

    if (!details.location) {
      $.ajax({
        url:      "//j.maxmind.com/app/geoip.js",
        dataType: "script",
        success: function(data) {
          _this.details({id: _this.website.id}).update({
            location: geoip_country_name(),
            city:     geoip_city(),
            code:     geoip_country_code()
          });
          callback();
        },
        error: function(XMLHttpRequest, textStatus, errorThrown) {
          _this.details({id: _this.website.id}).update({
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