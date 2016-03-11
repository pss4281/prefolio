angular.module("prefolioApp.directives", []).directive("ngUploadForm", ["$rootScope", "fileUpload", ->
  restrict: "E"
  templateUrl: "/templates/fileform.html"
  scope:
    allowed: "@"
    url: "@"
    autoUpload: "@"
    sizeLimit: "@"
    ngModel: "="
    name: "@"

  controller: ($rootScope, $scope, $element, fileUpload) ->
    # console.log fileUpload
    $scope.$on "fileuploaddone", (e, data) ->
      console.log data
      fileUpload.addFieldData $scope.name, data._response.result.files[0].result

    $scope.options =
      url: $scope.url
      dropZone: $element
      maxFileSize: $scope.sizeLimit
      autoUpload: $scope.autoUpload

    $scope.loadingFiles = false
    $scope.queue = []  unless $scope.queue
    generateFileObject = generateFileObjects = (objects) ->
      # console.log objects
      angular.forEach objects, (value, key) ->
        fileObject =
          name: value.filename
          size: value.length
          url: value.url
          thumbnailUrl: value.url
          deleteUrl: value.url
          deleteType: "DELETE"
          result: value

        fileObject.url = "/" + fileObject.url  if fileObject.url and fileObject.url.charAt(0) isnt "/"
        fileObject.deleteUrl = "/" + fileObject.deleteUrl  if fileObject.deleteUrl and fileObject.deleteUrl.charAt(0) isnt "/"
        fileObject.thumbnailUrl = "/" + fileObject.thumbnailUrl  if fileObject.thumbnailUrl and fileObject.thumbnailUrl.charAt(0) isnt "/"
        $scope.queue[key] = fileObject
        return

    fileUpload.registerField $scope.name
    $scope.filequeue = fileUpload.fieldData[$scope.name]
    # console.log fileUpload
    $scope.$watchCollection "filequeue", (newval) ->
      generateFileObject newval

])
.controller "FileDestroyController", [
  "$rootScope"
  "$scope"
  "$http"
  "fileUpload"
  ($rootScope, $scope, $http, fileUpload) ->
    file = $scope.file
    state = undefined
    $scope.fieldname = $scope.$parent.$parent.$parent.name  if $scope.$parent and $scope.$parent.$parent and $scope.$parent.$parent.$parent.name
    fileUpload.fieldData[$scope.name] = []  unless fileUpload.fieldData[$scope.name]
    $scope.filequeue = fileUpload.fieldData
    if file.url
      file.$state = ->
        state

      file.$destroy = ->
        state = "pending"
        $http(
          url: file.deleteUrl
          method: file.deleteType
        ).then (->
          state = "resolved"
          fileUpload.removeFieldData $scope.fieldname, file.result._id
          $scope.clear file
          return
        ), ->
          state = "rejected"
          fileUpload.removeFieldData $scope.fieldname, file.result._id
          $scope.clear file
          return

    else if not file.$cancel and not file._index
      file.$cancel = ->
        $scope.clear file
        return
]
