convert = require("convert-units")
module.exports = #milliseconds
  MINIMAL: process.env.MINIMAL_DELAY or 100
  MILD: process.env.MILD_DELAY or convert(10).from('s').to 'ms'
  MODERATE: process.env.MODERATE_DELAY or convert(30).from('s').to 'ms'
  HIGH: process.env.HIGH_DELAY or convert(5).from('m').to 'ms'
  HUGE: process.env.HUGE_DELAY or convert(10).from('m').to 'ms'
