proxyquire = require("proxyquire")
Promise = require("bluebird")
{ spies } = require("./fixture")
sinon = require("sinon")

module.exports = ->
  stub =
    "azure":
      new class AzureMock
        constructor: ->
          @refreshSpies()
        refreshSpies: =>
          @spies =
            createSubscription: sinon.spy()
            createRule: sinon.spy()
            deleteRule: sinon.spy()
            unlockMessage: sinon.spy()
            deleteMessage: sinon.spy()
        createServiceBusService: =>
            createSubscription: (topic,subscription,callback) =>
              @spies.createSubscription topic, subscription
              callback null, {}
            createRule: (topic, subscription, name, expression, callback) =>
              @spies.createRule topic, subscription, name , expression
              callback null, {}
            deleteRule: (topic,subscription,rule,callback) =>
              @spies.deleteRule topic, subscription, rule
              callback null, {}
            unlockMessage: (message, callback) =>
              @spies.unlockMessage message
              callback null, {}
            deleteMessage: (message, callback) =>
              @spies.deleteMessage message
              callback null, {}
            receiveSubscriptionMessage: (topic, subscription, callback) =>
              @spies.receiveSubscriptionMessage topic, subscription
              callback null, {}

  proxyquire("../../src/notificationsReader", stub)
  stub.azure

