(function() {
  var Browser, Session, assert, express, request, salesforceAuth, should, superagent, _;

  should = require("should");

  express = require("express");

  should = require("should");

  request = require('supertest');

  superagent = require('superagent');

  express = require("express");

  Session = require("../../lib/session");

  assert = require('assert');

  Browser = require('zombie');

  process.env.NODE_ENV = 'test';

  _ = require("lodash");

  salesforceAuth = require("../../lib/salesforce/authentication");

  _ = require("lodash");

  describe("Salesforce Authentication Test", function() {
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
        loginRoute: "/salesforce/login",
        callbackRoute: "/salesforce/callback",
        passwordRoute: "/salesforce/password",
        onLoginError: function(req, res, error) {
          res.status(500);
          return res.send(error);
        }
      };
      this.app = express();
      this.app.use(express.bodyParser());
      this.authentication = salesforceAuth.controller(this.app, options);
      this.app.use(this.authentication);
      this.server = this.app.listen(9995);
      return done();
    });
    return it("should login with password mock", function(done) {
      var original,
        _this = this;
      this.timeout(10000);
      this.authentication.options.onLoginSuccess = function(req, res, data) {
        return res.send(data);
      };
      original = salesforceAuth.finalAuthLeg;
      salesforceAuth.finalAuthLeg = function(req, res, url, options, onLoginSuccess, onLoginError) {
        var loginResponse;
        loginResponse = '{"id":"https://login.salesforce.com/id/00Dx0000000BV7z/005x00000012Q9P",\
      "issued_at":"1278448832702","instance_url":"https://na1.salesforce.com",\
      "signature":"0CmxinZir53Yex7nE0TD+zMpvIWYGb/bdJh6XfOH6EQ=","access_token":\
      "00Dx0000000BV7z!AR8AQAxo9UfVkh8AlV0Gomt9Czx9LjHnSSpwBMmbRcgKFmxOtvxjTrKW1\
      9ye6PE3Ds1eQz3z8jr3W7_VbWmEu4Q8TVGSTHxs"}';
        return onLoginSuccess(req, res, loginResponse);
      };
      return request("http://localhost:9995").get("/salesforce/password").send({
        username: "devtest@com",
        password: "monomono1dHHIfSVERIh4VP3KZuGgbFgs"
      }).end(function(err, res) {
        res.status.should.equal(200);
        salesforceAuth.finalAuthLeg = original;
        return done();
      });
    });
  });

}).call(this);
