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
# define server base URL

class TestController extends BeeteaController
  @route = "testController"

  constructor: (@app) ->
    super @app

describe "Simple Controller Test", ->
  before (done) ->
    DatabaseConnection.connect database: "test"
    @app = express()
    @app.use express.bodyParser()
    testController = new TestController(@app)
    @app.listen 9998

    staticCommand = "create Table IF NOT EXISTS TestController (id int AUTO_INCREMENT, name NVARCHAR(55) , 
      PRIMARY KEY (id), lastname NVARCHAR(44) )"

    staticPromise= BeeteaOperation.staticOperation DatabaseConnection, [staticCommand]
    staticPromise.then (results) ->
      done()

  it "insert should return 200", (done) ->
    request("http://localhost:9998").put("/bee/testController").send({name: "test"}).end (err, res) ->
      throw err if err
      res.should.have.status 200
      done()
 
  it "update should return 200", (done) ->
    request("http://localhost:9998").post("/bee/testController/1").send({id: 1 , name: "test2"}).end (err, res) ->
      throw err if err
      res.should.have.status 200
      done()

  it "get one should return 200", (done) ->
    request("http://localhost:9998").get("/bee/testController/1").send().end (err, res) ->
      throw err if err
      res.should.have.status 200
      done()

  it "delete should return 200", (done) ->
    request("http://localhost:9998").del("/bee/testController/1").send({name: "test"}).end (err, res) ->
      throw err if err
      res.should.have.status 200
      done()

  it "get all should return 200", (done) ->
    request("http://localhost:9998").get("/bee/testController").send().end (err, res) ->
      throw err if err
      res.should.have.status 200
      done()

  it "get one should return 404", (done) ->
    request("http://localhost:9998").get("/bee/testController/1").send().end (err, res) ->
      throw err if err
      res.should.have.status 404
      done()

  after (done) ->
    staticPromise= BeeteaOperation.staticOperation DatabaseConnection, ["drop Table TestController"]
    staticPromise.then (results) ->
      done()
