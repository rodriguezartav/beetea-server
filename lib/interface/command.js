(function() {
  var Command;

  Command = (function() {
    var name;

    name = "";

    function Command() {}

    Command.prototype.getQuery = function() {
      return "";
    };

    return Command;

  })();

  module.exports = Command;

}).call(this);
