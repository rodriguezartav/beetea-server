(function() {
  var AppbotModel, _;

  _ = require("lodash");

  AppbotModel = (function() {
    function AppbotModel(name, tableName, body, id) {
      this.name = name;
      this.tableName = tableName;
      this.id = id != null ? id : null;
      _.extend(this, body);
      this;
    }

    AppbotModel.createFromRequest = function(req) {
      return new this.constructor("name", "tablename", {}, null);
    };

    return AppbotModel;

  })();

  module.exports = AppbotModel;

}).call(this);
