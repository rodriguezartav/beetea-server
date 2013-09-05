(function() {
  var Browser, Proxy, Q, Session, assert, express, request, salesforceAuth, should, superagent, _;

  should = require("should");

  request = require('supertest');

  superagent = require('superagent');

  express = require("express");

  Session = require("../../lib/session");

  assert = require('assert');

  Browser = require('zombie');

  process.env.NODE_ENV = 'test';

  _ = require("lodash");

  Q = require("q");

  Proxy = require("../../lib/salesforce/proxy");

  salesforceAuth = require("../../lib/salesforce/authentication");

  _ = require("lodash");

  describe("Salesforce Proxy Test", function() {
    after(function() {
      return this.appServer.close();
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
        req.session.authentication = {
          "id": "https://login.salesforce.com/id/00Dx0000000BV7z/005x00000012Q9P",
          "issued_at": "1278448832702",
          "instance_url": "https://na1.salesforce.com",
          "signature": "0CmxinZir53Yex7nE0TD+zMpvIWYGb/bdJh6XfOH6EQ=",
          "access_token": "00Dx0000000BV7z!AR8AQAxo9UfVkh8AlV0Gomt9Czx9LjHnSSpwBMmbRcgKFmxOtvxjTrKW19ye6PE3Ds1eQz3z8jr3W7_VbWmEu4Q8TVGSTHxs"
        };
        return next();
      });
      this.authentication = salesforceAuth.controller(this.app, options);
      this.proxy = Proxy.controller(this.app);
      this.app.use(this.authentication);
      this.app.use(this.proxy);
      this.app.get("/", function(req, res) {
        return res.send(req.session.authentication);
      });
      this.appServer = this.app.listen(9995);
      return done();
    });
    it("should mock a request with onProxySuccess", function(done) {
      var original,
        _this = this;
      original = Proxy.sendRequest;
      Proxy.sendRequest = function(request) {
        var defered;
        defered = Q.defer();
        process.nextTick(function() {
          return defered.resolve({
            data: {
              name: "test",
              success: true
            },
            serviceResponse: {
              statusCode: 200
            }
          });
        });
        return defered.promise;
      };
      this.proxy.onProxySuccess = function() {
        Proxy.sendRequest = original;
        return done();
      };
      return request("http://localhost:9995").get("/salesforce/restapi/resources").send().end(function(err, res) {});
    });
    it("should mock a request with onProxySuccess and no autorespond", function(done) {
      var original,
        _this = this;
      original = Proxy.sendRequest;
      Proxy.sendRequest = function(request) {
        var defered;
        defered = Q.defer();
        process.nextTick(function() {
          return defered.resolve({
            data: {
              name: "test",
              success: true
            },
            serviceResponse: {
              statusCode: 200
            }
          });
        });
        return defered.promise;
      };
      this.proxy.proxyAutorespond = false;
      this.proxy.onProxySuccess = function(originalRequest, originalResponse, data, serviceResponse) {
        data.name.should.equal("test");
        return originalResponse.send("ok");
      };
      return request("http://localhost:9995").get("/salesforce/restapi/resources").send().end(function(err, res) {
        Proxy.sendRequest = original;
        _this.proxy.proxyAutorespond = true;
        res.text.should.equal("ok");
        return done();
      });
    });
    return it("should not have a response on onProxySuccess because of autorespond", function(done) {
      var original,
        _this = this;
      original = Proxy.sendRequest;
      Proxy.sendRequest = function(request) {
        var defered;
        defered = Q.defer();
        process.nextTick(function() {
          return defered.resolve({
            data: {
              name: "test",
              success: true
            },
            serviceResponse: {
              statusCode: 200
            }
          });
        });
        return defered.promise;
      };
      this.proxy.onProxySuccess = function(originalRequest, originalResponse, data, serviceResponse) {
        return (null === originalResponse).should.equal("true");
      };
      return request("http://localhost:9995").get("/salesforce/restapi/resources").send().end(function(err, res) {
        Proxy.sendRequest = original;
        return done();
      });
    });
  });

}).call(this);
