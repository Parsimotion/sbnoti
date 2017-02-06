
module.exports =
class CompositeReader
  constructor: (@_sbnotis) ->

  run: (process) =>
    @_forEachSbnoti (sbnoti) => sbnoti.run process

  runAndPost: (messageToOptions) =>
    @runAndRequest messageToOptions, 'post'
  runAndPut: (messageToOptions) =>
    @runAndRequest messageToOptions, 'put'
  runAndDelete: (messageToOptions) =>
    @runAndRequest messageToOptions, 'delete'
  runAndGet: (messageToOptions) =>
    @runAndRequest messageToOptions, 'get'
  runAndRequest: (messageToOptions, method = 'post') =>
    @_forEachSbnoti (sbnoti) => sbnoti.runAndRequest messageToOptions, method

  _forEachSbnoti: (fn) => @_sbnotis.forEach fn
