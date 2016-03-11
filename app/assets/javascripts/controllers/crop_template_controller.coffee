prefolioApp.controller('CropTemplateCtrl', ['$scope', '$http', ($scope, $http) ->

  $scope.jcropSettings = {
    aspectRatio: 1.25
    setSelect: [ 100, 100, 50, 50 ]
  }

  $scope.updateCoordinates = (coords)->
    $scope.coords = coords

])