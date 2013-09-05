
should = require("should")
request = require('supertest')
superagent = require('superagent');
express = require("express")
Session = require("../../lib/session")
assert = require('assert');
Browser = require('zombie');
process.env.NODE_ENV = 'test';
_ = require("lodash")

Proxy = require("../../lib/salesforce/proxy")
salesforceAuth = require("../../lib/salesforce/authentication")


_ = require("lodash")
# define server base URL

describe "Salesforce Proxy Test", ->

  after ->
    @server.close()

  before (done) ->

    options = 
      consumerKey: "3MVG9A2kN3Bn17htk3vTjstUS64YQ65jHnCAafk3dWGiRAzlh0FJYCzLjAGPhE63NoI2bm.GZaRbmiUeWpOnC"
      consumerSecret: "1438897970312424324"
      salesforceHostURI: "https://login.salesforce.com"
      apiServerURI: "http://localhost:9995"
      passwordRoute: "/salesforce/password"
      onLoginError: (req,res,error)  ->
        res.status 500
        res.send error

    @app = express()
    @app.use express.bodyParser()
    @app.use (req,res,next) ->
      req.session = {}
      req.session.authentication= req.app.authMock if req.app.authMock
      next()

    @authentication = salesforceAuth.controller @app , options
    @proxy = Proxy.controller @app 

    @app.use @authentication
    @app.use @proxy


    @app.get "/" , (req,res) ->
      res.send req.session.authentication
      
    @server = @app.listen 9995

    done()

  it "should login with password" , (done) ->
    this.timeout(10000);

    request("http://localhost:9995").get("/salesforce/password").send({username: "devtest@beetea.com" , password: "monomono1dHHIfSVERIh4VP3KZuGgbFgs"}).end (err, res) =>
      res.status.should.equal 200
      done()

    @authentication.options.onLoginSuccess = (req,res,data)  =>
      @app.authMock = data
      res.send JSON.stringify data

  it "req should have authentication in session" , (done) ->
    request("http://localhost:9995").get("/").send().end (err, res) =>
      @app.authMock.should.not.equal null
      done()
      
  it "should retrieve all users" , (done) ->
    request("http://localhost:9995").get("/salesforce/User?query=select%20id,name%20from%20Account").send().end (err, res) =>
      console.log res.body
      done()


