(function() {
  var DatabaseConnection, Q, mysql, _;

  mysql = require('mysql');

  _ = require("lodash");

  Q = require("q");

  DatabaseConnection = (function() {
    function DatabaseConnection() {}

    DatabaseConnection.getConnection = function() {
      var deferred;
      deferred = Q.defer();
      DatabaseConnection.pool.getConnection(function(err, connection) {
        if (err) {
          deferred.reject(err);
        }
        return deferred.resolve(connection);
      });
      return deferred.promise;
    };

    DatabaseConnection.connect = function(options) {
      return DatabaseConnection.pool = mysql.createPool({
        host: options.host || "",
        user: options.user || "",
        password: options.password || "",
        database: options.database || ""
      });
    };

    return DatabaseConnection;

  })();

  module.exports = DatabaseConnection;

}).call(this);
