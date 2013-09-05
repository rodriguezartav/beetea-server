mysql = require('mysql');
_ = require("lodash")
Q  = require("q")

class DatabaseConnection

  @getConnection: ->
    deferred = Q.defer();
    DatabaseConnection.pool.getConnection (err,connection) ->
      deferred.reject err if err
      deferred.resolve connection
    deferred.promise
      
  @connect: (options) ->
    DatabaseConnection.pool  = mysql.createPool
      host     : options.host or ""
      user     : options.user or ""
      password : options.password or ""
      database : options.database or ""

module.exports = DatabaseConnection