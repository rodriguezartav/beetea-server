###

  Provides the Authentication Strategies for Salesforce.com

  options:
    consumerKey            : Salesforce Consumer Key
    consumerSecret         : Salesforce Consumer Secret
    salesforceHostURI      : Salesforce Host URI
    apiServerURI           : Api Server URI
    loginRoute             : Route where Login Process is Started 
    callbackRoute          : Route where Salesforce Callback is Returned
    onLoginSuccess         : Function that's called when Salesforce Login Succeds
    onLoginError           : Function that's called when Salesforce Login has an error

###
http = require('https')
restler = require('restler');

class Authentication

  constructor: (@app , @options) ->
    @consumerKey= @options.consumerKey
    @consumerSecret= @options.consumerSecret
    @salesforceHostURI = @options.salesforceHostURI
    @apiServerURI= @options.apiServerURI

    #Setting up routes for Login,Callback and Password based login
    @app.get @options.loginRoute , @oauthLeg1 if @options.loginRoute
    @app.get @options.callbackRoute , @oauthLeg2 if @options.callbackRoute
    @app.get @options.passwordRoute , @passwordLeg1 if @options.passwordRoute

  # The final and shared action that's taken after login success either OAuth or Password based
  @finalAuthLeg: (req,res,url,options,onLoginSuccess, onLoginError) ->
    post = restler.post url, options
    post.on 'complete' , (data,authResponse) => 
      if authResponse.statusCode == 200
        onLoginSuccess(req, res, data, authResponse) 
      else
        onLoginError(res,res,data)

    post.on 'error', (error) => onLoginError(req,res,error)
    post

  #The first and only Leg of the Password dance
  passwordLeg1: (req, res ) =>
    postData= "grant_type=password&client_id=#{@options.consumerKey}&client_secret=#{@options.consumerSecret}&username=#{req.body.username}&password=#{req.body.password}"
    postHeaders = @getPostOptions(postData.length)
    
    url= "#{@salesforceHostURI}/services/oauth2/token"
    options = { data: postData , headers: postHeaders} 

    Authentication.finalAuthLeg(req,res,url,options, @options.onLoginSuccess, @options.onLoginError) if res #for Testing
    return url: url, options: options  if !res #for testing
    
  #The first Leg of the OAUTH dance, sending ConsumerKey and Secret
  oauthLeg1: (req,res) =>
    redirectURI = @apiServerURI + @options.callbackRoute
    url = "#{@salesforceHostURI}/services/oauth2/authorize?response_type=code&client_id=#{@consumerKey}&redirect_uri=#{redirectURI}&scope=api%20refresh_token"
    res.redirect(url) if res #for testing
    url

  #The second Leg, known as OAuth Callback which sends an authorization code used to get the auth token
  oauthLeg2: (req, res) =>
    data=
      code: req.query.code
      grant_type: 'authorization_code'
      client_id: @consumerKey
      redirect_uri: @apiServerURI + @options.callbackRoute
      client_secret: @consumerSecret

    url=  "#{@salesforceHostURI}/services/oauth2/token"
    options = { data: data , headers: {"Code" : req.query.code} }

    Authentication.finalAuthLeg(req,res,url,options, @options.onLoginSuccess, @options.onLoginError) if res #for testing
    return url: url, options: options if !res #for testing

  # Helper function to set Request Headers
  getPostOptions: (dataLength) =>
    options=
      'Content-Length'  : dataLength
      'Content-Type'    : 'application/x-www-form-urlencoded'
      'Accept'          : 'application/jsonrequest'
      'Cache-Control'   : 'no-cache,no-store,must-revalidate'
    options
  
  #The Controller is structures this way in order to match other Express/Connect "Plugins"
  @controller: (app,options) ->
    return new Authentication(app,options)

module.exports = Authentication
