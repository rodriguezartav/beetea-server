(function() {
  var Browser, Proxy, Session, assert, express, request, salesforceAuth, should, superagent, _;

  should = require("should");

  request = require('supertest');

  superagent = require('superagent');

  express = require("express");

  Session = require("../../lib/session");

  assert = require('assert');

  Browser = require('zombie');

  process.env.NODE_ENV = 'test';

  _ = require("lodash");

  Proxy = require("../../lib/salesforce/proxy");

  salesforceAuth = require("../../lib/salesforce/authentication");

  _ = require("lodash");

  describe("Salesforce Proxy Test", function() {
    after(function() {
      return this.server.close();
    });
    before(function(done) {
      var options;
      options = {
        consumerKey: "3MVG9A2kN3Bn17htk3vTjstUS64YQ65jHnCAafk3dWGiRAzlh0FJYCzLjAGPhE63NoI2bm.GZaRbmiUeWpOnC",
        consumerSecret: "1438897970312424324",
        salesforceHostURI: "https://login.salesforce.com",
        apiServerURI: "http://localhost:9995",
        passwordRoute: "/salesforce/password",
        onLoginError: function(req, res, error) {
          res.status(500);
          return res.send(error);
        }
      };
      this.app = express();
      this.app.use(express.bodyParser());
      this.app.use(function(req, res, next) {
        req.session = {};
        if (req.app.authMock) {
          req.session.authentication = req.app.authMock;
        }
        return next();
      });
      this.authentication = salesforceAuth.controller(this.app, options);
      this.proxy = Proxy.controller(this.app);
      this.app.use(this.authentication);
      this.app.use(this.proxy);
      this.app.get("/", function(req, res) {
        return res.send(req.session.authentication);
      });
      this.server = this.app.listen(9995);
      return done();
    });
    it("should login with password", function(done) {
      var _this = this;
      this.timeout(10000);
      request("http://localhost:9995").get("/salesforce/password").send({
        username: "devtest@beetea.com",
        password: "monomono1dHHIfSVERIh4VP3KZuGgbFgs"
      }).end(function(err, res) {
        res.status.should.equal(200);
        return done();
      });
      return this.authentication.options.onLoginSuccess = function(req, res, data) {
        _this.app.authMock = data;
        return res.send(JSON.stringify(data));
      };
    });
    it("req should have authentication in session", function(done) {
      var _this = this;
      return request("http://localhost:9995").get("/").send().end(function(err, res) {
        _this.app.authMock.should.not.equal(null);
        return done();
      });
    });
    return it("should retrieve all users", function(done) {
      var _this = this;
      return request("http://localhost:9995").get("/salesforce/User?query=select%20id,name%20from%20Account").send().end(function(err, res) {
        console.log(res.body);
        return done();
      });
    });
  });

}).call(this);
