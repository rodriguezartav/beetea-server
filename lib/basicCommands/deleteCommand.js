(function() {
  var Command, DeleteCommand,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Command = require("../interface/command");

  DeleteCommand = (function(_super) {
    __extends(DeleteCommand, _super);

    function DeleteCommand(model) {
      this.model = model;
    }

    DeleteCommand.prototype.getQuery = function() {
      var query;
      return query = {
        sql: "Delete from " + this.model.tableName + " where id = ?",
        values: this.model.body.id
      };
    };

    return DeleteCommand;

  })(Command);

  module.exports = DeleteCommand;

}).call(this);
