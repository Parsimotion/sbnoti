Promise = require("bluebird")
redis = require("redis")
Promise.promisifyAll redis.RedisClient.prototype
Promise.promisifyAll redis.Multi.prototype
module.exports = redis
