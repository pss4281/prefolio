# angular.module("prefolioApp.directives", []).directive "jcrop", ->
prefolioApp.directive "jcrop", ->
  restrict: 'A'
  # require: 'ngModel'
  # replace: true
  scope: { onChangeFn: '&' }
  # scope: { score: '=ngModel' }

  priority: 10
  link: (scope, element, attrs) ->
    # console.log 'fggg'
    onChange = (coords)->
      scope.$apply ->
        scope.onChangeFn(coords: coords)

    # scope.onChangeFn x: 5
    settings = {
      allowResize: false
      allowSelect: false
      onChange: onChange
    }

    
    angular.extend(settings, angular.fromJson(attrs.jcrop))

    element.on 'load', ->
      jQuery(element).Jcrop(settings)


