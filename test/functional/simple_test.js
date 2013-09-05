(function() {
  var BeeteaController, BeeteaOperation, Browser, DatabaseConnection, Session, TestController, assert, express, request, should, superagent, _,
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

  TestController = (function(_super) {
    __extends(TestController, _super);

    TestController.route = "testController";

    function TestController(app) {
      this.app = app;
      TestController.__super__.constructor.call(this, this.app);
    }

    return TestController;

  })(BeeteaController);

  describe("Simple Controller Test", function() {
    before(function(done) {
      var staticCommand, staticPromise, testController;
      DatabaseConnection.connect({
        database: "test"
      });
      this.app = express();
      this.app.use(express.bodyParser());
      testController = new TestController(this.app);
      this.app.listen(9998);
      staticCommand = "create Table IF NOT EXISTS TestController (id int AUTO_INCREMENT, name NVARCHAR(55) ,       PRIMARY KEY (id), lastname NVARCHAR(44) )";
      staticPromise = BeeteaOperation.staticOperation(DatabaseConnection, [staticCommand]);
      return staticPromise.then(function(results) {
        return done();
      });
    });
    it("insert should return 200", function(done) {
      return request("http://localhost:9998").put("/bee/testController").send({
        name: "test"
      }).end(function(err, res) {
        if (err) {
          throw err;
        }
        res.should.have.status(200);
        return done();
      });
    });
    it("update should return 200", function(done) {
      return request("http://localhost:9998").post("/bee/testController/1").send({
        id: 1,
        name: "test2"
      }).end(function(err, res) {
        if (err) {
          throw err;
        }
        res.should.have.status(200);
        return done();
      });
    });
    it("get one should return 200", function(done) {
      return request("http://localhost:9998").get("/bee/testController/1").send().end(function(err, res) {
        if (err) {
          throw err;
        }
        res.should.have.status(200);
        return done();
      });
    });
    it("delete should return 200", function(done) {
      return request("http://localhost:9998").del("/bee/testController/1").send({
        name: "test"
      }).end(function(err, res) {
        if (err) {
          throw err;
        }
        res.should.have.status(200);
        return done();
      });
    });
    it("get all should return 200", function(done) {
      return request("http://localhost:9998").get("/bee/testController").send().end(function(err, res) {
        if (err) {
          throw err;
        }
        res.should.have.status(200);
        return done();
      });
    });
    it("get one should return 404", function(done) {
      return request("http://localhost:9998").get("/bee/testController/1").send().end(function(err, res) {
        if (err) {
          throw err;
        }
        res.should.have.status(404);
        return done();
      });
    });
    return after(function(done) {
      var staticPromise;
      staticPromise = BeeteaOperation.staticOperation(DatabaseConnection, ["drop Table TestController"]);
      return staticPromise.then(function(results) {
        return done();
      });
    });
  });

}).call(this);
