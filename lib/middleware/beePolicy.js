(function() {
  var beePolicy, _;

  _ = require("lodash");

  module.exports = beePolicy = function(options) {
    if (options == null) {
      options = {};
    }
    if (!options.policies) {
      throw "Policies array must be provided options.policies = []";
    }
    if (!options.rules) {
      throw "Riles array must be policiesoptions.rules";
    }
    return beePolicy = function(req, res, next) {
      var action, entity, entityPolicies, result, rule, rules, _i, _len;
      entity = req.beeRequest.entity || "*";
      action = req.beeRequest.action || "*";
      entityPolicies = options.policies[entity];
      if (_.isUndefined(entityPolicies)) {
        entityPolicies = options.policies["*"];
      }
      rules = entityPolicies[action];
      if (_.isUndefined(rules)) {
        rules = entityPolicies["*"];
      }
      if (_.isString(rules)) {
        rules = [rules];
      }
      result = true;
      for (_i = 0, _len = rules.length; _i < _len; _i++) {
        rule = rules[_i];
        if (result === true) {
          result = options.rules[rule](req, res);
        }
      }
      if (!result) {
        res.status(500);
        return res.send("Security Error: Permission not granted.");
      } else {
        if (result) {
          return next();
        }
      }
    };
  };

}).call(this);
