_ = require("lodash")
Promise = require("bluebird")
request = Promise.promisifyAll require("request")

module.exports =
  new class Http

    process: (messageToOptions, method, { @ignoredStatusCodes } = {}) =>
      (parsedMessageBody, message) =>
        parsedMessageBody = JSON.parse parsedMessageBody if _.isString parsedMessageBody
        @_makeRequest messageToOptions(parsedMessageBody, message), method

    _addDefaultOptions: (opts) => _.merge json: true, opts

    _makeRequest: (options, method = 'post') =>
      request["#{method}Async"] @_addDefaultOptions options
      .then ({ statusCode, body }) =>
        throw new Error body if @_isErrorStatusCode statusCode

    _isErrorStatusCode: (code) =>
      code >= 400 and !_.includes(@ignoredStatusCodes or [], code)
