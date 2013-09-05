(function() {
  var BeeteaCommand, BeeteaOperation, CustomCommand, DatabaseConnection, DeleteCommand, InsertCommand, InsertOperation, Model, QueryCommand, model, should, _,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  should = require("should");

  BeeteaOperation = require("../../lib/beetea").Operation;

  QueryCommand = require("../../lib/beetea").QueryCommand;

  DeleteCommand = require("../../lib/beetea").DeleteCommand;

  InsertCommand = require("../../lib/beetea").InsertCommand;

  CustomCommand = require("../../lib/beetea").CustomCommand;

  DatabaseConnection = require("../../lib/beetea").DatabaseConnection;

  Model = require("../../lib/beetea").Model;

  model = new Model("modelname", "BasicModelTable", {});

  BeeteaCommand = require("../../lib/beetea").Command;

  _ = require("lodash");

  InsertOperation = (function(_super) {
    __extends(InsertOperation, _super);

    function InsertOperation(model, connection) {
      this.model = model;
      InsertOperation.__super__.constructor.call(this, connection);
    }

    InsertOperation.prototype.setCommands = function() {
      return this.commands.push(new InsertCommand(this.model));
    };

    return InsertOperation;

  })(BeeteaOperation);

  describe("Custom Command", function() {
    before(function(done) {
      DatabaseConnection.connect({
        database: "test"
      });
      return DatabaseConnection.getConnection().then(function(connection) {
        return connection.query("create Table IF NOT EXISTS BasicModelTable (id int AUTO_INCREMENT, name NVARCHAR(55) , PRIMARY KEY (id), lastname NVARCHAR(44) )", function(error, success) {
          if (error) {
            throw error;
          }
          return done();
        });
      });
    });
    it('should rollback insert an item', function(done) {
      var connectionPromise;
      connectionPromise = DatabaseConnection.getConnection();
      model.body = {
        name: "test"
      };
      return connectionPromise.then(function(connection) {
        var operation, promise;
        operation = new InsertOperation(model, connection);
        operation.commands.push(new CustomCommand(function(results) {
          return "update BasicModelTable set name='test3' where id = " + results.insertId;
        }));
        promise = operation.execute();
        return promise.then(function(results) {
          return done();
        });
      });
    });
    return after(function(done) {
      return DatabaseConnection.getConnection().then(function(connection) {
        return connection.query("drop table BasicModelTable", function(transactionError, success) {
          if (transactionError) {
            throw transactionError;
          }
          return done();
        });
      });
    });
  });

}).call(this);
