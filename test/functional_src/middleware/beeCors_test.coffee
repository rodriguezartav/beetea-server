should = require("should")
express = require("express")
BeeteaController = require("../../lib/beetea").Controller
DatabaseConnection = require('../../lib/beetea').DatabaseConnection
BeeteaOperation = require("../../lib/beetea").Operation

should = require("should")
request = require('supertest')
superagent = require('superagent');
express = require("express")
Session = require("../../lib/session")
assert = require('assert');
Browser = require('zombie');
process.env.NODE_ENV = 'test';
_ = require("lodash")

beeCors = require("../../lib/middleware/beeCors")

_ = require("lodash")
# define server base URL

class TestController extends BeeteaController
  @route = "testController"

  constructor: (@app) ->
    super @app

describe "Bee Cors Test", ->
  before (done) ->
    DatabaseConnection.connect database: "test"

    @app = express()
    @app.use express.bodyParser()
    @app.use beeCors origins: [ { origin: "allowedDomain.com" , allowedMethods: 'GET,PUT,POST,DELETE' } , { origin: "OtherallowedDomain.com" , allowedMethods: 'GET,PUT,POST,DELETE' }  ]
    testController = new TestController(@app)
    @app.listen 9994

    @app.get "/" , (req,res) ->
      res.status 200
      res.send "ok"

    done()

  it "it should return 200", (done) ->
    request("http://localhost:9994").get("/").set("origin","http://www.allowedDomain.com").send().end (err, res) ->
      throw err if err
      _.isUndefined( res.headers["access-control-allow-origin"] ).should.equal false
      done()

  it "it should return 200 with other domain", (done) ->
    request("http://localhost:9994").get("/").set("origin","http://www.otherallowedDomain.com").send().end (err, res) ->
      throw err if err
      _.isUndefined( res.headers["access-control-allow-origin"] ).should.equal false
      done()

  it "it should return 200, with no headers", (done) ->
    request("http://localhost:9994").get("/").send().end (err, res) ->
      throw err if err
      _.isUndefined( res.headers["access-control-allow-origin"] ).should.equal true
      done()

  it "it should return 500 because of cors configuration", (done) ->
    request("http://localhost:9994").get("/").set("origin","http://otherDomain.com").send().end (err, res) ->
      throw err if err
      res.status.should.equal 500
      done()

