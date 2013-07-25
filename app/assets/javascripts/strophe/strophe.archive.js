Strophe.addConnectionPlugin('archive', {
  _connection: null,

  init: function (connection) {
    this._connection = connection;
    Strophe.addNamespace('DELAY', 'jabber:x:delay');
    Strophe.addNamespace('ARCHIVE', 'urn:xmpp:archive');
    Strophe.addNamespace('RMS', 'http://jabber.org/protocol/rsm');
  },

  listCollections: function(handler_cb, jid, error_cb) {
    var xml = $iq({type: 'get', id: this._connection.getUniqueId('list')}).c('list', {xmlns: Strophe.NS.ARCHIVE, 'with': jid});
    this._connection.sendIQ(xml, this.retrieveMessages.bind(this, handler_cb), error_cb);
  },

  retrieveMessages: function(handler_cb, stanza, error_cb) {
    console.log(stanza)
    var jid, xml, start;
    var _this = this;
    var list = $(stanza).find('chat')
    $.each(list, function(key, value){
      if(key == 0) {
        jid   = $(value).attr('with');
        start = $(value).attr('start');
        xml = $iq({type: 'get', id: _this._connection.getUniqueId('retrieve')}).c('retrieve', {xmlns: Strophe.NS.ARCHIVE, 'with': jid, start: start});
        _this._connection.sendIQ(xml, handler_cb, error_cb);
      }
    });
    // jid = this._connection.jid;
    // xml = $iq({type: 'get', id: this._connection.getUniqueId('disco'), from: jid}).c('query', {xmlns: 'http://jabber.org/protocol/disco#info'});
    // this._connection.sendIQ(xml, handler_cb);
  }
});