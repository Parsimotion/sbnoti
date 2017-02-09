convert = require("convert-units")
module.exports = #milliseconds
  minimal:
    name: "Minimal"
    value: process.env.MINIMAL_DELAY or 100 #Innecesario?
  mild:
    name: "Mild"
    value: process.env.MILD_DELAY or convert(10).from('s').to 'ms'
  moderate:
    name: "Moderate"
    value: process.env.MODERATE_DELAY or convert(10).from('s').to 'ms'
  high:
    name: "High"
    value: process.env.HIGH_DELAY or convert(5).from('min').to 'ms'
  huge:
    name: "Huge"
    value: process.env.HUGE_DELAY or convert(10).from('min').to 'ms'
