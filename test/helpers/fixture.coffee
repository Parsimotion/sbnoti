_ = require("lodash")

basicConfig = { subscription: "una-subscription", topic: "un-topic", connectionString: "un-connection-string" }
deadLetterConfig = _.merge deadLetter: true, basicConfig
filtersConfig = _.merge filters: [{name: "un-filtro", expression: "un_filtro eq 'True'"}], basicConfig
redis =
  host: "127.0.0.1"
  port: "1234"
  db: "3"
  auth: "unaCadenaDeAuth",

message =
  body: JSON.stringify { un: "json", CompanyId: 123, ResourceId: 456 }
  brokerProperties:
    MessageId: "el-message-id"
    DeliveryCount: 11
    EnqueuedTimeUtc: "Sat, 05 Nov 2016 16:44:43 GMT"

retryableMessage = _(_.clone(message))
  .assign
      brokerProperties:
        MessageId: "otro-message-id"
        DeliveryCount: 1
  .value()

notification =_.omit _.merge {app: 'una-app'}, basicConfig, { message }, "connectionString"
retryableNotification =_.merge {}, notification,{ message: retryableMessage }

module.exports = {
  basicConfig
  deadLetterConfig
  filtersConfig
  message
  retryableMessage
  redis
  notification
  retryableNotification
}
