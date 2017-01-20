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
          @_functionsToSpy()
          .reduce (service,value) =>
            _.update service, value, => asyncify @spies[value]
          , {}

  proxyquire("../../src/notificationsReader", stub)
  stub.azure

