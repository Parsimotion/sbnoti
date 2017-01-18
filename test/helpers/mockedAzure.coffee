proxyquire = require("proxyquire")
Promise = require("bluebird")
module.exports = ->
  stub =
    "azure":
      createServiceBusService: ->
        Promise.resolve { }

  proxyquire("../../src/notificationsReader", stub)

