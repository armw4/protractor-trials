gravatarResponse = require './armw4-gravatar-response.e2e.json'
consocoResponse  = require './armw4-consoco-response.e2e.json'

class GitHubApiMock
  constructor: (proxy) -> @proxy = proxy

  configureGravatarResponse: -> configure.call @, gravatarResponse

  configureConsocoResponse: -> configure.call @, consocoResponse

  configureErrorResponse: -> configure.call @, null, 500

  configure = (responsePayload, responseStatusCode = 200) ->
    @proxy.context = payload: responsePayload, status: responseStatusCode

    @proxy
    .onLoad
    .whenGET 'https://api.github.com/users/armw4'
    .respond -> [$httpBackend.context.status, $httpBackend.context.payload]

module.exports = GitHubApiMock
