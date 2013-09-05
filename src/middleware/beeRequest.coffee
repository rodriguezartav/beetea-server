_  = require 'lodash'
_.str = require 'underscore.string'

# adds entity , action and id to a express request
# used for policies
module.exports = beeRequest = (options = {}) ->
  throw "Activation Route must be assigned" if !options.activationRoute
  
  beeRequest = (req, res, next) ->
    prePath = req.path
    index = prePath.indexOf("/" + options.activationRoute)
    return next() if index == -1

    path = req.path.substring index + options.activationRoute.length
    pieces = path.split('/');
    pieces.reverse()
    pieces.pop()
    pieces.reverse()
    return next() if pieces.length == 0

    req.beeRequest =
      entity: pieces[0]
      entityId: if pieces.length > 1 and pieces[1] then pieces[1] else null
    

    if req.method == "GET" and req.beeRequest.entityId != null  then req.beeRequest.action = "find"
    if req.method == "GET" and req.beeRequest.entityId == null  then req.beeRequest.action = "findAll"
    if req.method == "DELETE" and req.beeRequest.entityId != null  then req.beeRequest.action = "destroy"
    if req.method == "POST" and req.beeRequest.entityId != null then req.beeRequest.action = "update"
    if req.method == "PUT"                                      then req.beeRequest.action = "create"

    next();


