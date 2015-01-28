HttpBackend = require 'http-backend-proxy'

payload1 = require './armw4-github-payload-1.e2e.json'
payload2 = require './armw4-github-payload-2.e2e.json'

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
      githubApiMock.configure payload1
      homePage.load().initialize()

    it 'should render data to the UI based on the results of the first payload', ->
      avatarUrl = homePage.avatarUrl()

      expect(avatarUrl).toEqual 'https://gravatar.com'

  describe 'payload 2', ->
    beforeEach ->
      githubApiMock.configure payload2
      homePage.load().initialize()

    it 'should render data to the UI based on the results of the second payload', ->
      avatarUrl = homePage.avatarUrl()

      expect(avatarUrl).toEqual 'https://consoco.com'

