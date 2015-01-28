HttpBackend   = require 'http-backend-proxy'
HomePage      = require '../home/home-page.e2e'
GitHubApiMock = require './github-api-mock.e2e'

describe 'my test suite', ->
  homePage = proxy = githubApiMock = null

  beforeEach ->
    proxy         = new HttpBackend(browser)
    githubApiMock = new GitHubApiMock(proxy)
    homePage      = new HomePage()

  afterEach -> proxy.onLoad.reset()

  describe 'payload 1', ->
    beforeEach ->
      githubApiMock.configurePayload1()
      homePage.load().initialize()

    it 'should render data to the UI based on the results of the first payload', ->
      avatarUrl = homePage.avatarUrl()

      expect(avatarUrl).toEqual 'https://gravatar.com'

  describe 'payload 2', ->
    beforeEach ->
      githubApiMock.configurePayload2()
      homePage.load().initialize()

    it 'should render data to the UI based on the results of the second payload', ->
      avatarUrl = homePage.avatarUrl()

      expect(avatarUrl).toEqual 'https://consoco.com'

