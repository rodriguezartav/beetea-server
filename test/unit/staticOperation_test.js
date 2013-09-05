(function() {
  var BeeteaOperation, DatabaseConnection, should, _;

  should = require("should");

  BeeteaOperation = require("../../lib/beetea").Operation;

  DatabaseConnection = require("../../lib/beetea").DatabaseConnection;

  _ = require("lodash");

  describe("Static Operation", function() {
    before(function(done) {
      DatabaseConnection.connect({
        database: "test"
      });
      return done();
    });
    return it('should perform all tasks', function(done) {
      var staticCommands, staticPromise;
      staticCommands = ["create Table IF NOT EXISTS StaticTable (id int AUTO_INCREMENT, name NVARCHAR(55) , PRIMARY KEY (id), lastname NVARCHAR(44) )", "insert into StaticTable (name) values ('test')", "select * from StaticTable"];
      staticPromise = BeeteaOperation.staticOperation(DatabaseConnection, staticCommands);
      staticPromise.then(function(results) {
        var result, _i, _len, _ref;
        _ref = results.results[2];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          result = _ref[_i];
          result.name.should.equal("test");
        }
        return BeeteaOperation.staticOperation(DatabaseConnection, ["drop table StaticTable"], function(error, results) {
          if (error) {
            throw error;
          }
          return done();
        });
      });
      return staticPromise.fail(function(error) {
        return done();
      });
    });
  });

}).call(this);
