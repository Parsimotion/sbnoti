_ = require("lodash")

basicConfig = { subscription: "una-subscription", topic: "un-topic" }
deadLetterConfig = _.merge deadLetter: true, basicConfig
filtersConfig = _.merge filters: [{name: "un-filtro", expression: "un_filtro eq 'True'"}], basicConfig
message =
  body: JSON.stringify un: "json"
  brokerProperties:
    MessageId: "el-message-id"
    DeliveryCount: 11


module.exports = {
  basicConfig
  deadLetterConfig
  filtersConfig
  message
}
