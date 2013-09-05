sessions = require("client-sessions");
_ = require("lodash")

# Configure Session Cookies
## Session Cookies must have
 ## name: Name of the Cookie, goes to req[name], required
 ## secret: The Secret Encryption Key, required
 ## duration: Expire in Seconds, default: 1000 * 60 * 60 * 2
 ## path: The cookie path limit., default: /

module.exports= (app, sessionConfig ) ->
  throw "First Argument should be a Connect/Express Application" if !app.use
    
  sessionConfig = [sessionConfig] if !_.isArray(sessionConfig)
  
  for cookie in sessionConfig
    throw "Session Config must contain a name property" if !cookie.name
    throw "Session Config must contain a secret property"  if !cookie.secret
    options = 
      duration: cookie.duration or 24 * 60 * 60 * 1000
      path: cookie.path or "/"
      secure: if cookie.secure == null then true else cookie.secure
      httpOnly: if cookie.httpOnly == null then true else cookie.httpOnly
      
    app.use sessions
      cookieName: cookie.name
      secret: cookie.secret
      duration: options.duration, 
      cookie:
        path: options.path, 
        httpOnly: options.httpOnly, 
        secure: options.secure

