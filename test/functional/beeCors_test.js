(function() {
  var BeeteaController, BeeteaOperation, Browser, DatabaseConnection, Session, TestController, assert, beeCors, express, request, should, superagent, _,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  should = require("should");

  express = require("express");

  BeeteaController = require("../../lib/beetea").Controller;

  DatabaseConnection = require('../../lib/beetea').DatabaseConnection;

  BeeteaOperation = require("../../lib/beetea").Operation;

  should = require("should");

  request = require('supertest');

  superagent = require('superagent');

  express = require("express");

  Session = require("../../lib/session");

  assert = require('assert');

  Browser = require('zombie');

  process.env.NODE_ENV = 'test';

  _ = require("lodash");

  beeCors = require("../../lib/middleware/beeCors");

  _ = require("lodash");

  TestController = (function(_super) {
    __extends(TestController, _super);

    TestController.route = "testController";

    function TestController(app) {
      this.app = app;
      TestController.__super__.constructor.call(this, this.app);
    }

    return TestController;

  })(BeeteaController);

  describe("Bee Cors Test", function() {
    before(function(done) {
      var testController;
      DatabaseConnection.connect({
        database: "test"
      });
      this.app = express();
      this.app.use(express.bodyParser());
      this.app.use(beeCors({
        origins: [
          {
            origin: "allowedDomain.com",
            allowedMethods: 'GET,PUT,POST,DELETE'
          }, {
            origin: "OtherallowedDomain.com",
            allowedMethods: 'GET,PUT,POST,DELETE'
          }
        ]
      }));
      testController = new TestController(this.app);
      this.app.listen(9994);
      this.app.get("/", function(req, res) {
        res.status(200);
        return res.send("ok");
      });
      return done();
    });
    it("it should return 200", function(done) {
      return request("http://localhost:9994").get("/").set("origin", "http://www.allowedDomain.com").send().end(function(err, res) {
        if (err) {
          throw err;
        }
        _.isUndefined(res.headers["access-control-allow-origin"]).should.equal(false);
        return done();
      });
    });
    it("it should return 200 with other domain", function(done) {
      return request("http://localhost:9994").get("/").set("origin", "http://www.otherallowedDomain.com").send().end(function(err, res) {
        if (err) {
          throw err;
        }
        _.isUndefined(res.headers["access-control-allow-origin"]).should.equal(false);
        return done();
      });
    });
    it("it should return 200, with no headers", function(done) {
      return request("http://localhost:9994").get("/").send().end(function(err, res) {
        if (err) {
          throw err;
        }
        _.isUndefined(res.headers["access-control-allow-origin"]).should.equal(true);
        return done();
      });
    });
    return it("it should return 500 because of cors configuration", function(done) {
      return request("http://localhost:9994").get("/").set("origin", "http://otherDomain.com").send().end(function(err, res) {
        if (err) {
          throw err;
        }
        res.status.should.equal(500);
        return done();
      });
    });
  });

}).call(this);
