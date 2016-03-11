prefolioApp.controller('ShowTemplateCtrl', ['$scope', '$http', '$upload', ($scope, $http, $upload) ->
  $scope.selected_image_number = 1

  $scope.positionForDropzone = (rule)->
    left: "#{ parseInt(rule.composite_position_x / $scope.template.original_width * 100) }%"
    top: "#{ parseInt(rule.composite_position_y / $scope.template.original_height * 100) }%"

  # <===== PHOTO UPLOAD LOGIC:
  $scope.image_url          = undefined
  $scope.is_uploading_photo = false
  $scope.photo_errors       = null
  $scope.template_id        = undefined
  $scope.processed_image    = undefined

  $scope.init = (template)->
    $scope.image_url = template.image.with_placeholder.url
    $scope.template = template


  $scope.onFileSelect = ($files, rule_id) ->
    file = $files[0]
    # console.log rule_id
    method = 'POST'
    url = Routes.template_processed_images_path
      template_id: $scope.template.id
      rule_id: rule_id
      processed_image_id: "#{ if $scope.processed_image? then $scope.processed_image.id else '' }"

    if file?
      $scope.is_uploading_photo = true
      $scope.upload = $upload.upload
        url: url
        file: file
        method: 'POST'
      .progress (evt)->
        $scope.uploaded_percents = parseInt(100.0 * evt.loaded / evt.total)
      .success (data, status, headers, config) ->
        $scope.processed_image = data
        $scope.photo_errors = null
        $scope.image_url    = "#{ data.image.url }?#{ new Date().getTime() }"
        $scope.is_uploading_photo = false
      .error (data) ->
        $scope.photo_errors       = data.errors
        $scope.is_uploading_photo = false


  $(document).bind "dragover", (e) ->
    dropZone = $(".dropzone")
    foundDropzone = undefined
    timeout = window.dropZoneTimeout
    if !timeout then dropZone.addClass("in") else clearTimeout(timeout)
    found = false
    node  = e.target
    loop
      if $(node).hasClass("dropzone")
        found = true
        foundDropzone = $(node)
        break
      node = node.parentNode
      break unless node?
    dropZone.removeClass "in hover"
    foundDropzone.addClass "hover"  if found
    window.dropZoneTimeout = setTimeout(->
      window.dropZoneTimeout = null
      dropZone.removeClass "in hover"
      return
    , 100)

])