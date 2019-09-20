# servicebus-notifications-reader
##### (or `sbnoti` because Azure has problems with large path names -__-)
Notifications Reader for Azure Service Bus

### Usage:
```coffee-script
SbnotiBuilder = require("sbnoti")

reader = new SbnotiBuilder()
.withServiceBus #required
  connectionString: "the azure connection string"
  topic: "the topic name"
  subscription: "the subscription name"
#All settigns below are optional. The values are the defaults.
.withConcurrency 25
# new health notifiying option:
.withHealth
  redis: 
    host: "host"
    port: 6739
    auth: "cadenaDeAuth"
    db: 2
  app: "la-aplicacion-que-esta-usando-sbnoti"
.build()
```
### To read from the dead letter subscription
``` Coffeescript
reader = new SbnotiBuilder()
.withServiceBus #required
  connectionString: "the azure connection string"
  topic: "the topic name"
  subscription: "the subscription name"
.fromDeadLetter()
.build()
```

### Also read from regular and dead letter at the same time!
``` Coffeescript
reader = new SbnotiBuilder()
.withServiceBus #required
  connectionString: "the azure connection string"
  topic: "the topic name"
  subscription: "the subscription name"
.activeFor
  pending: true #Read from regular subscription
  failed: true  #Read from dead letter
.build()
```

#### TIP: Use the booleans for pending and failed to control which readers are active

#### A nice function to transform strings 'true' and 'false' to actual the boolean value or a default:
``` Coffeescript
stringToBoolean: (value,_default) ->
  (value?.toLowerCase?() ? _default?.toString()) == 'true'
```

### To start the reader with a given process
``` Coffeescript
Promise = require("bluebird")
reader.run (message) =>
  # do something with message
  Promise.resolve "message processed ok"
  # or...
  Promise.reject "error processing the message"
```

### To make an http request for each message
``` Coffeescript
messageToOptions = (message) =>
  uri: "http://an.endpoint.com"
  body: message.data
  headers:
    authorization: "access token"

reader.runAndPost messageToOptions, ignoredStatusCodes: [409,503]
reader.runAndGet messageToOptions
reader.runAndPut messageToOptions
reader.runAndDelete messageToOptions
#or also
method = 'post',  #'get','delete','update'
reader.runAndRequest messageToOptions, method, ignoredStatusCodes: [409]

```

### Migrations

#### 4.x -> 5.x

##### Removed methods

* builder#withFilters

* builder#withLogging. You should use environment variable DEBUG=sbnoti:*

* builder#withReceiveBatchSize and builder#withWaitForMessageTime. Service bus SDK uses AMQP [azure-servicebus.receiver.registerMessageHandler](https://docs.microsoft.com/en-us/javascript/api/@azure/service-bus/receiver?view=azure-node-latest#registermessagehandler-onmessage--onerror--messagehandleroptions-)

