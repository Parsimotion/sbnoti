proxyquire = require("proxyquire")
Promise = require("bluebird")
{ spies } = require("./fixture")
sinon = require("sinon")
_ = require("lodash")

asyncify = (fn) ->
  (args...) ->
    fn args...
    _(args).last() null, {}

stub =
  "azure":
    new class AzureMock
      constructor: ->
        @refreshSpies()

      _functionsToSpy: -> ["createSubscription","createRule","deleteRule","unlockMessage","deleteMessage","receiveSubscriptionMessage","getSubscription"]

      _reduceFunctions: (reducer) =>
        @_functionsToSpy().reduce reducer, {}

      refreshSpies: =>
        @spies = @_reduceFunctions (spies,key) => _.update spies, key, -> sinon.spy()

      createServiceBusService: =>
        @_reduceFunctions (service,value) => _.update service, value, => asyncify @spies[value]
stub["@global"] = true
proxyquire("../../src/notificationsReader.builder", stub)

module.exports = stub.azure

