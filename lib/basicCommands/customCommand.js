(function() {
  var Command, CustomCommand,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Command = require("../interface/command");

  CustomCommand = (function(_super) {
    __extends(CustomCommand, _super);

    function CustomCommand(customGet) {
      this.getQuery = customGet;
    }

    return CustomCommand;

  })(Command);

  module.exports = CustomCommand;

}).call(this);
