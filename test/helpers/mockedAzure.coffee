proxyquire = require("proxyquire")
Promise = require("bluebird")
{ spies } = require("./fixture")
sinon = require("sinon")
_ = require("lodash")
module.exports = ->

  asyncify = (fn) ->
    (args...) ->
      fn args...
      _(args).last() null, {}

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
            receiveSubscriptionMessage: sinon.spy()

        createServiceBusService: =>
          createSubscription: asyncify @spies.createSubscription
          createRule: asyncify @spies.createRule
          deleteRule: asyncify @spies.deleteRule
          unlockMessage: asyncify @spies.unlockMessage
          deleteMessage: asyncify @spies.deleteMessage
          receiveSubscriptionMessage: asyncify @spies.receiveSubscriptionMessage
            # createSubscription: asyncify (topic,subscription) =>
            #   @spies.createSubscription topic, subscription
            # createRule: asyncify (topic, subscription, name, expression) =>
            #   @spies.createRule topic, subscription, name , expression
            # deleteRule: asyncify (topic,subscription,rule,callback) =>
            #   @spies.deleteRule topic, subscription, rule
            # unlockMessage: asyncify (message) =>
            #   @spies.unlockMessage message
            # deleteMessage: asyncify (message) =>
            #   @spies.deleteMessage message
            # receiveSubscriptionMessage: asyncify (topic, subscription) =>
            #   @spies.receiveSubscriptionMessage topic, subscription

  proxyquire("../../src/notificationsReader", stub)
  stub.azure

