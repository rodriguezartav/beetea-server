(function() {
  var Browser, Session, assert, express, request, should, superagent;

  should = require("should");

  request = require('supertest');

  superagent = require('superagent');

  express = require("express");

  Session = require("../../lib/session");

  assert = require('assert');

  Browser = require('zombie');

  process.env.NODE_ENV = 'test';

  before(function() {
    this.app = express();
    this.app.listen(9999);
    Session(this.app, {
      name: "test-session-999",
      secret: "secret",
      secure: false,
      httpOnly: false
    });
    this.app.get("/", function(req, res) {
      req["test-session-999"].check = "ok";
      return res.send(200);
    });
    this.browser = new Browser({
      site: 'http://localhost:9999'
    });
    return this.browser.on("error", function(err) {
      return console.log(err);
    });
  });

  describe("Use Session", function() {
    return it('should use session cookies', function(done) {
      var _this = this;
      return this.browser.visit('/', function() {
        return _this.browser.visit('/', function() {
          _this.browser.cookies.toString().indexOf("test-session-999").should.be.above(-1);
          return done();
        });
      });
    });
  });

}).call(this);
