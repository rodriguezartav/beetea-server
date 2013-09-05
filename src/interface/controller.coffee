BeeteaOperation = require("./operation")
QueryCommand = require("../basicCommands/queryCommand")
InsertCommand = require("../basicCommands/insertCommand")
UpdateCommand = require("../basicCommands/updateCommand")
DeleteCommand = require("../basicCommands/deleteCommand")
DatabaseConnection = require("./databaseConnection")
Model = require("./model")

class Controller

  constructor: (@app) ->
    @model = new Model(@constructor.route, @constructor.route)
    @defineCustomRoutes?()
    @defineRestRoutes()
    @
  
  fromJson: (data) ->
    return JSON.parse data
  
  defineRestRoutes: =>
    parent = @constructor
    route = "/bee/#{parent.route}"
    response = @app.get  route  + "/*" , @find
    response = @app.get  route         , @findAll
    response = @app.post route + "/*" , @update
    response = @app.put  route         , @create
    response = @app.del  route  + "/*" , @destroy

  find: (req,res) =>
    operation = BeeteaOperation.staticOperation DatabaseConnection , [ "select * from #{@model.tableName} where id = #{req.params[0]}" ]
    @handleQueryResponse(operation,req, res,true)

  findAll: (req,res) =>
    operation = BeeteaOperation.staticOperation DatabaseConnection , [ "select * from #{@model.tableName}" ]
    @handleQueryResponse(operation,req, res)

  create: (req,res) =>
    @model.body = req.body
    operation = BeeteaOperation.staticOperation DatabaseConnection , [new InsertCommand(@model)]
    @handleRestResponse(operation,req, res,true)

  update: (req,res) =>
    @model.body = req.body
    operation = BeeteaOperation.staticOperation DatabaseConnection , [new UpdateCommand(@model)]
    @handleRestResponse(operation,req, res,true)

  destroy: (req,res) =>
    @model.body = id: req.params[0]
    operation = BeeteaOperation.staticOperation DatabaseConnection , [new DeleteCommand(@model)]
    @handleRestResponse(operation,req, res,true)

  handleQueryResponse: (promise,req,res, single = false) ->
    promise.then (response) ->
      results = response.results[0]
      if single and results.length == 0
        res.status 404
        res.send "Record not found"
      else
        res.status 200
        res.send if single then results[0] else results
    promise.fail (error) ->
      res.status 500
      res.send error

  handleRestResponse: (promise,req,res,single=false) ->
    promise.then (response) ->
      results = response.results[0]
      if single and results.affectedRows ==0 and results.changedRows ==0 and results.insertId == 0
        res.status 404
        res.send "Record Not Found"
      else
        res.status 200
        if !req.body.id and results.insertId then req.body.id = results.insertId
        res.send req.body
    promise.fail (error) ->
      res.status 500
      res.send error

module.exports = Controller