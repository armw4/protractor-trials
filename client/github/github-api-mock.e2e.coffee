class GitHubApiMock
  constructor: (proxy) -> @proxy = proxy

  configure: (responsePayload, responseStatusCode = 200) ->
    @proxy.context = payload: responsePayload, status: responseStatusCode

    @proxy
    .onLoad
    .whenGET 'https://api.github.com/users/armw4'
    .respond -> [$httpBackend.context.status, $httpBackend.context.payload]

    @

module.exports = GitHubApiMock
