(function() {
  var BeeteaCommand, BeeteaOperation, Command1, Command2, DatabaseConnection, ErrorCommand, express, should, _, _ref, _ref1,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  should = require("should");

  express = require("express");

  BeeteaOperation = require("../../lib/beetea").Operation;

  BeeteaCommand = require("../../lib/beetea").Command;

  DatabaseConnection = require("../../lib/beetea").DatabaseConnection;

  _ = require("lodash");

  Command1 = (function(_super) {
    __extends(Command1, _super);

    function Command1() {
      _ref = Command1.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    Command1.prototype.getQuery = function(results) {
      return "select id from test";
    };

    return Command1;

  })(BeeteaCommand);

  Command2 = (function(_super) {
    __extends(Command2, _super);

    function Command2() {}

    Command2.prototype.getQuery = function(results) {
      return "select name from test";
    };

    return Command2;

  })(BeeteaCommand);

  ErrorCommand = (function(_super) {
    __extends(ErrorCommand, _super);

    function ErrorCommand() {
      _ref1 = ErrorCommand.__super__.constructor.apply(this, arguments);
      return _ref1;
    }

    ErrorCommand.prototype.getQuery = function(results) {
      return "query dsdfor error";
    };

    return ErrorCommand;

  })(BeeteaCommand);

  describe("AppBot Operation", function() {
    before(function(done) {
      DatabaseConnection.connect({
        database: "test"
      });
      return DatabaseConnection.getConnection().then(function(connection) {
        return connection.query("create Table IF NOT EXISTS test (id INT , name NVARCHAR(55))", function(error, success) {
          if (error) {
            throw error;
          }
          if (success) {
            return done();
          }
        });
      });
    });
    it('should instantiate an Operation', function(done) {
      var operation;
      operation = new BeeteaOperation();
      return done();
    });
    it('should execute an Operation', function(done) {
      return DatabaseConnection.getConnection().then(function(connection) {
        var operation;
        operation = new BeeteaOperation(connection);
        operation.commands.push(new Command1());
        operation.commands.push(new Command2());
        return operation.execute().then(function() {
          return done();
        });
      });
    });
    it('should throw an error', function(done) {
      var connectionPromise;
      connectionPromise = DatabaseConnection.getConnection();
      return connectionPromise.then(function(connection) {
        var operation, promise;
        operation = new BeeteaOperation(connection);
        operation.commands.push(new ErrorCommand());
        operation.commands = operation.commands.reverse();
        promise = operation.execute();
        return promise.fail(function(error) {
          error.should.not.equal(null);
          return done();
        });
      });
    });
    return after(function(done) {
      return DatabaseConnection.getConnection().then(function(connection) {
        return connection.query("drop table test", function(transactionError, success) {
          if (transactionError) {
            throw transactionError;
          }
          return done();
        });
      });
    });
  });

}).call(this);
