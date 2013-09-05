(function() {
  var sessions, _;

  sessions = require("client-sessions");

  _ = require("lodash");

  module.exports = function(app, sessionConfig) {
    var cookie, options, _i, _len, _results;
    if (!app.use) {
      throw "First Argument should be a Connect/Express Application";
    }
    if (!_.isArray(sessionConfig)) {
      sessionConfig = [sessionConfig];
    }
    _results = [];
    for (_i = 0, _len = sessionConfig.length; _i < _len; _i++) {
      cookie = sessionConfig[_i];
      if (!cookie.name) {
        throw "Session Config must contain a name property";
      }
      if (!cookie.secret) {
        throw "Session Config must contain a secret property";
      }
      options = {
        duration: cookie.duration || 24 * 60 * 60 * 1000,
        path: cookie.path || "/",
        secure: cookie.secure === null ? true : cookie.secure,
        httpOnly: cookie.httpOnly === null ? true : cookie.httpOnly
      };
      _results.push(app.use(sessions({
        cookieName: cookie.name,
        secret: cookie.secret,
        duration: options.duration,
        cookie: {
          path: options.path,
          httpOnly: options.httpOnly,
          secure: options.secure
        }
      })));
    }
    return _results;
  };

}).call(this);
