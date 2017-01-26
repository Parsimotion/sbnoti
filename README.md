# servicebus-notifications-reader
##### (or `sbnoti` because Azure has problems with large path names -__-)
Notifications Reader for Azure Service Bus

Usage:
```coffee-script
Promise = require("bluebird")
SBNotiBuilder = require("sbnoti")

reader = new SBNotiBuilder()
.withServiceBus #required
  connectionString: "the azure connection string"
  topic: "the topic name"
  subscription: "the subscription name"
#All settigns below are optional. The values are the defaults.
.withFilters [ 
    { name: "theNameOfTheCustomFilter", expression: "created = True" }
  ]
.withLogging true # or simply .withLogging()
.fromDeadLetter true # or simply .fromDeadLetter()
.withConcurrency 25
.withReceiveBatchSize 5
.withWaitForMessageTime 3000
# new health notifiying option:
.withHealth
  host: "redis.host.com"
  port: 6739
  db: 3
  auth: "yourAuthToken"
.build()

reader.run (message) =>
  # do something with message
  
  Promise.resolve "message processed ok"
  # or...
  Promise.reject "error processing the message"
```
