prefolioApp = angular.module('prefolioApp', [
  'angularFileUpload'
  'ui.select2'
  'prefolioApp.directives'
  ]).config ['$httpProvider', ($httpProvider) ->
  #  using csrf tokens for angular requests:
  $httpProvider.defaults.headers.common['X-CSRF-Token'] = $('meta[name=csrf-token]').attr('content')
  $httpProvider.defaults.headers.common['X-Requested-With'] = "XMLHttpRequest"
]

prefolioApp.directive 'eatClick', () ->
  (scope, element, attrs) ->
    $(element).click (event) ->
      event.preventDefault()

window.prefolioApp = prefolioApp