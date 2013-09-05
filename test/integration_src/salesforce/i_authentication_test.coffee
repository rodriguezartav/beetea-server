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

  ###
  it "should login with password" , (done) ->
    this.timeout(10000);

    @authentication.options.onLoginSuccess = (req,res,data)  =>
      res.send JSON.stringify data

    request("http://localhost:9995").get("/salesforce/password").send({username: "devtest@beetea.com" , password: "monomono1dHHIfSVERIh4VP3KZuGgbFgs"}).end (err, res) =>
      res.status.should.equal 200
      done()

  it "should not login with password" , (done) ->
    this.timeout(10000);

    request("http://localhost:9995").get("/salesforce/password").send({username: "devtest@beetea" , password: "monomono1dHHIfSVERIh4VP3KZuGgbFgs"}).end (err, res) =>
      res.status.should.equal 500
      done()

  
  
  it "it should show the login url", (done) ->
    this.timeout(10000);
    request("http://localhost:9995").get("/salesforce/login").send().end (err, res) =>
      throw err if err
      console.log "GRAB THIS URL AND POST IT IN YOUR BROWSER"
      console.log res.headers.location
      console.log "USE USERNAME AND PASSWORD PROVIDED BY TEST"
      done()
  ###
  ###
  UNCOMMENT TO TEST LOGIN WITH LAST URL
  
  it "it should set token to complete login", (done) ->
    this.timeout(10000);
    
    @authentication.options.onLoginSuccess = (req,res,data)  =>
      res.send JSON.stringify data

    #SET THE URL RETURNED BY LOGIN HERE AND RUN AGAIN
    url = "http://localhost:9995/salesforce/callback?code=aPrxMZkm7lCkgfTiHhsjGwMUh_T56MhFx8UkGE_a.VV7Dkz1WTu8SN5o7DJBUYwqPGU6BXXFZA%3D%3D"
    request("").get(url).send().end (err, authResponse) =>
      throw err if err
      authResponse.text.indexOf("access_token").should.be.above "-1" 
      done()
  
  it "should login with password" , (done) ->
    this.timeout(10000);

    request("http://localhost:9995").get("/salesforce/password").send({username: "devtest@beetea.com" , password: "monomono1dHHIfSVERIh4VP3KZuGgbFgs"}).end (err, res) =>
      res.status.should.equal 200
      done()

    @authentication.options.onLoginSuccess = (req,res,data)  =>
      res.send JSON.stringify data
  ###


