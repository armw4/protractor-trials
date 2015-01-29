class HomePage
  load: ->
    browser.get '/'

  avatarUrl: ->
    @_avatarUrl ?= element By.css('.field-avatar-url .field-value')

    @_avatarUrl.getText()

  errorMessage: ->
    @_errorMessage ?= element By.css('#github-profile-errors p')

    @_errorMessage.getText()

module.exports = HomePage
