
should = require("should")
request = require('supertest')
superagent = require('superagent');
express = require("express")
Session = require("../../lib/session")
assert = require('assert');
Browser = require('zombie');
process.env.NODE_ENV = 'test';
_ = require("lodash")
Q = require("q")
Proxy = require("../../lib/salesforce/proxy")
salesforceAuth = require("../../lib/salesforce/authentication")

_ = require("lodash")
# define server base URL

describe "Salesforce Proxy Request Test", ->
  
  after ->
    @appServer.close()
  
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
      req.session.authentication= 
        "id": "https://login.salesforce.com/id/00Dx0000000BV7z/005x00000012Q9P"
        "issued_at":"1278448832702"
        "instance_url":"https://na1.salesforce.com"
        "signature":"0CmxinZir53Yex7nE0TD+zMpvIWYGb/bdJh6XfOH6EQ="
        "access_token":"00Dx0000000BV7z!AR8AQAxo9UfVkh8AlV0Gomt9Czx9LjHnSSpwBMmbRcgKFmxOtvxjTrKW19ye6PE3Ds1eQz3z8jr3W7_VbWmEu4Q8TVGSTHxs"
      next()
    @authentication = salesforceAuth.controller @app , options
    @proxy = Proxy.controller @app 
    @app.use @authentication
    @app.use @proxy
    @app.get "/" , (req,res) ->
      res.send req.session.authentication
      
    @appServer = @app.listen 9995

    done()
    


  it "should retrieve a record using REST Standard" , (done) ->
    original = Proxy.sendRequest
    
    Proxy.sendRequest= (request) ->
      defered = Q.defer()

      headers=
        Date: "Thu, 21 Oct 2010 22:16:22 GMT"
        "Content-Length": 71
        Location: "/services/data/v24.0/sobjects/Account/001T000000NU96UIAT"
        "Content-Type": "application/json; charset=UTF-8 Server:"
      
      body=
        "id" : "001T000000NU96UIAT"
        "name" : "test1"

      process.nextTick ->
        defered.resolve { data: body  , serviceResponse: {statusCode: 200, headers: headers} }
      return defered.promise

    request("http://localhost:9995").get("/salesforce/Account/001T000000NU96UIAT").send().end (err, res) =>
      res.body.name.should.be.equal "test1"
      res.body.id.should.be.equal "001T000000NU96UIAT"
      Proxy.sendRequest = original
      done()    


  it "should create a record using REST Standard" , (done) ->
    original = Proxy.sendRequest

    Proxy.sendRequest= (request) ->
      defered = Q.defer()

      headers=
        Date: "Thu, 21 Oct 2010 22:16:22 GMT"
        "Content-Length": 71
        Location: "/services/data/v24.0/sobjects/Account/001T000000NU96UIAT"
        "Content-Type": "application/json; charset=UTF-8 Server:"

      body=
        id : "001T000000NU96UIAT"
        name: "test2"

      process.nextTick ->
        defered.resolve { data: body , serviceResponse: {statusCode: 200, headers: headers} }
      return defered.promise

    request("http://localhost:9995").post("/salesforce/Account").send({name: "test2"}).end (err, res) =>
      res.body.name.should.be.equal "test2"
      res.body.id.should.be.equal "001T000000NU96UIAT"
      Proxy.sendRequest = original
      done()


  it "should update record using REST Standard" , (done) ->
    original = Proxy.sendRequest

    Proxy.sendRequest= (request) ->
      defered = Q.defer()

      headers=
        Date: "Thu, 21 Oct 2010 22:16:22 GMT"
        "Content-Length": 71
        Location: "/services/data/v24.0/sobjects/Account/001T000000NU96UIAT"
        "Content-Type": "application/json; charset=UTF-8 Server:"

      body=
        "id" : "001T000000NU96UIAT"
        "name" : "test3"

      process.nextTick ->
        defered.resolve { data: body , serviceResponse: {statusCode: 200, headers: headers} }
      return defered.promise

    request("http://localhost:9995").put("/salesforce/Account").send({id: "001T000000NU96UIAT", name: "test3"}).end (err, res) =>
      res.body.name.should.be.equal "test3"
      res.body.id.should.be.equal "001T000000NU96UIAT"
      Proxy.sendRequest = original
      done()

  it "should delete a record using REST Standard" , (done) ->
    original = Proxy.sendRequest

    Proxy.sendRequest= (request) ->
      defered = Q.defer()

      headers=
        Date: "Thu, 21 Oct 2010 22:16:22 GMT"
        "Content-Length": 71
        Location: "/services/data/v24.0/sobjects/Account/001T000000NU96UIAT"
        "Content-Type": "application/json; charset=UTF-8 Server:"

      body= 
        id: "001T000000NU96UIAT"

      process.nextTick ->
        defered.resolve { data: body , serviceResponse: {statusCode: 200, headers: headers} }
      return defered.promise

    request("http://localhost:9995").del("/salesforce/Account/001T000000NU96UIAT").send().end (err, res) =>
      res.body.id.should.be.equal "001T000000NU96UIAT"
      Proxy.sendRequest = original
      done()
