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
beePolicy = require("../../lib/middleware/beePolicy")

_ = require("lodash")
# define server base URL

describe "Bee Policy Request Test", ->
  before (done) ->
    DatabaseConnection.connect database: "test"

    policies =
      tea:
        "*" : 'allow'
        "update": ["allow"]
        "create": ["allow","block"]
        "find": ["block","allow"]

      "*":
        "*" : "allow"

    rules = 
      block: (req,res) ->
        return false
      allow: (req,res) ->
        return true

    @app = express()
    @app.use express.bodyParser()
    @app.use( express.cookieParser() );
    @app.use express.session(secret: "123")
    
    @app.use beeRequest(activationRoute: "bee")
    @app.use beePolicy(policies: policies , rules: rules )

    @app.get "/bee/tea" , (req,res) ->
      res.send 200
  
    @app.post "/bee/tea/1" , (req,res) ->
      res.send 200
  
    @app.put "/bee/tea" , (req,res) ->
      res.send 200

    @app.get "/bee/tea/1" , (req,res) ->

      res.send 200

    @app.listen 9996

  
    done()

  it "it should be allowed by *", (done) ->
    request("http://localhost:9996").get("/bee/tea").send().end (err, res) ->
      throw err if err
      res.should.have.status 200
      done()

  it "it should be allowed by update rule", (done) ->
    request("http://localhost:9996").post("/bee/tea/1").send().end (err, res) ->
      throw err if err
      res.should.have.status 200
      done()
      
  it "it should get blocked by create rule", (done) ->
    request("http://localhost:9996").put("/bee/tea").send().end (err, res) ->
      throw err if err
      res.should.have.status 500
      done()
      
  it "it should also get blocked by find rule", (done) ->
    request("http://localhost:9996").get("/bee/tea/1").send().end (err, res) ->
      throw err if err
      res.should.have.status 500

      done()
      

 