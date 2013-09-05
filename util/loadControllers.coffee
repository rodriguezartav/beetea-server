fs = require 'fs'
path = require 'path'
_  = require 'lodash'
_.str = require("underscore.string")
_.mixin _.str.exports()

# automatically load the controllers into spine 
class LoadControllers
  
  @load: (app,dir) =>
    app.controllers = {}
    
    # the directory supplied must be valid
    throw "Directory #{dir} does not exists" if !fs.existsSync(dir)
    @autoload(app,dir)

  #recursive function to find controllers inside of directory
  @autoload = (app, dir, camelCase) ->
    #double check for recursive scenario
    return unless fs.existsSync dir
    
    #each file in directory
    for filename in fs.readdirSync(dir)
      pathname = path.join dir, filename
      
      #if is directory then recursive autoLoad
      if fs.lstatSync(pathname).isDirectory()
        @autoload app, pathname
      else
        #load module
        controllerModule = require(pathname)

        #get route for mapping
        route = controllerModule.route

        #instantiate module
        loadedModule = new controllerModule( app )
        
        #store instantiation in variable for access from app
        app.controllers[route] = loadedModule 

module.exports = LoadControllers