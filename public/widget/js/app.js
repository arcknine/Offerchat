Offerchat = {
  settings: {},

  init: function(options) {
    var _this = this;
    this.params = options.params || {};

    if (this.params.api_key && this.params.secret_token) {
      this.loadSettings(function(){
        Templates.init({
          params:   _this.params,
          settings: _this.settings
        });
        $.postMessage({show: true}, _this.params.current_url, parent);
      });
    }
  },

  loadSettings: function(callback) {
    this.settings = {
      "style": {
        "theme":"lightgoldenrod2",
        "position":"left",
        "rounded":false,
        "gradient":true
      },
      "online":{
        "header":"Chat with us",
        "agent_label":"Got a question? We can help.",
        "greeting":"Hi, I am",
        "placeholder":"Type your message and hit enter"
      },
      "pre_chat":{
        "enabled":false,
        "message_required":true,
        "header":"Let me get to know you!",
        "description":"Fill out the form to start the chat. fdsafsdaf"
      },
      "post_chat":{
        "enabled":true,
        "header":"Chat with me, I'm here to help",
        "description":"Please take a moment to rate this chat session !!!!!",
        "email":"keenan@offerchat.com"
      },
      "offline":{
        "enabled":true,
        "header":"Contact Us",
        "description":"Offline message here!",
        "email":"keenan@offerchat.com"
      }
    };

    callback();
  }
};