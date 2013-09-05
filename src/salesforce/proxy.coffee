###
  Provides the Authentication Strategies for Salesforce.com
  options:
###
restler = require('restler');
querystring = require("querystring")
_ = require("lodash")
Q = require("q")

class Proxy

  @apiVersion = "/v24.0"
  @servicesUrl = "/services/data"
  @servicePrefix = "/salesforce"

  constructor: (@app , @options = {}) ->
    Proxy.apiVersion = @options.apiVersion if @options.apiVersion
    Proxy.servicesUrl = @options.servicesUrl if @options.servicesUrl
    Proxy.servicePrefix = @options.servicePrefix if @options.servicePrefix
    @proxyAutorespond = true
    @onProxySuccess = @options.onProxySuccess
    @onProxyError = @options.onProxyError
    @proxyAutorespond = @options.proxyAutorespond if !_.isUndefined(@options.proxyAutorespond)

    # Route for direct salesforce service invocation
    @app.all Proxy.servicePrefix + "/restapi/:service/:objectType?/:objectId?" , (req, res) =>
      serviceData = Proxy.serviceFactory( req.params.service , req.params.objectType, req.params.objectId, req.body)
      requestOptions = Proxy.buildRequest(serviceData, req.session.authentication)
      requestPromise = Proxy.sendRequest(requestOptions)
      @proxyComplete(req, res, requestPromise)

    # Route for rest standard service invocation
    @app.all Proxy.servicePrefix + "/:objectType?/:objectId?" , (req,res) =>
      serviceData= Proxy.serviceDataFromReq(req)
      requestOptions = Proxy.buildRequest(serviceData, req.session.authentication)
      requestPromise = Proxy.sendRequest(requestOptions)
      @proxyComplete(req, res, requestPromise)

  # Logical function to balance and assign proxyAutorespond and onProxySuccess
  proxyComplete: (originalRequest, originalResponse, requestPromise) =>
    requestPromise.then (promiseResponse) =>
      #In order to QueryMore
      if originalRequest.params.mayRequireRequery
        originalResponse.queryRecords = [] if _.isUndefined originalResponse.queryRecords
        originalResponse.queryRecords= originalResponse.queryRecords.concat promiseResponse.data.records
      
      if @proxyAutorespond then Proxy.proxyAutoresponse originalRequest,originalResponse, promiseResponse.data, promiseResponse.serviceResponse
      originalResponse=null if @proxyAutorespond #in order to avoid response allready send exception
      @onProxySuccess? originalRequest, originalResponse, promiseResponse.data, promiseResponse.serviceResponse

    requestPromise.fail (failResponse) =>
      if @proxyAutorespond then Proxy.proxyAutoresponse(originalRequest, originalResponse, failResponse.data, failResponse.serviceResponse)
      originalResponse=null if @proxyAutorespond  #in order to avoid response allready send exception
      @onProxyError? originalRequest, originalResponse, failResponse.data, failResponse.serviceResponse
 
  # Build's the http request setting request body and headers values
  @buildRequest: (requestValues, authentication ) ->
    requestValues = { path: requestValues, query:"", method: "GET", data: {} } if !_.isObject(requestValues)
    requestValues.path += requestValues.query

    options =
      method: requestValues.method
      data: JSON.stringify(requestValues.data)
      headers:
        Accept: "application/json"
        "Accept-Encoding": "gzip"
        Authorization: "OAuth " + authentication.access_token
        "Content-Type": "application/json"

    return {url: authentication.instance_url + requestValues.path, options: options}

  # This function actually sends the request to salesforce and pipes down the response
  # It's separated into it's own method in order to Mock it for testing
  @sendRequest: (request) ->
    defered = Q.defer()
    salesforceRequest = restler.request request.url, request.options

    salesforceRequest.on "success", (data, response) =>
      defered.resolve { data: JSON.parse(data), serviceResponse: response }

    salesforceRequest.on "fail", (error, response ) => defered.reject data: error, serviceResponse: response
    salesforceRequest.on "error", (error, response ) => defered.reject data: error, serviceResponse: response
    
    return defered.promise

  # This is the standard way the proxy responds to all requests
  # It's set with options: options.proxyAutorespond = true
  # It may work in conjuntion with options.onProxySuccess and options.onProxyError
  # If both responses are used, options.onProxySuccess does not carry originalReponse in order to avoid response all ready send exception.
  @proxyAutoresponse: (originalRequest, originalResponse, data, response) ->
    originalResponse.status response.statusCode
    if response.statusCode >= 200 and response.statusCode < 400
      originalResponse.send @responseFactory originalRequest, originalResponse, data, response
    else
      originalResponse.send @errorResponseFactory originalRequest, originalResponse, data, response

  #When using the standard rest, this function transforms expected actions into salesforce service calls
  @serviceDataFromReq: (originalRequest) ->
    method = originalRequest.route.method.toLowerCase()
    serviceData = {}
  
    if method == "get" and originalRequest.query.query
      originalRequest.params.service = "query"
      originalRequest.params.mayRequireRequery= true
      serviceData = Proxy.serviceFactory( "query" , null , null ,originalRequest.query.query)
      
    else if method == "get" and originalRequest.query.search
      originalRequest.params.service = "search"
      serviceData = Proxy.serviceFactory( "search" , null, null, originalRequest.query.search)

    else if method == "get"
      originalRequest.params.service = "retrieve"
      serviceData = Proxy.serviceFactory( "retrieve" , originalRequest.params.objectType, originalRequest.params.objectId, originalRequest.query)

    else if method == "post"
      originalRequest.params.service = "create"
      serviceData = Proxy.serviceFactory( "create" , originalRequest.params.objectType, originalRequest.params.objectId, originalRequest.body)

    else if method == "put"
      originalRequest.params.service = "update"
      serviceData = Proxy.serviceFactory( "update" , originalRequest.params.objectType, originalRequest.params.objectId, originalRequest.body)

    else if method == "delete"
      originalRequest.params.service = "del"
      serviceData = Proxy.serviceFactory( "del" , originalRequest.params.objectType, originalRequest.params.objectId)

    serviceData
  
  # Factory to match Salesforce endpoints to a String, used as a Router Parameter
  @serviceFactory: (service, objectType, objectId, data={}) ->
    
    services=
      versions: "/"

      resources: @servicesUrl + @apiVersion + "/"

      describeGlobal: @servicesUrl + @apiVersion + "/sobjects/"

      identity: "#{@servicesUrl}/#{objectId}/"

      metadata: @servicesUrl + @apiVersion + "/sobjects/" + objectType + "/"

      describe: @servicesUrl + @apiVersion + "/sobjects/" + objectType + "/describe/"

      retrieve: @servicesUrl + @apiVersion + "/sobjects/" + objectType + "/" + objectId +  (if data.fields then "/?fields=" + JSON.stringify(data.fields) else "/")

      create:
        path: @servicesUrl + @apiVersion + "/sobjects/" + objectType + "/"
        method: "POST"
        data: JSON.stringify(data)

      upsert: 
        path: @servicesUrl + @apiVersion + "/sobjects/" + objectType + "/" + data.externalIdField + "/" + objectId + "/"
        method: "PATCH"
        data: JSON.stringify(data.fields) if data.fields

      update:
        path: @servicesUrl + @apiVersion + "/sobjects/" + objectType + "/" + objectId + "/"
        method: "PATCH"
        data: JSON.stringify(data)

      del:
        path: @servicesUrl + @apiVersion + "/sobjects/" + objectType + "/" + objectId + "/"
        method: "DELETE"

      search: @servicesUrl + @apiVersion + "/search/?q=" + escape(data)

      query: @servicesUrl + @apiVersion + "/query/?q=" + escape(data)

      queryMore: data.nextRecordsUrl

      apex:      
        path: "/services/apexrest/#{objectType}/"
        query: if objectId == "GET" then "?#{querystring.stringify(data)}" else ""
        method: objectId
        data:  if objectId == "GET" then null else JSON.stringify(data)

      chatter: @servicesUrl + @apiVersion + "/chatter/feeds/" + objectType + "/" + objectId + "/feed-items/" #news,user-profile,record

    return services[service]
    
  # Transforms the Original Salesforce Error into the Standard Proxy Error Messsage
  @errorResponseFactory: (originalRequest, originalResponse, responseData, serviceResponse) ->
    #responseData = JSON.parse responseData
    #responseData = _.extend( {} , responseData )if _.isArray(responseData)
    return responseData

  #Transforms the Original Salesforce into what would be expected on traditional REST
  @responseFactory: (originalRequest, originalResponse, responseData, serviceResponse) ->
    service = originalRequest.params.service
    
    if service == "versions" or service == "resources" or service == "describeGlobal" or service == "identity" or service == "describe"
      return responseData

    else if service == "retrieve" or service == "apex" or service == "chatter" or service == "search"
      return responseData
      
    else if service == "create"
      originalRequest.body.id = responseData.id
      originalRequest.body.objectType= originalRequest.params.objectType
      return originalRequest.body

    else if service == "update"
      originalRequest.body.objectType= originalRequest.params.objectType
      return originalRequest.body
    
    else if service == "del"
      return { id: originalRequest.params.objectId, objectType: originalRequest.params.objectType }
    
    else if service == "upsert" and responseData
      #for upsert resulting in insert
      originalRequest.body.id = responseData.id
      originalRequest.body.objectType= originalRequest.params.objectType
      return originalRequest.body

    else if service == "upsert" and !responseData
      #for upsert resulting in update
      originalRequest.body.objectType= originalRequest.params.objectType
      return originalRequest.body
      
    else if service == "query"
      return originalResponse.queryRecords

  #The Controller is structures this way in order to match other Express/Connect "Plugins"
  @controller: (app,options) ->
    return new Proxy(app,options)

module.exports = Proxy

