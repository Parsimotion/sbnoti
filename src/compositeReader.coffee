_ = require("lodash")

module.exports =
class CompositeReader
  constructor: (@_sbnotis) ->
    @_setUpConvinienceMethods()

  run: (process) =>
    @_forEachSbnoti (sbnoti) => sbnoti.run process

  runAndRequest: (messageToOptions, method = 'post') =>
    @_forEachSbnoti (sbnoti) => sbnoti.runAndRequest messageToOptions, method

  _setUpConvinienceMethods: =>
    ['post','get','put','delete'].map (verb) =>
      @["runAnd#{_.capitalize verb}"] = _.partialRight @runAndRequest, verb

  _forEachSbnoti: (fn) => @_sbnotis.forEach fn
