Helpers = {
  bind: function(fn, me) {
    return function() {
      return fn.apply(me, arguments);
    };
  },

  unserialize: function(p) {
    var ret = {},
    seg = p.replace(/^\?/,'').split('&'),

    len = seg.length, i = 0, s;
    for (;i<len;i++) {
      if (!seg[i]) { continue; }
      s = seg[i].split('=');
      ret[s[0]] = decodeURIComponent(s[1].replace(/\+/g, " "));
    }
    return ret;
  },

  validateEmail: function(email) {
    var re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    return re.test(email);
  },

  randomString: function() {
    var chars, i, randomstring, rnum, string_length;
    chars = "0123456789Aabcdefghiklmnopqrstuvwxyz";
    string_length = 8;
    randomstring = "widget_";
    i = 0;
    while (i < string_length) {
      rnum = Math.floor(Math.random() * chars.length);
      randomstring += chars.substring(rnum, rnum + 1);
      i++;
    }
    return randomstring;
  },

  detectURL: function(str) {
    var urlPattern          = /\b(?:https?|ftp):\/\/[a-z0-9-+&@#\/%?=~_|!:,.;]*[a-z0-9-+&@#\/%=~_|]/gim;
    var pseudoUrlPattern    = /(^|[^\/])(www\.[\S]+(\b|$))/gim;
    var emailAddressPattern = /\w+@[a-zA-Z_]+?(?:\.[a-zA-Z]{2,6})+/gim;

    return str
      .replace(urlPattern, '<a href="$&" target="_blank">$&</a>')
      .replace(pseudoUrlPattern, '$1<a href="http://$2" target="_blank">$2</a>')
      .replace(emailAddressPattern, '<a href="mailto:$&">$&</a>');
  },

  htmlEntities: function(str) {
    return String(str).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
  }
};