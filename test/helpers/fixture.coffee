_ = require("lodash")

config = { subscription: "una-subscription", topic: "un-topic" }

module.exports =
  aConfig: config
  deadLetterConfig: _.merge  deadLetter: true, config
