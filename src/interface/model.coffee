_ = require("lodash")

class AppbotModel

  constructor: (@name,@tableName,body,@id=null) ->
    _.extend(@,body)
    @

  @createFromRequest: (req) ->
    return new @.constructor("name","tablename",{},null)
    

module.exports = AppbotModel