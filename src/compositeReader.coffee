module.exports =
class CompositeReader
  constructor: (@_sbnotis) ->

  run: (process) =>
    @_sbnotis.forEach (sbnoti) => sbnoti.run process
