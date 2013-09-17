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
  version: '2.1.1',
  src: {
    script:   '//local.offerchat.com:3000/',
    bosh_url: 'http://local.offerchat.com:7070/http-bind/',
    server:   '@local.offerchat.com',
    api_url:  '//local.offerchat.com:3000/api/v1/widget/',
    assets:   '//local.offerchat.com:3000',
    history:  '//history.offerchat.loc:9292'
  }
};