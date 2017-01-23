_ = require("lodash")

basicConfig = { subscription: "una-subscription", topic: "un-topic", app: "una-app" }
deadLetterConfig = _.merge deadLetter: true, basicConfig
filtersConfig = _.merge filters: [{name: "un-filtro", expression: "un_filtro eq 'True'"}], basicConfig

health = health:
          redis:
            host: "127.0.0.1"
            port: "1234"
            db: "3"
            auth: "unaCadenaDeAuth",

healthConfig = _.merge { }, health, basicConfig

message =
  body: JSON.stringify { un: "json", CompanyId: 123, ResourceId: 456 }
  brokerProperties:
    MessageId: "el-message-id"
    DeliveryCount: 11

retryableMessage = _(_.clone(message))
  .assign
      brokerProperties:
        MessageId: "otro-message-id"
        DeliveryCount: 1
  .value()

module.exports = {
  basicConfig
  deadLetterConfig
  filtersConfig
  healthConfig
  message
  retryableMessage
}
