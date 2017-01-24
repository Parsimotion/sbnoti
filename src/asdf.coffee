NotificationsReader = require("./notificationsReader");

reader = new NotificationsReader
  connectionString: "Endpoint=sb://producteca.servicebus.windows.net/;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=euLNZQTHaw81dzv29Z+paA4GAlbf+5LfduwY5c9ULGs="
  topic: "product"
  subscription: "meli-product-template"

reader.getMaxDeliveryCount()
