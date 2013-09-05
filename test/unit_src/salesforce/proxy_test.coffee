should = require("should")
Proxy = require("../../lib/salesforce/proxy")
Q= require("q")

# define server base URL

describe "Salesforce Proxy", ->

  before ->
    @app = {}


  it "should return a DELETE" , ->
    req = 
      route:
        method: "DELETE"
      params:
        objectType: "Account"
        objectId: "id"

    data= Proxy.serviceDataFromReq(req)
    data.path.indexOf("/Account/").should.be.above -1
    data.method.should.equal "DELETE"


  it "should return a UPDATE" , ->
    req = 
      route:
        method: "PUT"
      params:
        objectType: "Account"
        objectId: "id"
      body:
        name: "test"

    data= Proxy.serviceDataFromReq(req)
    data.path.indexOf("/Account/").should.be.above -1
    data.method.should.equal "PATCH"
    data.data.indexOf("test").should.be.above -1

  it "should return a CREATE" , ->
    req = 
      route:
        method: "POST"
      params:
        objectType: "Account"
      body:
        name: "test"

    data= Proxy.serviceDataFromReq(req)
    data.path.indexOf("/Account/").should.be.above -1
    data.method.should.equal "POST"
    data.data.indexOf("test").should.be.above -1


  it "should return a retrieve" , ->
    req = 
      query: {}
      route:
        method: "GET"
      params:
        objectType: "Account"
        objectId: "id"
        
        
    data= Proxy.serviceDataFromReq(req)
    data.indexOf("/Account/id/").should.be.above -1
    
  it "should return a query" , ->
    req = 
      route:
        method: "GET"
      query:
        query: "select id from account"
      params: {}

    data= Proxy.serviceDataFromReq(req)
    data.indexOf("/query").should.be.above -1


  it "should return a search" , ->
    req = 
      route:
        method: "GET"
      query:
        search: "select id from account"
      params: {}


    data= Proxy.serviceDataFromReq(req)
    data.indexOf("/search").should.be.above -1

  it "should run auto respond" , (done) ->
    defered = Q.defer()

    originalRequest=
      params:
        service: "versions"
    
    originalResponse=
      status: (status) ->
        
      send: (data) ->
        done()

    proxy = new Proxy(@app, {})

    proxy.proxyComplete(originalRequest, originalResponse,defered.promise)

    defered.resolve
      data: {name: "test",success: true}
      serviceResponse: {statusCode: 200}

  it "should run auto respond error" , (done) ->
    defered = Q.defer()

    originalResponse=
      status: (status) ->
      send: (data) ->
        @status.should.equal 500
        done()

    proxy = new Proxy(@app, {})

    proxy.proxyComplete({}, originalResponse,defered.promise)

    defered.reject "error"

  it "should run proxy complete" , (done) ->
    defered = Q.defer()

    originalResponse={}
    
    options = 
      onProxySuccess: =>
        done()
      onProxyError: =>
        console.log arguments

      proxyAutorespond: false

    proxy = new Proxy(@app, options)

    proxy.proxyComplete({}, originalResponse,defered.promise)

    defered.resolve
     data: {name: "test",success: true}
     serviceResponse: {statusCode: 200}

  it "should run proxy error" , (done) ->
    defered = Q.defer()

    originalResponse={}

    options = 
      onProxySuccess: =>

      onProxyError: =>
        done()

      proxyAutorespond: false

    proxy = new Proxy(@app, options)

    proxy.proxyComplete({}, originalResponse,defered.promise)

    defered.reject {}, {}

  it "should process autoresponse with success" , (done) ->
    originalRequest=
      params:
        service: "versions"
    
    originalResponse=
      status: (status) -> 
      send: (data) ->
        data.temp.should.equal "temp"
        done()

    Proxy.proxyAutoresponse(originalRequest, originalResponse, {temp: "temp",success: true}, {statusCode: 200})


  it "should process autoresponse with error" , (done) ->
    originalRequest=
      params:
        service: "versions"
    
    originalResponse=
      setStatus: 0 
      status: (status) ->
        @setStatus = status
        
      send: (data) ->
        @setStatus.should.equal 500
        done()

    Proxy.proxyAutoresponse(originalRequest, originalResponse, {success: false}, {statusCode: 500})

 
  it "should build a request with string" ,  ->
    request = Proxy.buildRequest("/path/to/api", {access_token: "anyToken" , instance_url: "http://localhost"})
    request.url.should.equal "http://localhost/path/to/api"
    request.options.method.should.equal "GET"
    request.options.headers.Authorization.should.equal 'OAuth anyToken'

  it "should build a request with string" ,  ->
    request = Proxy.buildRequest( {path: "/path/to/api", method: "POST" , data: {name: "test"} } , {access_token: "anyToken" , instance_url: "http://localhost"})
    request.options.method.should.equal "POST"
    JSON.stringify(request.options.data).should.equal '{"name":"test"}'

 
  it 'should return path and data from serviceFactory', (done) ->

    Proxy.serviceFactory("versions").should.equal "/"

    Proxy.serviceFactory("resources").should.equal "/services/data/v24.0/"
    
    Proxy.serviceFactory("identity",null,"1").should.equal "/services/data/1/"
    Proxy.serviceFactory("describeGlobal").should.equal "/services/data/v24.0/sobjects/"
    Proxy.serviceFactory("metadata","account").should.equal "/services/data/v24.0/sobjects/account/"
    Proxy.serviceFactory("describe","account").should.equal "/services/data/v24.0/sobjects/account/describe/"
    

    Proxy.serviceFactory("retrieve","account","id").should.equal "/services/data/v24.0/sobjects/account/id/"
    Proxy.serviceFactory("search",null,null,"select id from account").should.equal "/services/data/v24.0/search/?q=select%20id%20from%20account"
    
    Proxy.serviceFactory("query",null,null,"select id from account").should.equal "/services/data/v24.0/query/?q=select%20id%20from%20account"
    Proxy.serviceFactory("chatter","record","id").should.equal "/services/data/v24.0/chatter/feeds/record/id/feed-items/"
    Proxy.serviceFactory("chatter","news","id").should.equal "/services/data/v24.0/chatter/feeds/news/id/feed-items/"
    Proxy.serviceFactory("chatter","profile-feed","id").should.equal "/services/data/v24.0/chatter/feeds/profile-feed/id/feed-items/"


    create = Proxy.serviceFactory("create","account",null,{name: "accName"})
    create.path.should.equal "/services/data/v24.0/sobjects/account/"
    create.method.should.equal "POST"
    create.data.should.equal '{"name":"accName"}'

    upsert = Proxy.serviceFactory("upsert","account","id",{externalIdField: "extId" , fields: {name: "t"}})
    upsert.path.should.equal "/services/data/v24.0/sobjects/account/extId/id/"
    upsert.method.should.equal "PATCH"
    upsert.data.should.equal '{"name":"t"}'

    update = Proxy.serviceFactory("update","account","id",{name: "test"})
    update.path.should.equal "/services/data/v24.0/sobjects/account/id/"
    update.method.should.equal "PATCH"
    update.data.should.equal '{"name":"test"}'

    del = Proxy.serviceFactory("del","account","id")
    del.path.should.equal "/services/data/v24.0/sobjects/account/id/"
    del.method.should.equal "DELETE"

    rest = Proxy.serviceFactory("apex","apex","POST",{name: "test"})
    rest.path.should.equal "/services/apexrest/apex/"
    rest.method.should.equal "POST"
    rest.data.should.equal '{"name":"test"}'

    rest = Proxy.serviceFactory("apex","apex","PUT",{name: "test"})
    rest.path.should.equal "/services/apexrest/apex/"
    rest.method.should.equal "PUT"
    rest.data.should.equal '{"name":"test"}'
    
    rest = Proxy.serviceFactory("apex","apex","DEL",{name: "test"})
    rest.path.should.equal "/services/apexrest/apex/"
    rest.method.should.equal "DEL"
    rest.data.should.equal '{"name":"test"}'


    rest = Proxy.serviceFactory("apex","apex","GET",{name: "test",lastname: "test2"})
    rest.path.should.equal "/services/apexrest/apex/"
    rest.query.should.equal '?name=test&lastname=test2'
    rest.method.should.equal "GET"

    done()
    

  it "should mock proxy 2" , (done) ->
    Proxy.sendRequest= (request) ->
      defered = Q.defer()
      defered.resolve {name: "ok"}, response
      return defered.promise
      
    done()
    

  it "should responde with query" , (done) ->
    originalResponse=
      queryRecords: ["a","b"]

    originalRequest=
      params:
        service: "query"

    res = Proxy.responseFactory(originalRequest,originalResponse)
    res[0].should.equal "a"
    done()

  it "should responde with delete" , (done) ->
    originalResponse= {}

    originalRequest=
      params:
        objectId: "id"
        objectType: "account"
        service: "del"

    res = Proxy.responseFactory(originalRequest,originalResponse)
    res.id.should.equal "id"
    res.objectType.should.equal "account"
    done()
    
    
  it "should responde with update", (done) ->

    originalResponse= {}

    originalRequest=
      body:
        id: "id"
        name: "test"
      params: 
        service: "update"

    originalRequest2=
      body:
        id: "id2"
        name: "test2"
      params:
        service: "update"
      

    res = Proxy.responseFactory(originalRequest,originalResponse)
    res.id.should.equal "id"
    res.name.should.equal "test"

    res2 = Proxy.responseFactory(originalRequest2,originalResponse)
    res2.id.should.equal "id2"
    res2.name.should.equal "test2"
    done()


  it "should responde with create", (done) ->
    
    originalResponse= {}

    originalRequest=
      body:
        name: "test"
      params:
        service: "create"
      

    originalRequest2=
      body:
        name: "test2"
      params:
        service: "create"

    res = Proxy.responseFactory(originalRequest,originalResponse, {id: "id"})
    res.id.should.equal "id"
    res.name.should.equal "test"

    res2 = Proxy.responseFactory(originalRequest2,originalResponse, {id: "id2"})
    res2.id.should.equal "id2"
    res2.name.should.equal "test2"
    done()
    

  it "should respond with original api response" , (done) ->

    originalResponse= {}

    originalRequest=
      params:
        service: "versions"

    res = Proxy.responseFactory(originalRequest,originalResponse,"test")
    res.should.equal "test"


    originalRequest=
      params:
        service: "resources"

    res = Proxy.responseFactory(originalRequest,originalResponse,"test")
    res.should.equal "test"

    originalRequest=
      params:
        service: "describeGlobal"

    res = Proxy.responseFactory(originalRequest,originalResponse,"test")
    res.should.equal "test"

    originalRequest=
      params:
        service: "identity"

    res = Proxy.responseFactory(originalRequest,originalResponse,"test")
    res.should.equal "test"

    originalRequest=
      params:
        service: "describe"

    res = Proxy.responseFactory(originalRequest,originalResponse,"test")
    res.should.equal "test"

    originalRequest=
      params:
        service: "retrieve"

    res = Proxy.responseFactory(originalRequest,originalResponse,"test")
    res.should.equal "test"

    originalRequest=
      params:
        service: "apex"

    res = Proxy.responseFactory(originalRequest,originalResponse,"test")
    res.should.equal "test"

    originalRequest=
      params:
        service: "apex"

    res = Proxy.responseFactory(originalRequest,originalResponse,"test")
    res.should.equal "test"

    originalRequest=
      params:
        service: "chatter"

    res = Proxy.responseFactory(originalRequest,originalResponse,"test")
    res.should.equal "test"

    originalRequest=
      params:
        service: "search"

    res = Proxy.responseFactory(originalRequest,originalResponse,"test")
    res.should.equal "test"
    done()
