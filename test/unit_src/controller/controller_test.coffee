should = require("should")
express = require("express")
BeeteaController = require("../../lib/beetea").Controller
_ = require("lodash")
# define server base URL

class TestController extends BeeteaController
  @route = "testController"

beforeEach ->
  @app = express()


describe "AppBot Controller", ->
  it 'should extend an object', ->
    controller = new TestController(@app)
    @app.routes["get"][0].path.should.equal "/bee/testController/*"
    @app.routes["get"][1].path.should.equal "/bee/testController"

  it 'should contain a POST ROUTE', ->
    controller = new TestController(@app)
    @app.routes["post"][0].path.should.equal "/bee/testController/*"
    

  it 'should contain a PUT ROUTE', ->
    controller = new TestController(@app)
    @app.routes["put"][0].path.should.equal "/bee/testController"

  it 'should contain a DEL ROUTE', ->
    controller = new TestController(@app)
    @app.routes["delete"][0].path.should.equal "/bee/testController/*"
