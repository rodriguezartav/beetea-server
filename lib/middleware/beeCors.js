(function() {
  var BeeCors;

  module.exports = BeeCors = function(options) {
    var _this = this;
    if (options == null) {
      options = {};
    }
    return BeeCors = function(req, res, next) {
      var originObject, requestOrigin, resolvedOrigin, thisOrigin, _i, _len, _ref;
      if (!req.headers.origin) {
        return next();
      }
      resolvedOrigin = false;
      _ref = options.origins;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        originObject = _ref[_i];
        requestOrigin = req.headers.origin.toLowerCase();
        thisOrigin = originObject.origin.toLowerCase();
        if (requestOrigin.indexOf(thisOrigin) > -1) {
          resolvedOrigin = originObject;
        }
      }
      if (!resolvedOrigin) {
        return res.send(500);
      }
      if (req.method === 'OPTIONS') {
        return res.send(200);
      }
      res.header('Access-Control-Allow-Origin', req.headers.origin);
      res.header('Access-Control-Allow-Methods', resolvedOrigin.allowedMethods);
      res.header("Access-Control-Allow-Headers", "Accept,Content-Type,X-Requested-With,X-Parse-REST-API-Key,X-Parse-REST-API-Key");
      return next();
    };
  };

}).call(this);
