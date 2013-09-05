/*
  Provides the Authentication Strategies for Salesforce.com
  options:
*/


(function() {
  var Proxy, Q, querystring, restler, _,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  restler = require('restler');

  querystring = require("querystring");

  _ = require("lodash");

  Q = require("q");

  Proxy = (function() {
    Proxy.apiVersion = "/v24.0";

    Proxy.servicesUrl = "/services/data";

    Proxy.servicePrefix = "/salesforce";

    function Proxy(app, options) {
      var _this = this;
      this.app = app;
      this.options = options != null ? options : {};
      this.proxyComplete = __bind(this.proxyComplete, this);
      if (this.options.apiVersion) {
        Proxy.apiVersion = this.options.apiVersion;
      }
      if (this.options.servicesUrl) {
        Proxy.servicesUrl = this.options.servicesUrl;
      }
      if (this.options.servicePrefix) {
        Proxy.servicePrefix = this.options.servicePrefix;
      }
      this.proxyAutorespond = true;
      this.onProxySuccess = this.options.onProxySuccess;
      this.onProxyError = this.options.onProxyError;
      if (!_.isUndefined(this.options.proxyAutorespond)) {
        this.proxyAutorespond = this.options.proxyAutorespond;
      }
      this.app.all(Proxy.servicePrefix + "/restapi/:service/:objectType?/:objectId?", function(req, res) {
        var requestOptions, requestPromise, serviceData;
        serviceData = Proxy.serviceFactory(req.params.service, req.params.objectType, req.params.objectId, req.body);
        requestOptions = Proxy.buildRequest(serviceData, req.session.authentication);
        requestPromise = Proxy.sendRequest(requestOptions);
        return _this.proxyComplete(req, res, requestPromise);
      });
      this.app.all(Proxy.servicePrefix + "/:objectType?/:objectId?", function(req, res) {
        var requestOptions, requestPromise, serviceData;
        serviceData = Proxy.serviceDataFromReq(req);
        requestOptions = Proxy.buildRequest(serviceData, req.session.authentication);
        requestPromise = Proxy.sendRequest(requestOptions);
        return _this.proxyComplete(req, res, requestPromise);
      });
    }

    Proxy.prototype.proxyComplete = function(originalRequest, originalResponse, requestPromise) {
      var _this = this;
      requestPromise.then(function(promiseResponse) {
        if (originalRequest.params.mayRequireRequery) {
          if (_.isUndefined(originalResponse.queryRecords)) {
            originalResponse.queryRecords = [];
          }
          originalResponse.queryRecords = originalResponse.queryRecords.concat(promiseResponse.data.records);
        }
        if (_this.proxyAutorespond) {
          Proxy.proxyAutoresponse(originalRequest, originalResponse, promiseResponse.data, promiseResponse.serviceResponse);
        }
        if (_this.proxyAutorespond) {
          originalResponse = null;
        }
        return typeof _this.onProxySuccess === "function" ? _this.onProxySuccess(originalRequest, originalResponse, promiseResponse.data, promiseResponse.serviceResponse) : void 0;
      });
      return requestPromise.fail(function(failResponse) {
        if (_this.proxyAutorespond) {
          Proxy.proxyAutoresponse(originalRequest, originalResponse, failResponse.data, failResponse.serviceResponse);
        }
        if (_this.proxyAutorespond) {
          originalResponse = null;
        }
        return typeof _this.onProxyError === "function" ? _this.onProxyError(originalRequest, originalResponse, failResponse.data, failResponse.serviceResponse) : void 0;
      });
    };

    Proxy.buildRequest = function(requestValues, authentication) {
      var options;
      if (!_.isObject(requestValues)) {
        requestValues = {
          path: requestValues,
          query: "",
          method: "GET",
          data: {}
        };
      }
      requestValues.path += requestValues.query;
      options = {
        method: requestValues.method,
        data: JSON.stringify(requestValues.data),
        headers: {
          Accept: "application/json",
          "Accept-Encoding": "gzip",
          Authorization: "OAuth " + authentication.access_token,
          "Content-Type": "application/json"
        }
      };
      return {
        url: authentication.instance_url + requestValues.path,
        options: options
      };
    };

    Proxy.sendRequest = function(request) {
      var defered, salesforceRequest,
        _this = this;
      defered = Q.defer();
      salesforceRequest = restler.request(request.url, request.options);
      salesforceRequest.on("success", function(data, response) {
        return defered.resolve({
          data: JSON.parse(data),
          serviceResponse: response
        });
      });
      salesforceRequest.on("fail", function(error, response) {
        return defered.reject({
          data: error,
          serviceResponse: response
        });
      });
      salesforceRequest.on("error", function(error, response) {
        return defered.reject({
          data: error,
          serviceResponse: response
        });
      });
      return defered.promise;
    };

    Proxy.proxyAutoresponse = function(originalRequest, originalResponse, data, response) {
      originalResponse.status(response.statusCode);
      if (response.statusCode >= 200 && response.statusCode < 400) {
        return originalResponse.send(this.responseFactory(originalRequest, originalResponse, data, response));
      } else {
        return originalResponse.send(this.errorResponseFactory(originalRequest, originalResponse, data, response));
      }
    };

    Proxy.serviceDataFromReq = function(originalRequest) {
      var method, serviceData;
      method = originalRequest.route.method.toLowerCase();
      serviceData = {};
      if (method === "get" && originalRequest.query.query) {
        originalRequest.params.service = "query";
        originalRequest.params.mayRequireRequery = true;
        serviceData = Proxy.serviceFactory("query", null, null, originalRequest.query.query);
      } else if (method === "get" && originalRequest.query.search) {
        originalRequest.params.service = "search";
        serviceData = Proxy.serviceFactory("search", null, null, originalRequest.query.search);
      } else if (method === "get") {
        originalRequest.params.service = "retrieve";
        serviceData = Proxy.serviceFactory("retrieve", originalRequest.params.objectType, originalRequest.params.objectId, originalRequest.query);
      } else if (method === "post") {
        originalRequest.params.service = "create";
        serviceData = Proxy.serviceFactory("create", originalRequest.params.objectType, originalRequest.params.objectId, originalRequest.body);
      } else if (method === "put") {
        originalRequest.params.service = "update";
        serviceData = Proxy.serviceFactory("update", originalRequest.params.objectType, originalRequest.params.objectId, originalRequest.body);
      } else if (method === "delete") {
        originalRequest.params.service = "del";
        serviceData = Proxy.serviceFactory("del", originalRequest.params.objectType, originalRequest.params.objectId);
      }
      return serviceData;
    };

    Proxy.serviceFactory = function(service, objectType, objectId, data) {
      var services;
      if (data == null) {
        data = {};
      }
      services = {
        versions: "/",
        resources: this.servicesUrl + this.apiVersion + "/",
        describeGlobal: this.servicesUrl + this.apiVersion + "/sobjects/",
        identity: "" + this.servicesUrl + "/" + objectId + "/",
        metadata: this.servicesUrl + this.apiVersion + "/sobjects/" + objectType + "/",
        describe: this.servicesUrl + this.apiVersion + "/sobjects/" + objectType + "/describe/",
        retrieve: this.servicesUrl + this.apiVersion + "/sobjects/" + objectType + "/" + objectId + (data.fields ? "/?fields=" + JSON.stringify(data.fields) : "/"),
        create: {
          path: this.servicesUrl + this.apiVersion + "/sobjects/" + objectType + "/",
          method: "POST",
          data: JSON.stringify(data)
        },
        upsert: {
          path: this.servicesUrl + this.apiVersion + "/sobjects/" + objectType + "/" + data.externalIdField + "/" + objectId + "/",
          method: "PATCH",
          data: data.fields ? JSON.stringify(data.fields) : void 0
        },
        update: {
          path: this.servicesUrl + this.apiVersion + "/sobjects/" + objectType + "/" + objectId + "/",
          method: "PATCH",
          data: JSON.stringify(data)
        },
        del: {
          path: this.servicesUrl + this.apiVersion + "/sobjects/" + objectType + "/" + objectId + "/",
          method: "DELETE"
        },
        search: this.servicesUrl + this.apiVersion + "/search/?q=" + escape(data),
        query: this.servicesUrl + this.apiVersion + "/query/?q=" + escape(data),
        queryMore: data.nextRecordsUrl,
        apex: {
          path: "/services/apexrest/" + objectType + "/",
          query: objectId === "GET" ? "?" + (querystring.stringify(data)) : "",
          method: objectId,
          data: objectId === "GET" ? null : JSON.stringify(data)
        },
        chatter: this.servicesUrl + this.apiVersion + "/chatter/feeds/" + objectType + "/" + objectId + "/feed-items/"
      };
      return services[service];
    };

    Proxy.errorResponseFactory = function(originalRequest, originalResponse, responseData, serviceResponse) {
      return responseData;
    };

    Proxy.responseFactory = function(originalRequest, originalResponse, responseData, serviceResponse) {
      var service;
      service = originalRequest.params.service;
      if (service === "versions" || service === "resources" || service === "describeGlobal" || service === "identity" || service === "describe") {
        return responseData;
      } else if (service === "retrieve" || service === "apex" || service === "chatter" || service === "search") {
        return responseData;
      } else if (service === "create") {
        originalRequest.body.id = responseData.id;
        originalRequest.body.objectType = originalRequest.params.objectType;
        return originalRequest.body;
      } else if (service === "update") {
        originalRequest.body.objectType = originalRequest.params.objectType;
        return originalRequest.body;
      } else if (service === "del") {
        return {
          id: originalRequest.params.objectId,
          objectType: originalRequest.params.objectType
        };
      } else if (service === "upsert" && responseData) {
        originalRequest.body.id = responseData.id;
        originalRequest.body.objectType = originalRequest.params.objectType;
        return originalRequest.body;
      } else if (service === "upsert" && !responseData) {
        originalRequest.body.objectType = originalRequest.params.objectType;
        return originalRequest.body;
      } else if (service === "query") {
        console.log("************************");
        return originalResponse.queryRecords;
      }
    };

    Proxy.controller = function(app, options) {
      return new Proxy(app, options);
    };

    return Proxy;

  })();

  module.exports = Proxy;

}).call(this);
