# servicebus-notifications-reader
Notifications Reader for Azure Service Bus

Usage:
```coffee-script
Promise = require("bluebird")
NotificationsReader = require("servicebus-notifications-reader")

reader = new NotificationsReader
  connectionString: "the azure connection string"
  topic: "the topic name"
  subscription: "the subscription name"
  options:
    logs: true #defaults to false

reader.run (message) =>
  # do something with message
  
  Promise.resolve "message processed ok"
  # or...
  Promise.reject "error processing the message"
```
