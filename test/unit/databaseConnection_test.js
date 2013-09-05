(function() {
  var express, should, _;

  should = require("should");

  express = require("express");

  _ = require("lodash");

  beforeEach(function() {
    return this.DatabaseConnection = require("../../lib/beetea").DatabaseConnection;
  });

  describe("AppBot DatabaseConnection", function() {
    it('should behave as Singleton', function() {
      var AppbotDatabaseConnection1, AppbotDatabaseConnection2;
      AppbotDatabaseConnection1 = require("../../lib/beetea").DatabaseConnection;
      AppbotDatabaseConnection1.connection = "ok";
      AppbotDatabaseConnection2 = require("../../lib/beetea").DatabaseConnection;
      return AppbotDatabaseConnection2.connection.should.be.equal("ok");
    });
    it("should have a connection pool", function() {
      this.DatabaseConnection.connect({
        host: "",
        user: "",
        password: ""
      });
      return this.DatabaseConnection.pool.should.not.equal(null);
    });
    return it("should try to open a connection from pool", function(done) {
      return this.DatabaseConnection.getConnection().then(function(connection) {
        connection.should.not.be.equal(null);
        return done();
      }).fail(function(error) {
        return console.log(error);
      });
    });
  });

}).call(this);
