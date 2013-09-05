(function() {
  var BeeteaOperation, DatabaseConnection, should, _;

  should = require("should");

  BeeteaOperation = require("../../lib/beetea").Operation;

  DatabaseConnection = require("../../lib/beetea").DatabaseConnection;

  _ = require("lodash");

  describe("Exceptional Operations", function() {
    before(function(done) {
      DatabaseConnection.connect({
        database: "test"
      });
      return done();
    });
    it('should pass error in argument', function(done) {
      return BeeteaOperation.staticOperation(DatabaseConnection, ["select * from tableNotExists"], function(error, success) {
        error.should.not.equal(null);
        return done();
      });
    });
    it('should result in success', function(done) {
      return BeeteaOperation.staticOperation(DatabaseConnection, ["select 1;"], function(error, success) {
        return done();
      });
    });
    it('should catch error in success', function(done) {
      var staticPromise;
      staticPromise = BeeteaOperation.staticOperation(DatabaseConnection, ["select * from tableNotExists", ""]);
      staticPromise.then(function(results) {
        throw "error";
      }).fail(function(error) {
        error.should.equal("error");
        return done();
      });
      return staticPromise.fail(function(error) {
        return done();
      });
    });
    return it('should catch error in success', function(done) {
      var _this = this;
      return BeeteaOperation.staticOperation(DatabaseConnection, ["select * from tableNotExists"], function(error, success) {
        error.should.not.be.equal(null);
        return done();
      });
    });
  });

}).call(this);
