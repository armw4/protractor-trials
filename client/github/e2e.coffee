HttpBackend = require 'http-backend-proxy'

payload1 = require './armw4-github-payload-1.e2e.json'
payload2 = require './armw4-github-payload-2.e2e.json'

describe 'my test suite', ->
  $httpBackend = null

  beforeEach ->
    browser.get '/'

    $httpBackend = new HttpBackend(browser)

    $httpBackend.context =
      payload1: payload1
      payload2: payload2

    $httpBackend
      .whenGET 'https://api.github.com/users/armw4'
      .respond -> [200, $httpBackend.context.payload]

  describe 'payload 1', ->
    beforeEach -> $httpBackend.syncContext payload: payload1

  describe 'payload 1', ->
    beforeEach -> $httpBackend.syncContext payload: payload2
