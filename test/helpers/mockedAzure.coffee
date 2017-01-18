proxyquire = require("proxyquire")
Promise = require("bluebird")
module.exports = ->
  stub =
    "azure":
      createServiceBusService: ->
        Promise.resolve { }
      createSubscription: ->

  proxyquire("../../src/notificationsReader", stub)

