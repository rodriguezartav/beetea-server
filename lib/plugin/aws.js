(function() {
  module.exports = function(app) {
    var AWS, awsConfig;
    AWS = require("aws-sdk");
    awsConfig = process.env;
    AWS.config.update({
      accessKeyId: awsConfig.AWS_ACCESS_KEY_ID,
      secretAccessKey: awsConfig.AWS_SECRET_ACCESS_KEY,
      region: awsConfig.AWS_REGION
    });
    return app.aws = {
      client: AWS,
      services: {},
      getService: function(service) {
        var client, services;
        services = app.Aws.services;
        client = app.Aws.client;
        if (!services[service]) {
          services[service] = new client[service]();
        }
        return services[service];
      }
    };
  };

}).call(this);
