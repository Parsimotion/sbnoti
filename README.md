# servicebus-notifications-reader
##### (or `sbnoti` because Azure has problems with large path names -__-)
Notifications Reader for Azure Service Bus

Usage:
```coffee-script
Promise = require("bluebird")
NotificationsReader = require("sbnoti")

reader = new NotificationsReader
  connectionString: "the azure connection string"
  topic: "the topic name"
  subscription: "the subscription name"
  # optional:
  options: log: true
  filters: [
    { name: "customFilter", expression: "created = True" }
  ]

reader.run (message) =>
  # do something with message
  
  Promise.resolve "message processed ok"
  # or...
  Promise.reject "error processing the message"
```
