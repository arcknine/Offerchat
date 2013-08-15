/*
  Copyright 2010, François de Metz <francois@2metz.fr>
*/
/**
 * Roster Plugin
 * Allow easily roster management
 *
 *  Features
 *  * Get roster from server
 *  * handle presence
 *  * handle roster iq
 *  * subscribe/unsubscribe
 *  * authorize/unauthorize
 *  * roster versioning (xep 237)
 */
Strophe.addConnectionPlugin('roster',
{
    _connection: null,

    _callbacks : [],
    /** Property: items
     * Roster items
     * [
     *    {
     *        name         : "",
     *        jid          : "",
     *        subscription : "",
     *        ask          : "",
     *        groups       : ["", ""],
     *        resources    : {
     *            myresource : {
     *                show   : "",
     *                status : "",
     *                priority : ""
     *            }
     *        }
     *    }
     * ]
     */
    items : [],
    /** Property: ver
     * current roster revision
     * always null if server doesn't support xep 237
     */
    ver : null,
    /** Function: init
     * Plugin init
     *
     * Parameters:
     *   (Strophe.Connection) conn - Strophe connection
     */
    init: function(conn)
    {
    this._connection = conn;
        this.items = [];
        // Override the connect and attach methods to always add presence and roster handlers.
        // They are removed when the connection disconnects, so must be added on connection.
        var oldCallback, roster = this, _connect = conn.connect, _attach = conn.attach;
        var newCallback = function(status)
        {
            if (status == Strophe.Status.ATTACHED || status == Strophe.Status.CONNECTED)
            {
                try
                {
                    // Presence subscription
                    conn.addHandler(roster._onReceivePresence.bind(roster), null, 'presence', null, null, null);
                    conn.addHandler(roster._onReceiveIQ.bind(roster), Strophe.NS.ROSTER, 'iq', "set", null, null);
                }
                catch (e)
                {
                    Strophe.error(e);
                }
            }
            if (oldCallback !== null)
                oldCallback.apply(this, arguments);
        };
        conn.connect = function(jid, pass, callback, wait, hold)
        {
            oldCallback = callback;
            if (typeof arguments[0] == "undefined")
                arguments[0] = null;
            if (typeof arguments[1] == "undefined")
                arguments[1] = null;
            arguments[2] = newCallback;
            _connect.apply(conn, arguments);
        };
        conn.attach = function(jid, sid, rid, callback, wait, hold, wind)
        {
            oldCallback = callback;
            if (typeof arguments[0] == "undefined")
                arguments[0] = null;
            if (typeof arguments[1] == "undefined")
                arguments[1] = null;
            if (typeof arguments[2] == "undefined")
                arguments[2] = null;
            arguments[3] = newCallback;
            _attach.apply(conn, arguments);
        };

        Strophe.addNamespace('ROSTER_VER', 'urn:xmpp:features:rosterver');
    },
    /** Function: supportVersioning
     * return true if roster versioning is enabled on server
     */
    supportVersioning: function()
    {
        return (this._connection.features && this._connection.features.getElementsByTagName('ver').length > 0);
    },
    /** Function: get
     * Get Roster on server
     *
     * Parameters:
     *   (Function) userCallback - callback on roster result
     *   (String) ver - current rev of roster
     *      (only used if roster versioning is enabled)
     *   (Array) items - initial items of ver
     *      (only used if roster versioning is enabled)
     *     In browser context you can use sessionStorage
     *     to store your roster in json (JSON.stringify())
     */
    get: function(userCallback, ver, items)
    {
        var attrs = {xmlns: Strophe.NS.ROSTER};
        this.items = [];
        if (this.supportVersioning())
        {
            // empty rev because i want an rev attribute in the result
            attrs.ver = ver || '';
            this.items = items || [];
        }
        var iq = $iq({type: 'get',  'id' : this._connection.getUniqueId('roster')}).c('query', attrs);
        return this._connection.sendIQ(iq,
                                this._onReceiveRosterSuccess.bind(this, userCallback),
                                this._onReceiveRosterError.bind(this, userCallback));
    },
    /** Function: registerCallback
     * register callback on roster (presence and iq)
     *
     * Parameters:
     *   (Function) call_back
     */
    registerCallback: function(call_back)
    {
        this._callbacks.push(call_back);
    },
    /** Function: findItem
     * Find item by JID
     *
     * Parameters:
     *     (String) jid
     */
    findItem : function(jid)
    {
        for (var i = 0; i < this.items.length; i++)
        {
            if (this.items[i] && this.items[i].jid == jid)
            {
                return this.items[i];
            }
        }
        return false;
    },
    /** Function: removeItem
     * Remove item by JID
     *
     * Parameters:
     *     (String) jid
     */
    removeItem : function(jid)
    {
        for (var i = 0; i < this.items.length; i++)
        {
            if (this.items[i] && this.items[i].jid == jid)
            {
                this.items.splice(i, 1);
                return true;
            }
        }
        return false;
    },
    /** Function: subscribe
     * Subscribe presence
     *
     * Parameters:
     *     (String) jid
     *     (String) message
     */
    subscribe: function(jid, message)
    {
        var pres = $pres({to: jid, type: "subscribe"});
        if (message && message != "")
            pres.c("status").t(message);
        this._connection.send(pres);
    },
    /** Function: unsubscribe
     * Unsubscribe presence
     *
     * Parameters:
     *     (String) jid
     *     (String) message
     */
    unsubscribe: function(jid, message)
    {
        var pres = $pres({to: jid, type: "unsubscribe"});
        if (message && message != "")
            pres.c("status").t(message);
        this._connection.send(pres);
    },
    /** Function: authorize
     * Authorize presence subscription
     *
     * Parameters:
     *     (String) jid
     *     (String) message
     */
    authorize: function(jid, message)
    {
        var pres = $pres({to: jid, type: "subscribed"});
        if (message && message != "")
            pres.c("status").t(message);
        this._connection.send(pres);
    },
    /** Function: unauthorize
     * Unauthorize presence subscription
     *
     * Parameters:
     *     (String) jid
     *     (String) message
     */
    unauthorize: function(jid, message)
    {
        var pres = $pres({to: jid, type: "unsubscribed"});
        if (message && message != "")
            pres.c("status").t(message);
        this._connection.send(pres);
    },
    /** Function: add
     * Add roster item
     *
     * Parameters:
     *   (String) jid - item jid
     *   (String) name - name
     *   (Array) groups
     *   (Function) call_back
     */
    add: function(jid, name, groups, call_back)
    {
        var iq = $iq({type: 'set'}).c('query', {xmlns: Strophe.NS.ROSTER}).c('item', {jid: jid,
                                                                                      name: name});
        for (var i = 0; i < groups.length; i++)
        {
            iq.c('group').t(groups[i]).up();
        }
        this._connection.sendIQ(iq, call_back, call_back);
    },
    /** Function: update
     * Update roster item
     *
     * Parameters:
     *   (String) jid - item jid
     *   (String) name - name
     *   (Array) groups
     *   (Function) call_back
     */
    update: function(jid, name, groups, call_back)
    {
        var item = this.findItem(jid);
        if (!item)
        {
            throw "item not found";
        }
        var newName = name || item.name;
        var newGroups = groups || item.groups;
        var iq = $iq({type: 'set'}).c('query', {xmlns: Strophe.NS.ROSTER}).c('item', {jid: item.jid,
                                                                                      name: newName});
        for (var i = 0; i < newGroups.length; i++)
        {
            iq.c('group').t(newGroups[i]).up();
        }
        return this._connection.sendIQ(iq, call_back, call_back);
    },
    /** Function: remove
     * Remove roster item
     *
     * Parameters:
     *   (String) jid - item jid
     *   (Function) call_back
     */
    remove: function(jid, call_back)
    {
        var item = this.findItem(jid);
        if (!item)
        {
            throw "item not found";
        }
        var iq = $iq({type: 'set'}).c('query', {xmlns: Strophe.NS.ROSTER}).c('item', {jid: item.jid,
                                                                                      subscription: "remove"});
        this._connection.sendIQ(iq, call_back, call_back);
    },
    /** PrivateFunction: _onReceiveRosterSuccess
     *
     */
    _onReceiveRosterSuccess: function(userCallback, stanza)
    {
        this._updateItems(stanza);
        userCallback(this.items);
    },
    /** PrivateFunction: _onReceiveRosterError
     *
     */
    _onReceiveRosterError: function(userCallback, stanza)
    {
        userCallback(this.items);
    },
    /** PrivateFunction: _onReceivePresence
     * Handle presence
     */
    _onReceivePresence : function(presence)
    {
        // TODO: from is optional
        var jid = presence.getAttribute('from');
        var from = Strophe.getBareJidFromJid(jid);
        var item = this.findItem(from);
        // not in roster
        if (!item)
        {
            return true;
        }
        var type = presence.getAttribute('type');
        if (type == 'unavailable')
        {
            delete item.resources[Strophe.getResourceFromJid(jid)];
        }
        else if (!type)
        {
            // TODO: add timestamp
            item.resources[Strophe.getResourceFromJid(jid)] = {
                show     : (presence.getElementsByTagName('show').length != 0) ? Strophe.getText(presence.getElementsByTagName('show')[0]) : "",
                status   : (presence.getElementsByTagName('status').length != 0) ? Strophe.getText(presence.getElementsByTagName('status')[0]) : "",
                priority : (presence.getElementsByTagName('priority').length != 0) ? Strophe.getText(presence.getElementsByTagName('priority')[0]) : ""
            };
        }
        else
        {
            // Stanza is not a presence notification. (It's probably a subscription type stanza.)
            return true;
        }
        this._call_backs(this.items, item);
        return true;
    },
    /** PrivateFunction: _call_backs
     *
     */
    _call_backs : function(items, item)
    {
        for (var i = 0; i < this._callbacks.length; i++) // [].forEach my love ...
        {
            this._callbacks[i](items, item);
        }
    },
    /** PrivateFunction: _onReceiveIQ
     * Handle roster push.
     */
    _onReceiveIQ : function(iq)
    {
        var id = iq.getAttribute('id');
        var from = iq.getAttribute('from');
        // Receiving client MUST ignore stanza unless it has no from or from = user's JID.
        if (from && from != "" && from != this._connection.jid && from != Strophe.getBareJidFromJid(this._connection.jid))
            return true;
        var iqresult = $iq({type: 'result', id: id, from: this._connection.jid});
        this._connection.send(iqresult);
        this._updateItems(iq);
        return true;
    },
    /** PrivateFunction: _updateItems
     * Update items from iq
     */
    _updateItems : function(iq)
    {
        var query = iq.getElementsByTagName('query');
        if (query.length != 0)
        {
            this.ver = query.item(0).getAttribute('ver');
            var self = this;
            Strophe.forEachChild(query.item(0), 'item',
                function (item)
                {
                    self._updateItem(item);
                }
           );
        }
        this._call_backs(this.items);
    },
    /** PrivateFunction: _updateItem
     * Update internal representation of roster item
     */
    _updateItem : function(item)
    {
        var jid           = item.getAttribute("jid");
        var name          = item.getAttribute("name");
        var subscription  = item.getAttribute("subscription");
        var ask           = item.getAttribute("ask");
        var groups        = [];
        Strophe.forEachChild(item, 'group',
            function(group)
            {
                groups.push(Strophe.getText(group));
            }
        );

        if (subscription == "remove")
        {
            this.removeItem(jid);
            return;
        }

        var item = this.findItem(jid);
        if (!item)
        {
            this.items.push({
                name         : name,
                jid          : jid,
                subscription : subscription,
                ask          : ask,
                groups       : groups,
                resources    : {}
            });
        }
        else
        {
            item.name = name;
            item.subscription = subscription;
            item.ask = ask;
            item.groups = groups;
        }
    }
});

// Generated by CoffeeScript 1.3.3
/*
Plugin to implement the vCard extension.
http://xmpp.org/extensions/xep-0054.html

Author: Nathan Zorn (nathan.zorn@gmail.com)
CoffeeScript port: Andreas Guth (guth@dbis.rwth-aachen.de)
*/

/* jslint configuration:
*/

/* global document, window, setTimeout, clearTimeout, console,
    XMLHttpRequest, ActiveXObject,
    Base64, MD5,
    Strophe, $build, $msg, $iq, $pres
*/

var buildIq;

buildIq = function(type, jid, vCardEl) {
  var iq;
  iq = $iq(jid ? {
    type: type,
    to: jid
  } : {
    type: type
  });
  iq.c("vCard", {
    xmlns: Strophe.NS.VCARD
  });
  if (vCardEl) {
    iq.cnode(vCardEl);
  }
  return iq;
};

Strophe.addConnectionPlugin('vcard', {
  _connection: null,
  init: function(conn) {
    this._connection = conn;
    return Strophe.addNamespace('VCARD', 'vcard-temp');
  },
  /*Function
    Retrieve a vCard for a JID/Entity
    Parameters:
    (Function) handler_cb - The callback function used to handle the request.
    (String) jid - optional - The name of the entity to request the vCard
       If no jid is given, this function retrieves the current user's vcard.
  */

  get: function(handler_cb, jid, error_cb) {
    var iq;
    iq = buildIq("get", jid);
    return this._connection.sendIQ(iq, handler_cb, error_cb);
  },
  /* Function
      Set an entity's vCard.
  */

  set: function(handler_cb, vCardEl, jid, error_cb) {
    var iq;
    iq = buildIq("set", jid, vCardEl);
    return this._connection.sendIQ(iq, handler_cb, error_rb);
  }
});

Strophe.addConnectionPlugin("xdomainrequest", {
  init: function () {
    if (window.XDomainRequest) {
      Strophe.debug("using XdomainRequest for IE");

      // Need to extend XDomainRequest to support compatibility in IE8
      var MyXHR = function() {
        var that = new XDomainRequest();
        var oldsend = that.send;

        that.send = function() {
          oldsend.apply(that, arguments);

          that.readyState = 2;
          try {
            that.onreadystatechange();
          } catch (e) { }
        };

        return that;
      };

      // replace Strophe.Request._newXHR with the xdomainrequest version
      Strophe.Request.prototype._newXHR = function () {
        var fireReadyStateChange = function (xhr, status) {
          xhr.status = status;
          xhr.readyState = 4;
          try {
            xhr.onreadystatechange();
          } catch (e) {}
        };


        var xhr = MyXHR();

        xhr.readyState = 0;
        xhr.onreadystatechange = this.func.bind(null, this);
        xhr.onload = function () {
          xmlDoc = new ActiveXObject("Microsoft.XMLDOM");
          xmlDoc.async = "false";
          xmlDoc.loadXML(xhr.responseText);
          xhr.responseXML = xmlDoc;
          fireReadyStateChange(xhr, 200);
        };
        xhr.onerror = function () {
          Strophe.error("Strophe xdr.onerror called");
          fireReadyStateChange(xhr, 500);
        };
        xhr.ontimeout = function () {
          Strophe.error("Strophe xdr.ontimeout called");
          fireReadyStateChange(xhr, 500);
        };
        return xhr;
      }

    } else {
      Strophe.info("XDomainRequest not found. Falling back to native XHR implementation.");
    }
  }
});