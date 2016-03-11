page = require('webpage').create()
system = require 'system'
if system.args.length isnt 4
  console.log 'Usage: $> raphaeljs rasterize.coffee URL filename 1024x768'
  phantom.exit 1
else
  address = system.args[1]
  output  = system.args[2]
  viewportWidth  = parseInt(system.args[3].split('x')[0])
  viewportHeight = parseInt(system.args[3].split('x')[1])
  # console.log viewportHeight
  # console.log viewportWidth
  page.viewportSize = { width: viewportWidth, height: viewportHeight }

  page.open address, (status) ->
    if status isnt 'success'
      console.log 'Unable to load the address!'
      phantom.exit(1)
    else
      page.evaluate (w, h) ->
        console.log document.getElementById("width")
        # console.log viewportWidth
        document.getElementById("width").innerText = w
        document.getElementById("height").innerText = h
        true
      , viewportWidth, viewportHeight
      window.setTimeout (-> page.render output; phantom.exit()), 200
