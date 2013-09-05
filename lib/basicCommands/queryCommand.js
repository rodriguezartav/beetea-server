(function() {
  var Command, QueryCommand,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Command = require("../interface/command");

  QueryCommand = (function(_super) {
    __extends(QueryCommand, _super);

    function QueryCommand(options) {
      if (options.query) {
        this.query = options;
      } else {

      }
      this.model = options;
    }

    QueryCommand.prototype.getQuery = function() {
      if (this.query) {
        return this.query;
      }
      return "select * from " + this.model.tableName;
    };

    return QueryCommand;

  })(Command);

  module.exports = QueryCommand;

}).call(this);
