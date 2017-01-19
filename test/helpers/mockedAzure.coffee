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
        createServiceBusService: =>
            createSubscription: (a,b,callback) =>
              @spies["createSubscription"] a, b
              callback null, {}
            createRule: (a,b,c,d,callback) =>
              @spies["createRule"] a, b, c , d
              callback null, {}
            deleteRule: (a,b,c,callback) =>
              @spies["deleteRule"] a, b, c
              callback null, {}

  proxyquire("../../src/notificationsReader", stub)
  stub.azure

