(function() {
  var beeRequest, _;

  _ = require('lodash');

  _.str = require('underscore.string');

  module.exports = beeRequest = function(options) {
    if (options == null) {
      options = {};
    }
    if (!options.activationRoute) {
      throw "Activation Route must be assigned";
    }
    return beeRequest = function(req, res, next) {
      var index, path, pieces, prePath;
      prePath = req.path;
      index = prePath.indexOf("/" + options.activationRoute);
      if (index === -1) {
        return next();
      }
      path = req.path.substring(index + options.activationRoute.length);
      pieces = path.split('/');
      pieces.reverse();
      pieces.pop();
      pieces.reverse();
      if (pieces.length === 0) {
        return next();
      }
      req.beeRequest = {
        entity: pieces[0],
        entityId: pieces.length > 1 && pieces[1] ? pieces[1] : null
      };
      if (req.method === "GET" && req.beeRequest.entityId !== null) {
        req.beeRequest.action = "find";
      }
      if (req.method === "GET" && req.beeRequest.entityId === null) {
        req.beeRequest.action = "findAll";
      }
      if (req.method === "DELETE" && req.beeRequest.entityId !== null) {
        req.beeRequest.action = "destroy";
      }
      if (req.method === "POST" && req.beeRequest.entityId !== null) {
        req.beeRequest.action = "update";
      }
      if (req.method === "PUT") {
        req.beeRequest.action = "create";
      }
      return next();
    };
  };

}).call(this);
