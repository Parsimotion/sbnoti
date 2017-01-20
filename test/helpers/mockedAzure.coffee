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

        _functionsToSpy: -> ["createSubscription","createRule","deleteRule","unlockMessage","deleteMessage","receiveSubscriptionMessage"]

        refreshSpies: =>
          @spies = @_functionsToSpy()
          .reduce (spies,key) =>
            _.update spies, key, -> sinon.spy()
          , {}

        createServiceBusService: =>
          createSubscription: asyncify @spies.createSubscription
          createRule: asyncify @spies.createRule
          deleteRule: asyncify @spies.deleteRule
          unlockMessage: asyncify @spies.unlockMessage
          deleteMessage: asyncify @spies.deleteMessage
          receiveSubscriptionMessage: asyncify @spies.receiveSubscriptionMessage

  proxyquire("../../src/notificationsReader", stub)
  stub.azure

