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
            createSubscription: (a,b,callback) =>
              @spies["createSubscription"] a, b
              callback null, {}
            createRule: (a,b,c,d,callback) =>
              @spies["createRule"] a, b, c , d
              callback null, {}
            deleteRule: (a,b,c,callback) =>
              @spies["deleteRule"] a, b, c
              callback null, {}
            unlockMessage: (message, callback) =>
              console.log "LIBEEEEEEERA"
              @spies["unlockMessage"] message
              callback null, {}
            deleteMessage: (message, callback) =>
              console.log "BORRRRRRRRRRRA"
              @spies["deleteMessage"] message
              callback null, {}
            receiveSubscriptionMessage: (a,b,callback) =>
              callback null, {}

  proxyquire("../../src/notificationsReader", stub)
  stub.azure

