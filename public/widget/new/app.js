Offerchat = {
  website:  {},

  version: global.version,
  src:     global.src,

  init: function(options) {
    var _this = this;
    this.params  = options.params || {};
    this.api_key = this.params.api_key;

    this.details = this.loadData("ofc-details", localStorage) || undefined;
    this.roster  = this.loadData("ofc-roster", localStorage) || undefined;
    this.visitor = this.loadData("ofc-visitor", localStorage) || undefined;
    this.agent  = this.loadData("ofc-agent", localStorage) || undefined;

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
      details = _this.loadData("ofc-details", localStorage);
      if (!details) {
        _this.details = {
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
          message:  null,
          wversion: _this.version
        };
        _this.storeData("ofc-details", _this.details, localStorage);
      } else if (_this.details.wversion != _this.version) {
        localStorage.removeItem("offerchat_details");
        localStorage.removeItem("offerchat_LjAKRZBdrkc");
        localStorage.removeItem("offerchat_c2KtON93PneNpnmp/QBRKw==");
        localStorage.removeItem("offerchat_CebnSNzizB7khOg3YURskQ==");

        _this.details.wversion = _this.version;
        _this.storeData("ofc-details", _this.details, localStorage);
      } else {
        _this.details = details;
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
    // data = JSON.parse(sessionStorage.getItem("ofc-settings"));
    data = this.loadData("ofc-settings", sessionStorage);
    if (data === null) {
      $.ajax({
        type: "GET",
        url:  this.src.api_url + "settings/" + this.params.api_key + ".jsonp",
        dataType: "jsonp",
        success: function(data) {
          if (typeof data.error == "undefined") {
            _this.website = data.website;
            _this.any_agents_online = data.any_agents_online;

            _this.storeData("ofc-settings", data, sessionStorage);
            // sessionStorage.setItem("ofc-settings-" + _this.params.api_key, JSON.stringify(data));
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
    var _this = this, details = this.details;

    if (!details.location) {
      $.ajax({
        url:      "//j.maxmind.com/app/geoip.js",
        dataType: "script",
        success: function(data) {
          _this.details.location = geoip_country_name();
          _this.details.city = geoip_city();
          _this.details.code = geoip_country_code();

          _this.storeData("ofc-details", _this.details, localStorage);
          callback();
        },
        error: function(XMLHttpRequest, textStatus, errorThrown) {
          _this.details.location = geoip_country_name();
          _this.details.city = geoip_city();
          _this.details.code = geoip_country_code();

          _this.storeData("ofc-details", _this.details, localStorage);
          callback();
        }
      });

    } else {
      callback();
    }

    return true;
  },

  storeData: function(name, data, type) {
    type.setItem(name + "-" + this.api_key, JSON.stringify(data));
  },

  loadData: function(name, type) {
    var data = type.getItem(name + "-" + this.api_key);
    return JSON.parse(data);
  },

  removeData: function(name, type) {
    type.removeItem(name + "-" + this.api_key);
  }
};