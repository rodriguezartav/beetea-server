fs = require 'fs'
path = require 'path'
_  = require 'lodash'
_.str = require("underscore.string")
_.mixin _.str.exports()

# load policies and rules from directory
class LoadPolicies
  
  @load: (app,dir) =>
    app.rules = {}
    throw "Directory #{dir} does not exists" if !fs.existsSync(dir)
    
    # requests stored policies
    app.policies = require("#{dir}/policies")(app)
    @autoload(app,"#{dir}/rules")

  @autoload = (app, dir, camelCase) ->
    return unless fs.existsSync dir
    
    #for each file in directory
    for filename in fs.readdirSync(dir)
      pathname = path.join dir, filename

      #if its directory the recursive
      if fs.lstatSync(pathname).isDirectory()
        autoload app, pathname
      else
        #load rule module
        policyModule = require(pathname)
        # strore rule by file name for comparing later with request url
        app.rules[filename.split(".")[0]] = policyModule

module.exports = LoadPolicies
