(function() {
  var BeeteaController, BeeteaOperation, Browser, DatabaseConnection, Session, assert, beePolicy, beeRequest, express, request, should, superagent, _;

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

  beePolicy = require("../../lib/middleware/beePolicy");

  _ = require("lodash");

  describe("Bee Policy Request Test", function() {
    before(function(done) {
      var policies, rules;
      DatabaseConnection.connect({
        database: "test"
      });
      policies = {
        tea: {
          "*": 'allow',
          "update": ["allow"],
          "create": ["allow", "block"],
          "find": ["block", "allow"]
        },
        "*": {
          "*": "allow"
        }
      };
      rules = {
        block: function(req, res) {
          return false;
        },
        allow: function(req, res) {
          return true;
        }
      };
      this.app = express();
      this.app.use(express.bodyParser());
      this.app.use(express.cookieParser());
      this.app.use(express.session({
        secret: "123"
      }));
      this.app.use(beeRequest({
        activationRoute: "bee"
      }));
      this.app.use(beePolicy({
        policies: policies,
        rules: rules
      }));
      this.app.get("/bee/tea", function(req, res) {
        return res.send(200);
      });
      this.app.post("/bee/tea/1", function(req, res) {
        return res.send(200);
      });
      this.app.put("/bee/tea", function(req, res) {
        return res.send(200);
      });
      this.app.get("/bee/tea/1", function(req, res) {
        return res.send(200);
      });
      this.app.listen(9996);
      return done();
    });
    it("it should be allowed by *", function(done) {
      return request("http://localhost:9996").get("/bee/tea").send().end(function(err, res) {
        if (err) {
          throw err;
        }
        res.should.have.status(200);
        return done();
      });
    });
    it("it should be allowed by update rule", function(done) {
      return request("http://localhost:9996").post("/bee/tea/1").send().end(function(err, res) {
        if (err) {
          throw err;
        }
        res.should.have.status(200);
        return done();
      });
    });
    it("it should get blocked by create rule", function(done) {
      return request("http://localhost:9996").put("/bee/tea").send().end(function(err, res) {
        if (err) {
          throw err;
        }
        res.should.have.status(500);
        return done();
      });
    });
    return it("it should also get blocked by find rule", function(done) {
      return request("http://localhost:9996").get("/bee/tea/1").send().end(function(err, res) {
        if (err) {
          throw err;
        }
        res.should.have.status(500);
        return done();
      });
    });
  });

}).call(this);
