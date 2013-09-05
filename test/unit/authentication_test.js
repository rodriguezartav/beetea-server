(function() {
  var Authentication, express, request, should;

  should = require("should");

  express = require("express");

  Authentication = require("../../lib/salesforce/authentication");

  request = require('supertest');

  describe("Salesforce Authentication", function() {
    before(function() {
      var options;
      options = {
        consumerKey: "3MVG9A2kN3Bn17htk3vTjstUS64YQ65jHnCAafk3dWGiRAzlh0FJYCzLjAGPhE63NoI2bm.GZaRbmiUeWpOnC",
        consumerSecret: "1438897970312424324",
        salesforceHostURI: "https://login.salesforce.com",
        apiServerURI: "http://localhost:9995",
        loginRoute: "/salesforce/login",
        callbackRoute: "/salesforce/callback",
        onLoginSuccess: function() {},
        onLoginError: function() {}
      };
      this.app = express();
      this.app.use(express.bodyParser());
      this.authentication = Authentication.controller(this.app, options);
      this.app.use(this.authentication);
      this.app.get("/", function(req, res) {
        res.status(200);
        return res.send("ok");
      });
      return this.app.listen(8884);
    });
    it('instantiate and define routes', function(done) {
      this.app.routes.should.not.equal(null);
      return done();
    });
    it('Password Leg1', function(done) {
      var req, reqMock;
      reqMock = {
        body: {
          username: "test",
          password: "anypass"
        }
      };
      req = this.authentication.passwordLeg1(reqMock);
      return done();
    });
    it('oauthLeg1', function(done) {
      var reqUrl;
      reqUrl = this.authentication.oauthLeg1();
      return done();
    });
    it('oauthLeg2', function(done) {
      var leg2Post, reqMock, resMock;
      reqMock = {
        query: {
          code: "123"
        }
      };
      resMock = {
        statusCode: 200
      };
      leg2Post = this.authentication.oauthLeg2(reqMock);
      return done();
    });
    return it('getPostOptions', function(done) {
      var options;
      options = this.authentication.getPostOptions(20);
      return done();
    });
  });

}).call(this);
