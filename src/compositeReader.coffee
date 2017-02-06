module.exports =
class CompositeReader
  constructor: (@_sbnotis) ->

  run: (process) =>
    @_sbnotis.forEach (sbnoti) => sbnoti.run process

  runAndPost: (messageToOptions) =>
    @runAndRequest messageToOptions, 'post'
  runAndPut: (messageToOptions) =>
    @runAndRequest messageToOptions, 'put'
  runAndDelete: (messageToOptions) =>
    @runAndRequest messageToOptions, 'delete'
  runAndGet: (messageToOptions) =>
    @runAndRequest messageToOptions, 'get'
  runAndRequest: (messageToOptions, method = 'post') =>
    @_sbnotis.forEach (sbnoti) => sbnoti.runAndRequest messageToOptions, method
