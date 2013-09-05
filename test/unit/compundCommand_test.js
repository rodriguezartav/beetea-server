(function() {
  var BeeteaCommand, BeeteaOperation, DatabaseConnection, DeleteCommand, InsertCommand, InsertOperation, Model, QueryCommand, QueryOperation, UpdateCommand, model, should, _,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  should = require("should");

  BeeteaOperation = require("../../lib/beetea").Operation;

  QueryCommand = require("../../lib/beetea").QueryCommand;

  DeleteCommand = require("../../lib/beetea").DeleteCommand;

  InsertCommand = require("../../lib/beetea").InsertCommand;

  DatabaseConnection = require("../../lib/beetea").DatabaseConnection;

  Model = require("../../lib/beetea").Model;

  model = new Model("modelname", "BasicModelTable", {});

  BeeteaCommand = require("../../lib/beetea").Command;

  _ = require("lodash");

  UpdateCommand = (function(_super) {
    __extends(UpdateCommand, _super);

    function UpdateCommand(model) {
      this.model = model;
      this.name = "UpdateCommand for " + this.model.name;
    }

    UpdateCommand.prototype.getQuery = function(results) {
      var query;
      this.model.body.otherColumn = "should throw error";
      query = {
        sql: "UPDATE " + this.model.tableName + " SET ? where id = " + results.insertId,
        values: this.model.body
      };
      return query;
    };

    return UpdateCommand;

  })(BeeteaCommand);

  InsertOperation = (function(_super) {
    __extends(InsertOperation, _super);

    function InsertOperation(model, connection) {
      this.model = model;
      InsertOperation.__super__.constructor.call(this, connection);
    }

    InsertOperation.prototype.setCommands = function() {
      this.commands.push(new InsertCommand(this.model));
      return this.commands.push(new UpdateCommand(this.model));
    };

    return InsertOperation;

  })(BeeteaOperation);

  QueryOperation = (function(_super) {
    __extends(QueryOperation, _super);

    function QueryOperation(model, connection) {
      this.model = model;
      QueryOperation.__super__.constructor.call(this, connection);
    }

    QueryOperation.prototype.setCommands = function() {
      return this.commands.push(new QueryCommand(this.model));
    };

    return QueryOperation;

  })(BeeteaOperation);

  describe("Compound Command", function() {
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
        promise = operation.execute();
        return promise.fail(function(error) {
          return done();
        });
      });
    });
    it('should query and get 0 items', function(done) {
      var connectionPromise;
      connectionPromise = DatabaseConnection.getConnection();
      return connectionPromise.then(function(connection) {
        var operation, promise;
        operation = new QueryOperation(model, connection);
        return promise = operation.execute(function(error, results) {
          results.results[0].length.should.equal(0);
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
