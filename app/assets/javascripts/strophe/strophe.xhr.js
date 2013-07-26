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