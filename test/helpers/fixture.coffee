_ = require("lodash")

basicConfig = { subscription: "una-subscription", topic: "un-topic", app: "una-app" }
deadLetterConfig = _.merge deadLetter: true, basicConfig
filtersConfig = _.merge filters: [{name: "un-filtro", expression: "un_filtro eq 'True'"}], basicConfig
message =
  body: JSON.stringify { un: "json", CompanyId: 123, ResourceId: 456 }
  brokerProperties:
    MessageId: "el-message-id"
    DeliveryCount: 11


module.exports = {
  basicConfig
  deadLetterConfig
  filtersConfig
  message
}
