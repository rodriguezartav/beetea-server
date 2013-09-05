(function() {
  var BeeteaController, BeeteaOperation, Browser, DatabaseConnection, Session, TestController, assert, beeRequest, express, request, should, superagent, _,
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

  beeRequest = require("../../lib/middleware/beeRequest");

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

  describe("Bee Request Test", function() {
    before(function(done) {
      var testController;
      DatabaseConnection.connect({
        database: "test"
      });
      this.app = express();
      this.app.use(express.bodyParser());
      this.app.use(beeRequest({
        activationRoute: "bee"
      }));
      testController = new TestController(this.app);
      this.app.listen(9997);
      this.app.get("/", function(req, res) {
        return res.send(req.beeRequest);
      });
      this.app.get("/noBee", function(req, res) {
        return res.send(req.beeRequest);
      });
      this.app.get("/bee", function(req, res) {
        return res.send(req.beeRequest);
      });
      this.app.get("/bee/tea", function(req, res) {
        return res.send(req.beeRequest);
      });
      this.app.get("/bee/tea/1", function(req, res) {
        return res.send(req.beeRequest);
      });
      this.app.post("/bee/tea/1", function(req, res) {
        return res.send(req.beeRequest);
      });
      this.app.del("/bee/tea/1", function(req, res) {
        return res.send(req.beeRequest);
      });
      this.app.put("/bee/tea", function(req, res) {
        return res.send(req.beeRequest);
      });
      return done();
    });
    it("it should work with no path", function(done) {
      return request("http://localhost:9997").get("/").send().end(function(err, res) {
        if (err) {
          throw err;
        }
        return done();
      });
    });
    it("it should work with 1 path", function(done) {
      return request("http://localhost:9997").get("/bee").send().end(function(err, res) {
        if (err) {
          throw err;
        }
        return done();
      });
    });
    it("it should work with 2 path", function(done) {
      return request("http://localhost:9997").get("/bee/tea").send().end(function(err, res) {
        if (err) {
          throw err;
        }
        res.body.action.should.equal("findAll");
        return done();
      });
    });
    it("it should work with 2 path and id", function(done) {
      return request("http://localhost:9997").get("/bee/tea/1").send().end(function(err, res) {
        if (err) {
          throw err;
        }
        res.body.action.should.equal("find");
        res.body.entityId.should.equal("1");
        return done();
      });
    });
    it("it should post with post 2 path and id", function(done) {
      return request("http://localhost:9997").post("/bee/tea/1").send().end(function(err, res) {
        if (err) {
          throw err;
        }
        res.body.action.should.equal("update");
        res.body.entityId.should.equal("1");
        return done();
      });
    });
    it("it should put with put 2 path", function(done) {
      return request("http://localhost:9997").put("/bee/tea").send().end(function(err, res) {
        if (err) {
          throw err;
        }
        res.body.action.should.equal("create");
        return done();
      });
    });
    it("it should del with 2 path and id", function(done) {
      return request("http://localhost:9997").del("/bee/tea/1").send().end(function(err, res) {
        if (err) {
          throw err;
        }
        res.body.action.should.equal("destroy");
        res.body.entityId.should.equal("1");
        return done();
      });
    });
    return it("it should no contain beeRequest", function(done) {
      return request("http://localhost:9997").del("/noBee").send().end(function(err, res) {
        if (err) {
          throw err;
        }
        return done();
      });
    });
  });

}).call(this);
