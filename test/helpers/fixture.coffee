_ = require("lodash")
sinon = require("sinon")
{ Buffer } = require("buffer")

basicConfig = { subscription: "una-subscription", topic: "un-topic", connectionString: "Endpoint=sb://hostname.servicebus.windows.net/;SharedAccessKeyName=sakName;SharedAccessKey=sak", apm: { active: no } }
deadLetterConfig = _.merge deadLetter: true, basicConfig
redis =
  host: "127.0.0.1"
  port: "1234"
  db: "3"
  auth: "unaCadenaDeAuth",

message =
  body: Buffer.from JSON.stringify { un: "json", CompanyId: 123, ResourceId: 456 }
  messageId: "el-message-id"
  deliveryCount: 11
  enqueuedTimeUtc: "Sat, 05 Nov 2016 16:44:43 GMT"

messageWithParsedBody = _.update _.clone(message), "body", JSON.parse

retryableMessage = _(_.clone(message))
  .assign
    messageId: "otro-message-id"
    deliveryCount: 1
  .value()

notification =_.omit _.merge {app: 'una-app'}, basicConfig, { message: messageWithParsedBody }, "connectionString"
retryableNotification =_.merge {}, notification,{ message: retryableMessage }

module.exports = {
  basicConfig
  deadLetterConfig
  retryableMessage
  redis
  notification
  retryableNotification
  getMessage: ->
    _.merge _.clone(message), {
      abandon: sinon.stub().resolves("ok")
      complete: sinon.stub().resolves("ok")
    }
}
