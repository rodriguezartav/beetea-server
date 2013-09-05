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

beeRequest = require("../../lib/middleware/beeRequest")


_ = require("lodash")
# define server base URL

class TestController extends BeeteaController
  @route = "testController"

  constructor: (@app) ->
    super @app

describe "Bee Request Test", ->
  before (done) ->
    DatabaseConnection.connect database: "test"

    @app = express()
    @app.use express.bodyParser()
    @app.use beeRequest(activationRoute: "bee")
    testController = new TestController(@app)
    @app.listen 9997

    @app.get "/" , (req,res) ->
      res.send req.beeRequest

    @app.get "/noBee" , (req,res) ->
      res.send req.beeRequest


    @app.get "/bee" , (req,res) ->
      res.send req.beeRequest
    
    @app.get "/bee/tea" , (req,res) ->
      res.send req.beeRequest
    
    @app.get "/bee/tea/1" , (req,res) ->
      res.send req.beeRequest
    
    @app.post "/bee/tea/1" , (req,res) ->
      res.send req.beeRequest
  
    @app.del "/bee/tea/1" , (req,res) ->
      res.send req.beeRequest

    @app.put "/bee/tea" , (req,res) ->
      res.send req.beeRequest
  
    done()

  it "it should work with no path", (done) ->
    request("http://localhost:9997").get("/").send().end (err, res) ->
      throw err if err
      done()


  it "it should work with 1 path", (done) ->
    request("http://localhost:9997").get("/bee").send().end (err, res) ->
      throw err if err
      done()


  it "it should work with 2 path", (done) ->
    request("http://localhost:9997").get("/bee/tea").send().end (err, res) ->
      throw err if err
      res.body.action.should.equal "findAll"
      done()


  it "it should work with 2 path and id", (done) ->
    request("http://localhost:9997").get("/bee/tea/1").send().end (err, res) ->
      throw err if err
      res.body.action.should.equal "find"
      res.body.entityId.should.equal "1"

      done()


  it "it should post with post 2 path and id", (done) ->
    request("http://localhost:9997").post("/bee/tea/1").send().end (err, res) ->
      throw err if err
      res.body.action.should.equal "update"
      res.body.entityId.should.equal "1"

      done()
      
  it "it should put with put 2 path", (done) ->
    request("http://localhost:9997").put("/bee/tea").send().end (err, res) ->
      throw err if err
      res.body.action.should.equal "create"
      done()
      
  it "it should del with 2 path and id", (done) ->
    request("http://localhost:9997").del("/bee/tea/1").send().end (err, res) ->
      throw err if err
      res.body.action.should.equal "destroy"
      res.body.entityId.should.equal "1"
      done()
      
  it "it should no contain beeRequest", (done) ->
    request("http://localhost:9997").del("/noBee").send().end (err, res) ->
      throw err if err
      done()