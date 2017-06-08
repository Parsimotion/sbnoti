Promise = require("bluebird")
sinon = require("sinon")
_ = require("lodash")

module.exports =
  class ObserverStub
    constructor: ->
      @success = sinon.spy()
      @error = sinon.spy()

    appliesToPending: -> true
    appliesToFailed: -> true
