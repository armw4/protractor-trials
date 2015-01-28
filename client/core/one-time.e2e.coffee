module.exports = (fn) ->
  count = 0

  ->
    return unless count is 0

    ++count

    fn()
