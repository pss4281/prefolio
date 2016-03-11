prefolioApp.controller('EditTemplateFormCtrl', ['$scope', '$timeout', ($scope, $timeout) ->

  $scope.point_names = [
    'Top left corner'
    'Top right corner'
    'Bottom right corner'
    'Bottom left corner'
  ]

  $scope.canvas     = document.getElementById('img_canvas')
  $scope.canvas_ctx = $scope.canvas.getContext('2d')
  $scope.imageObj   = undefined

  $scope.set_current_rule = (rule) ->
    $scope.current_rule = rule

  $scope.get_init_distortion_points = (rule, index)->
    [
      0,0,
      rule.destination_size_x, 0,
      rule.destination_size_x, rule.destination_size_y, 
      0, rule.destination_size_y
    ][index]

  $scope.redraw_canvas = ->
    console.log $scope.current_rule
    $scope.canvas.width = $scope.canvas.width # re-setting canvas
    return if !$scope.current_rule.composite_position_x || !$scope.current_rule.composite_position_y || !$scope.current_rule.destination_size_x || !$scope.current_rule.destination_size_y
    $timeout ->
      $scope.canvas_ctx.drawImage(
        $scope.imageObj,
        $scope.current_rule.composite_position_x,
        $scope.current_rule.composite_position_y,
        $scope.current_rule.destination_size_x,
        $scope.current_rule.destination_size_y,
        0,
        0,
        $scope.current_rule.destination_size_x,
        $scope.current_rule.destination_size_y
      )

      $scope.canvas_ctx.beginPath()
      $scope.canvas_ctx.moveTo($scope.current_rule.destination_points[2], $scope.current_rule.destination_points[3])
      $scope.canvas_ctx.lineTo($scope.current_rule.destination_points[6], $scope.current_rule.destination_points[7])
      $scope.canvas_ctx.lineTo($scope.current_rule.destination_points[10], $scope.current_rule.destination_points[11])
      $scope.canvas_ctx.lineTo($scope.current_rule.destination_points[14], $scope.current_rule.destination_points[15])
    
      $scope.canvas_ctx.closePath()
      $scope.canvas_ctx.strokeStyle = '#ff0000'
      $scope.canvas_ctx.stroke()

  $scope.select_rule = (rule)->
    $scope.current_rule = rule
    $scope.redraw_canvas()

  $scope.add_embed_rule = ->
    $scope.template.embed_rules.push { destination_points: [], composite_position_x: 10, composite_position_y: 10, destination_size_x: 50, destination_size_y: 50 }

  $scope.remove_rule = (rule)->
    if !!rule.id
      rule.deleted = true
    else
      $scope.template.embed_rules.splice(index, 1) if (index = $scope.template.embed_rules.indexOf(rule)) > -1

  $scope.init = (template) ->
    $scope.imageObj = new Image()
    $scope.imageObj.src = template.image.url

    $scope.template = template
    $scope.current_rule = template.embed_rules[0]
    
    $timeout ->
      $scope.redraw_canvas()


])
