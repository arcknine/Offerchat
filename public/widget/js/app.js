Offerchat = {
  website:  {},

  version: global.version,
  src:     global.src,

  // taffy db
  details:  TAFFY(),
  roster:   TAFFY(),
  visitor:  TAFFY(),
  agent:    TAFFY(),

  init: function(options) {
    var _this = this;
    this.params = options.params || {};

    this.details.store('details');
    this.agent.store('LjAKRZBdrkc=');
    this.visitor.store('c2KtON93PneNpnmp/QBRKw==');
    this.roster.store('CebnSNzizB7khOg3YURskQ==');

    if (this.params.api_key && this.params.secret_token) {
      this.loadAllAssets(function(){

        Templates.init({
          params:   _this.params,
          settings: _this.website.settings,
          agents:   _this.website.agents
        });

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
          OS:       BrowserDetect.OS,
          sound:    true,
          prechat:  false,
          name:     null,
          email:    null,
          message:  null
        });
      }

      // overwrite for ie
      _this.website.settings.style.gradient = BrowserDetect.browser == "Internet Explorer" ? false : _this.website.settings.style.gradient;

      _this.loadLocation(function(){
        callback();
      });

    });

    return true;
  },

  loadSettings: function(callback) {
    var _this = this, settings;
    data = JSON.parse(sessionStorage.getItem("ofc-settings"));
    if (data === null) {
      $.ajax({
        type: "GET",
        url:  this.src.api_url + "settings/" + this.params.api_key + ".jsonp",
        dataType: "jsonp",
        success: function(data) {
          if (typeof data.error == "undefined") {
            _this.website = data.website;
            _this.any_agents_online = data.any_agents_online;

            sessionStorage.setItem("ofc-settings", JSON.stringify(data));
            callback();
          }
        }
      });
    } else {
      $.ajax({
        type: "GET",
        url:  this.src.api_url + "any_agents_online/" + this.params.api_key + ".jsonp",
        dataType: "jsonp",
        success: function(any_agents) {
          if (typeof data.error == "undefined") {
            _this.website = data.website;

            _this.any_agents_online = any_agents.any_agents_online;
            callback();
          }
        }
      });

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