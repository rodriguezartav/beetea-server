(function() {
  var BeeteaOperation, DatabaseConnection, DeleteCommand, DeleteOperation, InsertCommand, InsertOperation, Model, QueryCommand, QueryOperation, UpdateCommand, UpdateOperation, model, should, _,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  should = require("should");

  BeeteaOperation = require("../../lib/beetea").Operation;

  QueryCommand = require("../../lib/beetea").QueryCommand;

  UpdateCommand = require("../../lib/beetea").UpdateCommand;

  DeleteCommand = require("../../lib/beetea").DeleteCommand;

  InsertCommand = require("../../lib/beetea").InsertCommand;

  DatabaseConnection = require("../../lib/beetea").DatabaseConnection;

  Model = require("../../lib/beetea").Model;

  model = new Model("modelname", "BasicModelTable", {});

  _ = require("lodash");

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

  DeleteOperation = (function(_super) {
    __extends(DeleteOperation, _super);

    function DeleteOperation(model, connection) {
      this.model = model;
      DeleteOperation.__super__.constructor.call(this, connection);
    }

    DeleteOperation.prototype.setCommands = function() {
      return this.commands.push(new DeleteCommand(this.model));
    };

    return DeleteOperation;

  })(BeeteaOperation);

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

  UpdateOperation = (function(_super) {
    __extends(UpdateOperation, _super);

    function UpdateOperation(model, connection) {
      this.model = model;
      UpdateOperation.__super__.constructor.call(this, connection);
    }

    UpdateOperation.prototype.setCommands = function() {
      return this.commands.push(new UpdateCommand(this.model));
    };

    return UpdateOperation;

  })(BeeteaOperation);

  describe("Basic Command", function() {
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
    it('should inster an item', function(done) {
      var connectionPromise;
      connectionPromise = DatabaseConnection.getConnection();
      model.body = {
        name: "test",
        lastname: "lastnametest"
      };
      return connectionPromise.then(function(connection) {
        var operation, promise;
        operation = new InsertOperation(model, connection);
        promise = operation.execute();
        return promise.then(function(results) {
          results.results.length.should.equal(1);
          return done();
        });
      });
    });
    it('should update the item', function(done) {
      var connectionPromise;
      connectionPromise = DatabaseConnection.getConnection();
      return connectionPromise.then(function(connection) {
        var operation, promise;
        model.body = {
          id: 1,
          name: "test3"
        };
        operation = new UpdateOperation(model, connection);
        return promise = operation.execute(function(error, results) {
          if (error) {
            throw error;
          }
          return done();
        });
      });
    });
    it('should query the updated item', function(done) {
      var connectionPromise;
      connectionPromise = DatabaseConnection.getConnection();
      connectionPromise.fail(function(error) {
        console.log(error);
        return done();
      });
      return connectionPromise.then(function(connection) {
        var operation, promise;
        operation = new QueryOperation(model, connection);
        return promise = operation.execute(function(error, results) {
          var item, _i, _len, _ref;
          results.results[0].length.should.be.above(0);
          _ref = results.results[0];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            item = _ref[_i];
            item.name.should.equal("test3");
            item.lastname.should.equal("lastnametest");
          }
          return done();
        });
      });
    });
    it('should delete the item', function(done) {
      var connectionPromise;
      connectionPromise = DatabaseConnection.getConnection();
      return connectionPromise.then(function(connection) {
        var operation, promise;
        model.body = {
          id: 1
        };
        operation = new DeleteOperation(model, connection);
        return promise = operation.execute(function(error, results) {
          if (error) {
            throw error;
          }
          return done();
        });
      });
    });
    it('should query an get 0 items', function(done) {
      var connectionPromise;
      connectionPromise = DatabaseConnection.getConnection();
      connectionPromise.fail(function(error) {
        console.log(error);
        return done();
      });
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
