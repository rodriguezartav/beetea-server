(function() {
  var Session, express, should;

  should = require("should");

  express = require("express");

  Session = require("../../lib/session");

  beforeEach(function() {
    return this.app = express();
  });

  describe("Setup Validation", function() {
    it('Should throw exception if first argument is not Connect App', function(done) {
      var error;
      try {
        Session({}, [
          {
            name: "session"
          }
        ]);
      } catch (_error) {
        error = _error;
        error.should.equal("First Argument should be a Connect/Express Application");
      }
      return done();
    });
    it('Should throw exception if sessionConfig does not have name property', function(done) {
      var error;
      try {
        Session(this.app, [{}]);
      } catch (_error) {
        error = _error;
        error.should.equal("Session Config must contain a name property");
      }
      return done();
    });
    it('Should throw exception if sessionConfig does not have secret property', function(done) {
      var error;
      try {
        Session(this.app, [
          {
            name: "session"
          }
        ]);
      } catch (_error) {
        error = _error;
        error.should.equal("Session Config must contain a secret property");
      }
      return done();
    });
    return it('Should accept object insted of array of Session Config', function(done) {
      Session(this.app, {
        name: "session",
        secret: "secret"
      });
      return done();
    });
  });

}).call(this);
