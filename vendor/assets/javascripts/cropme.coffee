(->
  angular.module("cropme", ["ngSanitize", "ngTouch", "superswipe"]).service "elementOffset", ->
    (el) ->
      el = el[0]  if el[0]
      offsetTop  = 0
      offsetLeft = 0
      while el
        offsetTop += el.offsetTop
        offsetLeft += el.offsetLeft
        el = el.offsetParent
      top: offsetTop
      left: offsetLeft

  angular.module("cropme").directive "cropme", ($swipe, $window, $timeout, $rootScope, elementOffset) ->
    borderSensitivity = undefined
    minHeight = undefined
    minHeight = 100
    borderSensitivity = 8
    template: "<div\n\tclass=\"step-1\"\n\tng-show=\"state == 'step-1'\"\n\tng-style=\"{'width': width + 'px', 'height': height + 'px'}\">\n\t<dropbox ng-class=\"dropClass\"></dropbox>\n\t<div class=\"cropme-error\" ng-bind-html=\"dropError\"></div>\n\t<div class=\"cropme-file-input\">\n\t\t<input type=\"file\"/>\n\t\t<div\n\t\t\tclass=\"cropme-button\"\n\t\t\tng-class=\"{deactivated: dragOver}\"\n\t\t\tng-click=\"browseFiles()\">\n\t\t\t\tBrowse picture\n\t\t</div>\n\t\t<div class=\"cropme-or\">or</div>\n\t\t<div class=\"cropme-label\" ng-class=\"iconClass\">{{dropText}}</div>\n\t</div>\n</div>\n<div\n\tclass=\"step-2\"\n\tng-show=\"state == 'step-2'\"\n\tng-style=\"{'width': width + 'px'}\"\n\tng-mousemove=\"mousemove($event)\"\n\tng-mouseleave=\"deselect()\"\n\tng-class=\"{'col-resize': colResizePointer}\">\n\t<img ng-src=\"{{imgSrc}}\" ng-style=\"{'width': width + 'px'}\"/>\n\t<div class=\"overlay-tile\" ng-style=\"{'top': 0, 'left': 0, 'width': xCropZone + 'px', 'height': yCropZone + 'px'}\"></div>\n\t<div class=\"overlay-tile\" ng-style=\"{'top': 0, 'left': xCropZone + 'px', 'width': widthCropZone + 'px', 'height': yCropZone + 'px'}\"></div>\n\t<div class=\"overlay-tile\" ng-style=\"{'top': 0, 'left': xCropZone + widthCropZone + 'px', 'right': 0, 'height': yCropZone + 'px'}\"></div>\n\t<div class=\"overlay-tile\" ng-style=\"{'top': yCropZone + 'px', 'left': xCropZone + widthCropZone + 'px', 'right': 0, 'height': heightCropZone + 'px'}\"></div>\n\t<div class=\"overlay-tile\" ng-style=\"{'top': yCropZone + heightCropZone + 'px', 'left': xCropZone + widthCropZone + 'px', 'right': 0, 'bottom': 0}\"></div>\n\t<div class=\"overlay-tile\" ng-style=\"{'top': yCropZone + heightCropZone + 'px', 'left': xCropZone + 'px', 'width': widthCropZone + 'px', 'bottom': 0}\"></div>\n\t<div class=\"overlay-tile\" ng-style=\"{'top': yCropZone + heightCropZone + 'px', 'left': 0, 'width': xCropZone + 'px', 'bottom': 0}\"></div>\n\t<div class=\"overlay-tile\" ng-style=\"{'top': yCropZone + 'px', 'left': 0, 'width': xCropZone + 'px', 'height': heightCropZone + 'px'}\"></div>\n\t<div class=\"overlay-border\" ng-style=\"{'top': (yCropZone - 2) + 'px', 'left': (xCropZone - 2) + 'px', 'width': widthCropZone + 'px', 'height': heightCropZone + 'px'}\"></div>\n</div>\n<div class=\"cropme-actions\" ng-show=\"state == 'step-2'\">\n\t<button id=\"cropme-cancel\" ng-click=\"cancel($event)\">Cancel</button>\n\t<button id=\"cropme-ok\" ng-click=\"ok($event)\">Ok</button>\n</div>\n<canvas\n\twidth=\"{{destinationWidth}}\"\n\theight=\"{{destinationHeight}}\"\n\tng-style=\"{'width': destinationWidth + 'px', 'height': destinationHeight + 'px'}\">\n</canvas>"
    restrict: "E"
    scope:
      width: "=?"
      destinationWidth: "="
      height: "=?"
      destinationHeight: "=?"
      iconClass: "=?"
      ratio: "=?"
      type: "=?"

    link: (scope, element, attributes) ->
      scope.dropText  = "Drop picture here"
      scope.state     = "step-1"
      draggingFn      = null
      grabbedBorder   = null
      heightWithImage = null
      zoom            = null
      elOffset        = null
      imageEl         = element.find("img")[0]
      canvasEl        = element.find("canvas")[0]
      ctx             = canvasEl.getContext("2d")
      startCropping = (imageWidth, imageHeight) ->
        zoom = scope.width / imageWidth
        heightWithImage = imageHeight * zoom
        scope.widthCropZone = Math.round(scope.destinationWidth * zoom)
        scope.heightCropZone = Math.round((scope.destinationHeight or minHeight) * zoom)
        scope.xCropZone = Math.round((scope.width - scope.widthCropZone) / 2)
        scope.yCropZone = Math.round((scope.height - scope.heightCropZone) / 2)
        $timeout ->
          elOffset = elementOffset(imageAreaEl)


      checkScopeVariables = ->
        unless scope.width
          scope.width = element[0].offsetWidth
          scope.height = element[0].offsetHeight  unless scope.ratio or scope.height
        if scope.destinationHeight
          if scope.ratio
            throw "You can't specify both destinationHeight and ratio, destinationHeight = destinationWidth * ratio"
          else
            scope.ratio = scope.destinationHeight / scope.destinationWidth
        else scope.destinationHeight = scope.destinationWidth * scope.ratio  if scope.ratio
        throw "Can't initialize cropme: destinationWidth x ratio needs to be lower than height"  if scope.ratio and scope.height and scope.destinationHeight > scope.height
        throw "Can't initialize cropme: destinationWidth needs to be lower than width"  if scope.destinationWidth > scope.width
        scope.height = scope.width * scope.ratio  if scope.ratio and not scope.height
        scope.type or (scope.type = "png")

      imageAreaEl = element[0].getElementsByClassName("step-2")[0]
      checkScopeVariables()
      $input = element.find("input")
      $input.bind "change", ->
        file = undefined
        file = @files[0]
        scope.$apply ->
          scope.setFiles file


      $input.bind "click", (e) ->
        e.stopPropagation()
        $input.val ""

      scope.browseFiles = ->
        $input[0].click()

      scope.setFiles = (file) ->
        reader = undefined
        return scope.dropError = "Wrong file type, please select an image."  unless file.type.match(/^image\//)
        scope.dropError = ""
        reader = new FileReader
        reader.onload = (e) ->
          imageEl.onload = ->
            errors = undefined
            height = undefined
            width = undefined
            width = imageEl.naturalWidth
            height = imageEl.naturalHeight
            errors = []
            errors.push "The image you dropped has a width of " + width + ", but the minimum is " + scope.width + "."  if width < scope.width
            errors.push "The image you dropped has a height of " + height + ", but the minimum is " + scope.height + "."  if scope.height and height < scope.height
            errors.push "The image you dropped has a height of " + height + ", but the minimum is " + scope.destinationHeight + "."  if scope.ratio and scope.destinationHeight > height
            scope.$apply ->
              if errors.length
                scope.dropError = errors.join("<br/>")
              else
                $rootScope.$broadcast "cropme:loaded", width, height
                scope.state = "step-2"
                startCropping width, height


          scope.$apply ->
            scope.imgSrc = e.target.result


        reader.readAsDataURL file

      moveCropZone = (coords) ->
        scope.xCropZone = coords.x - elOffset.left - scope.widthCropZone / 2
        scope.yCropZone = coords.y - elOffset.top - scope.heightCropZone / 2
        checkBounds()

      moveBorders =
        top: (coords) ->
          y = undefined
          y = coords.y - elOffset.top
          scope.heightCropZone += scope.yCropZone - y
          scope.yCropZone = y
          checkVRatio()
          checkBounds()

        right: (coords) ->
          x = undefined
          x = coords.x - elOffset.left
          scope.widthCropZone = x - scope.xCropZone
          checkHRatio()
          checkBounds()

        bottom: (coords) ->
          y = undefined
          y = coords.y - elOffset.top
          scope.heightCropZone = y - scope.yCropZone
          checkVRatio()
          checkBounds()

        left: (coords) ->
          x = undefined
          x = coords.x - elOffset.left
          scope.widthCropZone += scope.xCropZone - x
          scope.xCropZone = x
          checkHRatio()
          checkBounds()

      checkHRatio = ->
        scope.heightCropZone = scope.widthCropZone * scope.ratio  if scope.ratio

      checkVRatio = ->
        scope.widthCropZone = scope.heightCropZone / scope.ratio  if scope.ratio

      checkBounds = ->
        scope.xCropZone = 0  if scope.xCropZone < 0
        scope.yCropZone = 0  if scope.yCropZone < 0
        if scope.widthCropZone < scope.destinationWidth * zoom
          scope.widthCropZone = scope.destinationWidth * zoom
          checkHRatio()
        else if scope.destinationHeight and scope.heightCropZone < scope.destinationHeight * zoom
          scope.heightCropZone = scope.destinationHeight * zoom
          checkVRatio()
        if scope.xCropZone + scope.widthCropZone > scope.width
          scope.xCropZone = scope.width - scope.widthCropZone
          if scope.xCropZone < 0
            scope.widthCropZone = scope.width
            scope.xCropZone = 0
            checkHRatio()
        if scope.yCropZone + scope.heightCropZone > heightWithImage
          scope.yCropZone = heightWithImage - scope.heightCropZone
          if scope.yCropZone < 0
            scope.heightCropZone = heightWithImage
            scope.yCropZone = 0
            checkVRatio()

      isNearBorders = (coords) ->
        x = scope.xCropZone + elOffset.left
        y = scope.yCropZone + elOffset.top
        w = scope.widthCropZone
        h = scope.heightCropZone
        topLeft     = { x: x, y: y }
        topRight    = { x: x + w, y: y }
        bottomLeft  = { x: x, y: y + h }
        bottomRight = { x: x + w, y: y + h }

        nearHSegment(coords, x, w, y, "top") or nearVSegment(coords, y, h, x + w, "right") or nearHSegment(coords, x, w, y + h, "bottom") or nearVSegment(coords, y, h, x, "left")

      nearHSegment = (coords, x, w, y, borderName) ->
        borderName  if coords.x >= x and coords.x <= x + w and Math.abs(coords.y - y) <= borderSensitivity

      nearVSegment = (coords, y, h, x, borderName) ->
        borderName  if coords.y >= y and coords.y <= y + h and Math.abs(coords.x - x) <= borderSensitivity

      dragIt = (coords) ->
        if draggingFn
          scope.$apply ->
            draggingFn coords


      scope.mousemove = (e) ->
        scope.colResizePointer = isNearBorders(
          x: e.pageX
          y: e.pageY
        )

      $swipe.bind angular.element(element[0].getElementsByClassName("step-2")[0]),
        start: (coords) ->
          grabbedBorder = isNearBorders(coords)
          if grabbedBorder
            draggingFn = moveBorders[grabbedBorder]
          else
            draggingFn = moveCropZone
          dragIt coords

        move: (coords) ->
          dragIt coords

        end: (coords) ->
          dragIt coords
          draggingFn = null

      scope.deselect = ->
        draggingFn = null

      scope.cancel = ($event) ->
        $event.preventDefault()  if $event
        scope.dropText = "Drop files here"
        scope.dropClass = ""
        scope.state = "step-1"

      scope.ok = ($event) ->
        $event.preventDefault()  if $event
        scope.croppedWidth = scope.widthCropZone / zoom
        scope.croppedHeight = scope.heightCropZone / zoom
        $timeout ->
          destinationHeight = undefined
          destinationHeight = scope.destinationHeight or scope.destinationWidth * scope.croppedHeight / scope.croppedWidth
          ctx.drawImage imageEl, scope.xCropZone / zoom, scope.yCropZone / zoom, scope.croppedWidth, scope.croppedHeight, 0, 0, scope.destinationWidth, scope.destinationHeight
          canvasEl.toBlob ((blob) ->
            $rootScope.$broadcast "cropme:done", blob
          ), "image/" + scope.type


      scope.$on "cropme:cancel", scope.cancel
      scope.$on "cropme:ok", scope.ok

  angular.module("cropme").directive "dropbox", (elementOffset) ->
    restrict: "E"
    link: (scope, element, attributes) ->
      offset = elementOffset(element)
      reset = (evt) ->
        evt.stopPropagation()
        evt.preventDefault()
        scope.$apply ->
          scope.dragOver  = false
          scope.dropText  = "Drop files here"
          scope.dropClass = ""


      dragEnterLeave = (evt) ->
        return  if evt.x > offset.left and evt.x < offset.left + element[0].offsetWidth and evt.y > offset.top and evt.y < offset.top + element[0].offsetHeight
        reset evt

      dropbox = element[0]
      scope.dropText = "Drop files here"
      scope.dragOver = false
      dropbox.addEventListener "dragenter", dragEnterLeave, false
      dropbox.addEventListener "dragleave", dragEnterLeave, false
      dropbox.addEventListener "dragover", ((evt) ->
        ok = undefined
        evt.stopPropagation()
        evt.preventDefault()
        ok = evt.dataTransfer and evt.dataTransfer.types and evt.dataTransfer.types.indexOf("Files") >= 0
        scope.$apply ->
          scope.dragOver = true
          scope.dropText = ((if ok then "Drop now" else "Only files are allowed"))
          scope.dropClass = ((if ok then "over" else "not-available"))

      ), false
      dropbox.addEventListener "drop", ((evt) ->
        files = undefined
        reset evt
        files = evt.dataTransfer.files
        scope.$apply ->
          file = undefined
          _i = undefined
          _len = undefined
          if files.length > 0
            _i = 0
            _len = files.length

            while _i < _len
              file = files[_i]
              if file.type.match(/^image\//)
                scope.dropText = "Loading image..."
                scope.dropClass = "loading"
                return scope.setFiles(file)
              scope.dropError = "Wrong file type, please drop at least an image."
              _i++
          return

      ), false

  ((view) ->
    "use strict"
    base64_ranks      = undefined
    Uint8Array        = view.Uint8Array
    HTMLCanvasElement = view.HTMLCanvasElement
    is_base64_regex   = /\s*;\s*base64\s*(?:;|$)/i
    decode_base64 = (base64) ->
      buffer = undefined
      code   = undefined
      i      = undefined
      last   = undefined
      len    = undefined
      outptr = undefined
      rank   = undefined
      undef  = undefined
      len    = base64.length
      buffer = new Uint8Array(len / 4 * 3 | 0)
      i      = 0
      outptr = 0
      last   = [0, 0]
      state  = 0
      save   = 0
      while len--
        code = base64.charCodeAt(i++)
        rank = base64_ranks[code - 43]
        if rank isnt 255 and rank isnt undef
          last[1] = last[0]
          last[0] = code
          save = (save << 6) | rank
          state++
          if state is 4
            buffer[outptr++] = save >>> 16
            buffer[outptr++] = save >>> 8  if last[1] isnt 61
            buffer[outptr++] = save  if last[0] isnt 61
            state = 0
      buffer

    if Uint8Array
      base64_ranks = new Uint8Array([
        62, -1, -1, -1, 63, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, -1, -1, -1, 0, -1, -1, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
        11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, -1, -1, -1, -1, -1, -1, 26, 27, 28, 29, 30, 31, 32, 33, 34,
        35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51
      ])
    if HTMLCanvasElement and not HTMLCanvasElement::toBlob
      HTMLCanvasElement::toBlob = (callback, type) ->
        blob = undefined
        type = "image/png"  unless type
        if @mozGetAsFile
          callback @mozGetAsFile("canvas", type)
          return
        args       = Array::slice.call(arguments, 1)
        dataURI    = @toDataURL.apply(this, args)
        header_end = dataURI.indexOf(",")
        data       = dataURI.substring(header_end + 1)
        is_base64  = is_base64_regex.test(dataURI.substring(0, header_end))
        if Blob.fake
          blob = new Blob
          if is_base64
            blob.encoding = "base64"
          else
            blob.encoding = "URI"
          blob.data = data
          blob.size = data.length
        else if Uint8Array
          if is_base64
            blob = new Blob([decode_base64(data)], { type: type })
          else
            blob = new Blob([decodeURIComponent(data)], { type: type })
        callback blob
  ) self
  return
).call this