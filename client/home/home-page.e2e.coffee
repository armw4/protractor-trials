class HomePage
  initialize: ->
    avatarUrlSelector = By.css '.field-avatar-url .field-value'

    @_avatarUrl = element avatarUrlSelector

    @

  load: ->
    browser.get '/'

    @

  avatarUrl: -> @_avatarUrl.getText()

module.exports = HomePage
