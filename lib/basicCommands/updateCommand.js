(function() {
  var Command, UpdateCommand,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Command = require("../interface/command");

  UpdateCommand = (function(_super) {
    __extends(UpdateCommand, _super);

    function UpdateCommand(model) {
      this.model = model;
      this.name = "InsertCommand for " + this.model.name;
    }

    UpdateCommand.prototype.getQuery = function() {
      var modelId, query;
      modelId = this.model.body.id;
      delete this.model.body.id;
      query = {
        sql: "UPDATE " + this.model.tableName + " SET ? where id = " + modelId,
        values: this.model.body
      };
      this.model.body.id = modelId;
      return query;
    };

    return UpdateCommand;

  })(Command);

  module.exports = UpdateCommand;

}).call(this);
