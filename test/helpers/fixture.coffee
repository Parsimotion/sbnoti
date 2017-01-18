_ = require("lodash")

basicConfig = { subscription: "una-subscription", topic: "un-topic" }
deadLetterConfig = _.merge deadLetter: true, basicConfig
filtersConfig = _.merge filters: "un_filtro eq 'True'", basicConfig

module.exports = {
  basicConfig
  deadLetterConfig
  filtersConfig
}
