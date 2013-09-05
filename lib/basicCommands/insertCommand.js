(function() {
  var Command, InsertCommand,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Command = require("../interface/command");

  InsertCommand = (function(_super) {
    __extends(InsertCommand, _super);

    function InsertCommand(model) {
      this.model = model;
      this.name = "InsertCommand for " + this.model.name;
    }

    InsertCommand.prototype.getQuery = function() {
      var query;
      return query = {
        sql: "INSERT INTO " + this.model.tableName + " SET ?",
        values: this.model.body
      };
    };

    return InsertCommand;

  })(Command);

  module.exports = InsertCommand;

}).call(this);
