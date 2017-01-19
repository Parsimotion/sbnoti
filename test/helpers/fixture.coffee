_ = require("lodash")

basicConfig = { subscription: "una-subscription", topic: "un-topic" , log:true}
deadLetterConfig = _.merge deadLetter: true, basicConfig
filtersConfig = _.merge filters: [{name: "un-filtro", expression: "un_filtro eq 'True'"}], basicConfig

module.exports = {
  basicConfig
  deadLetterConfig
  filtersConfig
}
