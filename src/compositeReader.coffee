_ = require("lodash")

module.exports =
class CompositeReader
  constructor: (@_sbnotis) ->
    @_setUpConvinienceMethods()

  run: (process) =>
    @_forEachSbnoti (sbnoti) => sbnoti.run process

  runAndRequest: (messageToOptions, method, options) =>
    @_forEachSbnoti (sbnoti) => sbnoti.runAndRequest messageToOptions, method or 'post', options

  _setUpConvinienceMethods: =>
    ['post','get','put','delete'].map (verb) =>
      @["runAnd#{_.capitalize verb}"] = _.partial @runAndRequest, _, verb

  _forEachSbnoti: (fn) => @_sbnotis.forEach fn
