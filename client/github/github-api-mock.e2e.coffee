payload1 = require './armw4-github-payload-1.e2e.json'
payload2 = require './armw4-github-payload-2.e2e.json'

class GitHubApiMock
  constructor: (proxy) -> @proxy = proxy

  configurePayload1: -> configure.call @, payload1

  configurePayload2: -> configure.call @, payload2

  configure = (responsePayload, responseStatusCode = 200) ->
    @proxy.context = payload: responsePayload, status: responseStatusCode

    @proxy
    .onLoad
    .whenGET 'https://api.github.com/users/armw4'
    .respond -> [$httpBackend.context.status, $httpBackend.context.payload]

module.exports = GitHubApiMock
