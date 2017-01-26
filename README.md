# servicebus-notifications-reader
##### (or `sbnoti` because Azure has problems with large path names -__-)
Notifications Reader for Azure Service Bus

Usage:
```coffee-script
Promise = require("bluebird")
SBNotiBuilder = require("sbnoti")

reader = new SBNotiBuilder()
.withServiceBus
  connectionString: "the azure connection string"
  topic: "the topic name"
  subscription: "the subscription name"
.withFilters [
    { name: "theNameOfTheCustomFilter", expression: "created = True" }
  ]
  # more optional (the values are the defaults):
.withLogging()
.fromDeadLetter()
.withConcurrency 25
...
.build()

reader.run (message) =>
  # do something with message
  
  Promise.resolve "message processed ok"
  # or...
  Promise.reject "error processing the message"
```

Or also with new builder:
```coffee-script

```

