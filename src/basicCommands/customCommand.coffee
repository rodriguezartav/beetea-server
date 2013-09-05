Command = require("../interface/command")


class CustomCommand extends Command

  constructor: (customGet) ->
    @getQuery = customGet


module.exports = CustomCommand