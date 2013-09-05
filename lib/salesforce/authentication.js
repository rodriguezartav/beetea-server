/*

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
*/


(function() {
  var Authentication, http, restler,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  http = require('https');

  restler = require('restler');

  Authentication = (function() {
    function Authentication(app, options) {
      this.app = app;
      this.options = options;
      this.getPostOptions = __bind(this.getPostOptions, this);
      this.oauthLeg2 = __bind(this.oauthLeg2, this);
      this.oauthLeg1 = __bind(this.oauthLeg1, this);
      this.passwordLeg1 = __bind(this.passwordLeg1, this);
      this.consumerKey = this.options.consumerKey;
      this.consumerSecret = this.options.consumerSecret;
      this.salesforceHostURI = this.options.salesforceHostURI;
      this.apiServerURI = this.options.apiServerURI;
      if (this.options.loginRoute) {
        this.app.get(this.options.loginRoute, this.oauthLeg1);
      }
      if (this.options.callbackRoute) {
        this.app.get(this.options.callbackRoute, this.oauthLeg2);
      }
      if (this.options.passwordRoute) {
        this.app.get(this.options.passwordRoute, this.passwordLeg1);
      }
    }

    Authentication.finalAuthLeg = function(req, res, url, options, onLoginSuccess, onLoginError) {
      var post,
        _this = this;
      post = restler.post(url, options);
      post.on('complete', function(data, authResponse) {
        if (authResponse.statusCode === 200) {
          return onLoginSuccess(req, res, data, authResponse);
        } else {
          return onLoginError(res, res, data);
        }
      });
      post.on('error', function(error) {
        return onLoginError(req, res, error);
      });
      return post;
    };

    Authentication.prototype.passwordLeg1 = function(req, res) {
      var options, postData, postHeaders, url;
      postData = "grant_type=password&client_id=" + this.options.consumerKey + "&client_secret=" + this.options.consumerSecret + "&username=" + req.body.username + "&password=" + req.body.password;
      postHeaders = this.getPostOptions(postData.length);
      url = "" + this.salesforceHostURI + "/services/oauth2/token";
      options = {
        data: postData,
        headers: postHeaders
      };
      if (res) {
        Authentication.finalAuthLeg(req, res, url, options, this.options.onLoginSuccess, this.options.onLoginError);
      }
      if (!res) {
        return {
          url: url,
          options: options
        };
      }
    };

    Authentication.prototype.oauthLeg1 = function(req, res) {
      var redirectURI, url;
      redirectURI = this.apiServerURI + this.options.callbackRoute;
      url = "" + this.salesforceHostURI + "/services/oauth2/authorize?response_type=code&client_id=" + this.consumerKey + "&redirect_uri=" + redirectURI + "&scope=api%20refresh_token";
      if (res) {
        res.redirect(url);
      }
      return url;
    };

    Authentication.prototype.oauthLeg2 = function(req, res) {
      var data, options, url;
      data = {
        code: req.query.code,
        grant_type: 'authorization_code',
        client_id: this.consumerKey,
        redirect_uri: this.apiServerURI + this.options.callbackRoute,
        client_secret: this.consumerSecret
      };
      url = "" + this.salesforceHostURI + "/services/oauth2/token";
      options = {
        data: data,
        headers: {
          "Code": req.query.code
        }
      };
      if (res) {
        Authentication.finalAuthLeg(req, res, url, options, this.options.onLoginSuccess, this.options.onLoginError);
      }
      if (!res) {
        return {
          url: url,
          options: options
        };
      }
    };

    Authentication.prototype.getPostOptions = function(dataLength) {
      var options;
      options = {
        'Content-Length': dataLength,
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept': 'application/jsonrequest',
        'Cache-Control': 'no-cache,no-store,must-revalidate'
      };
      return options;
    };

    Authentication.controller = function(app, options) {
      return new Authentication(app, options);
    };

    return Authentication;

  })();

  module.exports = Authentication;

}).call(this);
