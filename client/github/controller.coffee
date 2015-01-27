angular
.module 'controller.github', []
.controller 'GitHubCtrl', ($scope, github) ->
  $scope.errors = []
  $scope.hasErrors = -> $scope.errors.length

  github()
  .success (data) -> $scope.model = data
  .error (data, status, headers, config) -> $scope.errors.push data
