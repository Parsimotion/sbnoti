proxyquire = require("proxyquire")
Promise = require("bluebird")
module.exports = ->
  stub =
    "azure":
      createServiceBusService: -> {
          createSubscription: -> console.log "este es el mock del service bus en createSubscription"
          createRule: -> console.log "createRuleAsync mock del service bus en "
      }

  proxyquire("../../src/notificationsReader", stub)

