async = require("async")
_ = require("lodash")
Q = require("q")

## ALWAYS SEND MOST IMPORTANT COMMAND FIRST, THEN YOU KNOW TO USE RESULTS[0]

class AppbotOperation

  @queryToPromise: (connection, query) ->
    defered = Q.defer()
    connection.query query , (error, response) ->
      return defered.reject error if error
      defered.resolve response
    return defered.promise

  @staticOperation: (DatabaseConnection,commands,callback) ->
    throw "Second Argument should be array of strings" if !_.isArray commands
    defered = Q.defer()
    connectionPromise = DatabaseConnection.getConnection()
    connectionPromise.then (connection) ->
      operation = new AppbotOperation(connection)
      operation.commands = commands;
      operationPromise = operation.execute()
      operationPromise.then (results) ->
        defered.resolve results
        callback? null, results
      operationPromise.fail (error) ->
        defered.reject error
        callback? error
    connectionPromise.fail (error) ->
      defered.reject error
      callback? error

    return defered.promise

  constructor: (@connection, @commands = []) ->
    @setCommands() if @commands =[]

  setCommands: ->
    @commands= []

  execute: (finalCallback) =>
    @defered = Q.defer()
    
    @allResults = []
    @allRequests= []
    wrappedCommands = []
    wrappedCommands.push (transactionCallback) =>
      @connection.query "START TRANSACTION" , (queryError,queryResults) ->
        transactionCallback queryError , {}

    closureFn= (connection,command) =>
      (results,nextClosureFn) =>
        queryObject = if command.getQuery then command.getQuery(results) else command
        @connection.query queryObject, (queryError,queryResults) =>
          @allResults.push queryResults
          @allRequests.push queryObject
          nextClosureFn(queryError,queryResults)

    for command in @commands
      wrappedCommands.push closureFn(@connection,command)

    async.waterfall wrappedCommands , (transactionError, transactionResults) =>
      if transactionError
        @connection.query "ROLLBACK" , (rollBackError, response) =>
          @defered.reject transactionError
          finalCallback? [transactionError, rollBackError] if rollBackError
          finalCallback? [transactionError]
      else
        @connection.query "COMMIT" , (commitError, finalResults) =>
          @defered.resolve(results: @allResults , requests: @allRequests)
          finalCallback? [commitError] if commitError
          finalCallback? null, { results: @allResults, requests: @allRequests }

    return @defered.promise

  #example on how to build an executeOverride Function
  executeOverride: ->
    defered = Q.defer()
    @queryToPromise @connection , "START TRANSACTION"
    .then ->
      @queryToPromise @connection , "select 1;"
    .then ->
      @queryToPromise @connection , "COMMIT" 
    .fail (transactionError) ->
      @queryToPromise @connection , "ROLLBACK" 
      .fin ->
        defered.reject transactionError
    .fin ->
      defered.resolve true
        
    return defered.promise


module.exports = AppbotOperation