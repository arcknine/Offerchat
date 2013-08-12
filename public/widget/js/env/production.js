// make IE run even with console.log
if (!(window.console && console.log)) { (function() { var noop = function() {}; var methods = ['assert', 'clear', 'count', 'debug', 'dir', 'dirxml', 'error', 'exception', 'group', 'groupCollapsed', 'groupEnd', 'info', 'log', 'markTimeline', 'profile', 'profileEnd', 'markTimeline', 'table', 'time', 'timeEnd', 'timeStamp', 'trace', 'warn']; var length = methods.length; var console = window.console = {}; while (length--) { console[methods[length]] = noop; } }()); }

var origin = window.location.origin;
var DEBUG_MODE = (origin === 'http://www.offerchat.com' || origin === 'http://offerchat.com' ? false : true);
if (!DEBUG_MODE) {
  var console = console || {};
  console.log = function() {};
}

var global, Widget, App, Helpers, Chats;

global = {
  version: '2.0.0',
  src: {
    script:   '//www.offerchat.com/',
    bosh_url: ('https:' == document.location.protocol ? 'https://b1.offerchat.com:7443/http-bind/' : 'http://b1.offerchat.com:7070/http-bind/'),
    server:   '@realtime.offerchat.com',
    api_url:  '//app.offerchat.com/api/v2/widgets/',
    assets:   '//app.offerchat.com'
  }
};