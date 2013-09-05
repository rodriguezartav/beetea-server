module.exports = BeeCors = (options = {}) ->

  BeeCors = (req , res , next)  =>
    return next() if !req.headers.origin

    resolvedOrigin = false
    for originObject in options.origins
      requestOrigin = req.headers.origin.toLowerCase()
      thisOrigin = originObject.origin.toLowerCase()
      resolvedOrigin = originObject if requestOrigin.indexOf(thisOrigin) > -1 

    return res.send 500 if !resolvedOrigin
    return res.send 200 if req.method == 'OPTIONS'

    res.header('Access-Control-Allow-Origin'  , req.headers.origin );
    res.header('Access-Control-Allow-Methods' , resolvedOrigin.allowedMethods);
    res.header("Access-Control-Allow-Headers" , "Accept,Content-Type,X-Requested-With,X-Parse-REST-API-Key,X-Parse-REST-API-Key");

    next()
