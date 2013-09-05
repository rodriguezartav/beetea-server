
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

describe "Salesforce Proxy Test", ->
 
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
    
  it "should mock a request with onProxySuccess" , (done) ->
    original= Proxy.sendRequest

    Proxy.sendRequest= (request) ->
      defered = Q.defer()
      process.nextTick ->
        defered.resolve { data: { name: "test", success: true } , serviceResponse: {statusCode: 200} }
      return defered.promise

    @proxy.onProxySuccess = ->
      Proxy.sendRequest = original
      done()

    request("http://localhost:9995").get("/salesforce/restapi/resources").send().end (err, res) =>


  it "should mock a request with onProxySuccess and no autorespond" , (done) ->
    original= Proxy.sendRequest

    Proxy.sendRequest= (request) ->
      defered = Q.defer()
      process.nextTick ->
        defered.resolve { data: { name: "test", success: true } , serviceResponse: {statusCode: 200} }
      return defered.promise

    @proxy.proxyAutorespond = false

    @proxy.onProxySuccess = (originalRequest, originalResponse, data, serviceResponse) ->
      data.name.should.equal "test"
      originalResponse.send "ok"

    request("http://localhost:9995").get("/salesforce/restapi/resources").send().end (err, res) =>
      Proxy.sendRequest = original
      @proxy.proxyAutorespond = true
      res.text.should.equal "ok"
      done()
      
  it "should not have a response on onProxySuccess because of autorespond" , (done) ->
    original= Proxy.sendRequest

    Proxy.sendRequest= (request) ->
      defered = Q.defer()
      process.nextTick ->
        defered.resolve { data: { name: "test", success: true } , serviceResponse: {statusCode: 200} }
      return defered.promise

    @proxy.onProxySuccess = (originalRequest, originalResponse, data, serviceResponse) ->
      (null == originalResponse).should.equal "true"

    request("http://localhost:9995").get("/salesforce/restapi/resources").send().end (err, res) =>
      Proxy.sendRequest = original
      done()

