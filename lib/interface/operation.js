(function() {
  var AppbotOperation, Q, async, _,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  async = require("async");

  _ = require("lodash");

  Q = require("q");

  AppbotOperation = (function() {
    AppbotOperation.queryToPromise = function(connection, query) {
      var defered;
      defered = Q.defer();
      connection.query(query, function(error, response) {
        if (error) {
          return defered.reject(error);
        }
        return defered.resolve(response);
      });
      return defered.promise;
    };

    AppbotOperation.staticOperation = function(DatabaseConnection, commands, callback) {
      var connectionPromise, defered;
      if (!_.isArray(commands)) {
        throw "Second Argument should be array of strings";
      }
      defered = Q.defer();
      connectionPromise = DatabaseConnection.getConnection();
      connectionPromise.then(function(connection) {
        var operation, operationPromise;
        operation = new AppbotOperation(connection);
        operation.commands = commands;
        operationPromise = operation.execute();
        operationPromise.then(function(results) {
          defered.resolve(results);
          return typeof callback === "function" ? callback(null, results) : void 0;
        });
        return operationPromise.fail(function(error) {
          defered.reject(error);
          return typeof callback === "function" ? callback(error) : void 0;
        });
      });
      connectionPromise.fail(function(error) {
        defered.reject(error);
        return typeof callback === "function" ? callback(error) : void 0;
      });
      return defered.promise;
    };

    function AppbotOperation(connection, commands) {
      this.connection = connection;
      this.commands = commands != null ? commands : [];
      this.execute = __bind(this.execute, this);
      if (this.commands = []) {
        this.setCommands();
      }
    }

    AppbotOperation.prototype.setCommands = function() {
      return this.commands = [];
    };

    AppbotOperation.prototype.execute = function(finalCallback) {
      var closureFn, command, wrappedCommands, _i, _len, _ref,
        _this = this;
      this.defered = Q.defer();
      this.allResults = [];
      this.allRequests = [];
      wrappedCommands = [];
      wrappedCommands.push(function(transactionCallback) {
        return _this.connection.query("START TRANSACTION", function(queryError, queryResults) {
          return transactionCallback(queryError, {});
        });
      });
      closureFn = function(connection, command) {
        return function(results, nextClosureFn) {
          var queryObject;
          queryObject = command.getQuery ? command.getQuery(results) : command;
          return _this.connection.query(queryObject, function(queryError, queryResults) {
            _this.allResults.push(queryResults);
            _this.allRequests.push(queryObject);
            return nextClosureFn(queryError, queryResults);
          });
        };
      };
      _ref = this.commands;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        command = _ref[_i];
        wrappedCommands.push(closureFn(this.connection, command));
      }
      async.waterfall(wrappedCommands, function(transactionError, transactionResults) {
        if (transactionError) {
          return _this.connection.query("ROLLBACK", function(rollBackError, response) {
            _this.defered.reject(transactionError);
            if (rollBackError) {
              if (typeof finalCallback === "function") {
                finalCallback([transactionError, rollBackError]);
              }
            }
            return typeof finalCallback === "function" ? finalCallback([transactionError]) : void 0;
          });
        } else {
          return _this.connection.query("COMMIT", function(commitError, finalResults) {
            _this.defered.resolve({
              results: _this.allResults,
              requests: _this.allRequests
            });
            if (commitError) {
              if (typeof finalCallback === "function") {
                finalCallback([commitError]);
              }
            }
            return typeof finalCallback === "function" ? finalCallback(null, {
              results: _this.allResults,
              requests: _this.allRequests
            }) : void 0;
          });
        }
      });
      return this.defered.promise;
    };

    AppbotOperation.prototype.executeOverride = function() {
      var defered;
      defered = Q.defer();
      this.queryToPromise(this.connection, "START TRANSACTION".then(function() {
        return this.queryToPromise(this.connection, "select 1;");
      }).then(function() {
        return this.queryToPromise(this.connection, "COMMIT");
      }).fail(function(transactionError) {
        return this.queryToPromise(this.connection, "ROLLBACK".fin(function() {
          return defered.reject(transactionError);
        }));
      }).fin(function() {
        return defered.resolve(true);
      }));
      return defered.promise;
    };

    return AppbotOperation;

  })();

  module.exports = AppbotOperation;

}).call(this);
