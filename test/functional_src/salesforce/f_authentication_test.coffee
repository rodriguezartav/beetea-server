should = require("should")
express = require("express")

should = require("should")
request = require('supertest')
superagent = require('superagent');
express = require("express")
Session = require("../../lib/session")
assert = require('assert');
Browser = require('zombie');
process.env.NODE_ENV = 'test';
_ = require("lodash")

salesforceAuth = require("../../lib/salesforce/authentication")

_ = require("lodash")
# define server base URL

describe "Salesforce Authentication Test", ->
  after ->
    @server.close()

  before (done) ->

    options = 
      consumerKey: "3MVG9A2kN3Bn17htk3vTjstUS64YQ65jHnCAafk3dWGiRAzlh0FJYCzLjAGPhE63NoI2bm.GZaRbmiUeWpOnC"
      consumerSecret: "1438897970312424324"
      salesforceHostURI: "https://login.salesforce.com"
      apiServerURI: "http://localhost:9995"
      loginRoute: "/salesforce/login"
      callbackRoute: "/salesforce/callback"
      passwordRoute: "/salesforce/password"
      onLoginError: (req,res,error)  ->
        res.status 500
        res.send error

    @app = express()
    @app.use express.bodyParser()
    @authentication = salesforceAuth.controller @app , options
    @app.use @authentication
    @server = @app.listen 9995

    done()

  it "should login with password mock" , (done) ->
    this.timeout(10000);

    @authentication.options.onLoginSuccess = (req,res,data)  =>
      res.send data
    
    original = salesforceAuth.finalAuthLeg
    salesforceAuth.finalAuthLeg= (req,res,url,options,onLoginSuccess, onLoginError) ->
      
      loginResponse = '{"id":"https://login.salesforce.com/id/00Dx0000000BV7z/005x00000012Q9P",
      "issued_at":"1278448832702","instance_url":"https://na1.salesforce.com",
      "signature":"0CmxinZir53Yex7nE0TD+zMpvIWYGb/bdJh6XfOH6EQ=","access_token":
      "00Dx0000000BV7z!AR8AQAxo9UfVkh8AlV0Gomt9Czx9LjHnSSpwBMmbRcgKFmxOtvxjTrKW1
      9ye6PE3Ds1eQz3z8jr3W7_VbWmEu4Q8TVGSTHxs"}'
      
      onLoginSuccess(req,res,loginResponse)

    request("http://localhost:9995").get("/salesforce/password").send({username: "devtest@com" , password: "monomono1dHHIfSVERIh4VP3KZuGgbFgs"}).end (err, res) =>
      res.status.should.equal 200
      salesforceAuth.finalAuthLeg = original
      done()
