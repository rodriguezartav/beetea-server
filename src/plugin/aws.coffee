module.exports = (app) ->
  AWS = require("aws-sdk")
  awsConfig = process.env
  AWS.config.update({accessKeyId: awsConfig.AWS_ACCESS_KEY_ID, secretAccessKey: awsConfig.AWS_SECRET_ACCESS_KEY , region: awsConfig.AWS_REGION });
  
  app.aws=
    client: AWS 
    services: {}
    getService: (service) ->
      services = app.Aws.services
      client = app.Aws.client
      services[service] = new client[service]() if !services[service]
      return services[service]
