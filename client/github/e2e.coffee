HttpBackend   = require 'http-backend-proxy'
HomePage      = require '../home/home-page.e2e'
GitHubApiMock = require './mock.e2e'

describe 'github', ->
  homePage = proxy = githubApiMock = null

  beforeEach ->
    proxy         = new HttpBackend(browser)
    githubApiMock = new GitHubApiMock(proxy)
    homePage      = new HomePage()

  afterEach -> proxy.onLoad.reset()

  describe 'gravatar response', ->
    beforeEach ->
      githubApiMock.configureGravatarResponse()
      homePage.load()

    it 'should render data to the UI based on the results of the gravatar response', ->
      avatarUrl = homePage.avatarUrl()

      expect(avatarUrl).toEqual 'https://gravatar.com'

  describe 'consoco response', ->
    beforeEach ->
      githubApiMock.configureConsocoResponse()
      homePage.load()

    it 'should render data to the UI based on the results of the consoco response', ->
      avatarUrl = homePage.avatarUrl()

      expect(avatarUrl).toEqual 'https://consoco.com'

  describe 'error response', ->
    beforeEach ->
      githubApiMock.configureErrorResponse()
      homePage.load()

    it 'should show an error message', ->
      errorMessage = homePage.errorMessage()

      expect(errorMessage).toEqual 'Error processing request for @armw4...'
