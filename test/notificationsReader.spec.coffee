mockAzure = require("../test/helpers/mockedAzure")
ObserverStub =require("../test/helpers/observerStub")
{ Buffer } = require("buffer")

_ = require("lodash")
should = require("should")
require "should-sinon"

Promise = require("bluebird")
NotificationsReaderBuilder = require("../src/notificationsReader.builder")
nock = require("nock")
{ retryableMessage, redis, basicConfig, deadLetterConfig, getMessage } = require("../test/helpers/fixture")

deadLetterReader = (config = basicConfig) =>
  new NotificationsReaderBuilder()
  .withConfig config
  .fromDeadLetter()
  .build()._sbnotis[0]

reader = (config = basicConfig) =>
  new NotificationsReaderBuilder()
  .withConfig config
  .build()._sbnotis[0]

{ uri, observer, readerWithStubbedObserver, message } = {}

describe "NotificationsReader", ->

  beforeEach ->
    mockAzure.refreshSpies()
    uri = "http://un.endpoint.com"
    message = getMessage()

  describe "Reader", ->

    it "should have correct defaults", ->
      reader().config.should.eql
        subscription: "una-subscription"
        connectionString: "Endpoint=sb://hostname.servicebus.windows.net/;SharedAccessKeyName=sakName;SharedAccessKey=sak"
        topic: "un-topic"
        concurrency: 25,
        deadLetter: false,
        log: false,
        receiveBatchSize: 5,
        waitForMessageTime: 3000

    it "should build a message", ->
      aMessage = un: "mensaje"
      reader()._sanitizedBody Buffer.from JSON.stringify aMessage
      .should.eql aMessage

    it "should failed if message is not valid json", ->
      should.throws -> reader()._sanitizedBody Buffer.from "esto no un json"

    it "should delete message if it finishes ok", (done) ->
      assertAfterProcess done, {
        message
        process: Promise.resolve
        assertion: -> message.complete.should.be.calledOnce()
      }

    it "should unlock message if it finishes with errors when it isn't dead letter", (done) ->
      assertAfterProcess done, {
        message
        process: Promise.reject
        assertion: -> message.abandon.should.be.calledOnce()
      }

    it "should not unlock message if it finishes with errors when it is dead letter", (done)->
      assertAfterProcess done, {
        message
        process: Promise.reject
        assertion: -> message.abandon.should.be.not.called()
      }, deadLetterReader()

    describe "Observers", ->
      beforeEach ->
        observer = new ObserverStub()
        readerWithStubbedObserver = do ->
          new NotificationsReaderBuilder()
          .withConfig basicConfig
          .withObservers observer
          .build()._sbnotis[0]

      it "should notify success to observers on message success", (done)->
        assertAfterProcess done, {
          message
          process: Promise.resolve
          assertion: ->
            observer.success.calledOnce.should.be.true()
            observer.error.notCalled.should.be.true()
        }, readerWithStubbedObserver

      it "should notify error to observers on message error", (done)->
        assertAfterProcess done, {
          message
          process: Promise.reject
          assertion: ->
            observer.error.calledOnce.should.be.true()
            observer.success.notCalled.should.be.true()
        }, readerWithStubbedObserver

      describe "Run and request", ->
        beforeEach ->
          nock.disableNetConnect()
          nock.enableNetConnect('127.0.0.1')

        it "should make a post request", (done) ->
          shouldMakeRequest 'post', done

        it "should make a put request", (done) ->
          shouldMakeRequest 'put', done

        it "should fail if status code is >= 400 and not ignored", (done) ->
          assertion = ->
            observer.success.notCalled.should.be.true()
            observer.error.calledOnce.should.be.true()
          checkIfItFails readerWithStubbedObserver, {}, assertion, done

        it "should not fail if status code is >= 400 but ignored", (done) ->
          assertion = ->
            observer.error.notCalled.should.be.true()
            observer.success.calledOnce.should.be.true()
          checkIfItFails readerWithStubbedObserver, { ignoredStatusCodes: [400] }, assertion, done

        it "should not fail if status code is < 400", (done) ->
          assertion = ->
            observer.error.notCalled.should.be.true()
            observer.success.calledOnce.should.be.true()
          checkIfItFails readerWithStubbedObserver, {}, assertion, done, status: 200

assertRequest = (method, { status, body }, aReader, done, extraAssertion = (->), options = {}) ->
  nocked = nock uri
  scopeEndpoint =
    nocked[method] "/", { un: 'json', CompanyId: 123, ResourceId: 456 }
    .reply status, body

  assertAfterProcess done, {
    message
    process:
      aReader.http.process (aMessage) =>
        { uri, body: aMessage }
      , method, options
    assertion: ->
      scopeEndpoint.isDone().should.be.true()
      extraAssertion()
  }, aReader

checkIfItFails = (aReader, options, assertion, done, { status } = {}) ->
  assertRequest 'post', { status: status or 400, body: bad:'request' }, aReader, done, assertion, options

shouldMakeRequest = (method, done) ->
  aReader = reader()
  assertRequest method, { status:200, body: todo:'bien' }, aReader, done

assertAfterProcess = (done, { message, process, assertion }, aReader = reader()) ->
  aReader.onMessage(process) message
  .reflect()
  .then ->
    assertion()
    done()
