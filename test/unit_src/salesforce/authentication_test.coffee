should = require("should")

express = require("express")

Authentication = require("../../lib/salesforce/authentication")
request = require('supertest')

# define server base URL

describe "Salesforce Authentication", ->

  before ->
    options = 
      consumerKey: "3MVG9A2kN3Bn17htk3vTjstUS64YQ65jHnCAafk3dWGiRAzlh0FJYCzLjAGPhE63NoI2bm.GZaRbmiUeWpOnC"
      consumerSecret: "1438897970312424324"
      salesforceHostURI: "https://login.salesforce.com"
      apiServerURI: "http://localhost:9995"
      loginRoute: "/salesforce/login"
      callbackRoute: "/salesforce/callback"
      onLoginSuccess: ->
      onLoginError: ->

    @app = express()
    @app.use express.bodyParser()
    @authentication = Authentication.controller @app , options
    @app.use @authentication

    @app.get "/" , (req,res) ->
      res.status 200
      res.send "ok"

    @app.listen 8884


  it 'instantiate and define routes', (done) ->
    @app.routes.should.not.equal null
    done()

  it 'Password Leg1', (done) ->
    reqMock = {body: username: "test",password:"anypass"}
    req = @authentication.passwordLeg1(reqMock)
    done()
    
  it 'oauthLeg1', (done) ->
    reqUrl = @authentication.oauthLeg1()
    #console.log reqUrl
    done()

  it 'oauthLeg2', (done) ->
    reqMock = {query: code: "123"}
    resMock = {statusCode: 200}
    leg2Post = @authentication.oauthLeg2(reqMock)
    #console.log leg2Post
    done()

  it 'getPostOptions', (done) ->
    options = @authentication.getPostOptions(20)
    #console.log options
    done()

