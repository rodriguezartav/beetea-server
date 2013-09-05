_ = require("lodash")

module.exports = beePolicy = (options = {}) ->
  throw "Policies array must be provided options.policies = []" if !options.policies
  throw "Riles array must be policiesoptions.rules" if !options.rules

  beePolicy = (req, res, next) ->
    
    #If entity or action is not defined use rule for all
    entity = req.beeRequest.entity or "*"
    action = req.beeRequest.action or "*"

    #find in policies list of entities, if not defined fallback to all
    entityPolicies = options.policies[entity]
    entityPolicies = options.policies["*"] if _.isUndefined(entityPolicies)

    #find in entities list of actions, if not defined fallback to all
    rules = entityPolicies[action]
    rules = entityPolicies["*"] if _.isUndefined(rules)
  
    #if just one action, wrap in array
    rules = [ rules ] if _.isString(rules)

    result=true
    for rule in rules
      #call function with name equals to action in entity
      result = options.rules[rule](req,res) if result==true
      
    #if all rules passed , continue to perform action
    if !result
      res.status 500
      return res.send "Security Error: Permission not granted."
    else
      next() if result;
