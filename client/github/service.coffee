angular
.module 'service.github', []
.factory 'github', ($http) ->
  # hey, lets return my github profile info just for kicks, yea?
  -> $http.get 'https://api.github.com/users/armw4'
