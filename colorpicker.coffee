$.fn.colorPicker = (action = "init", param)->
  switch action
    when "init"
      @.each ()->
        data = $(@).data "colorpicker"
        $(@).data 'colorpicker', new ColorPicker @, param
    else
      @.eq(0).data("colorpicker")[action](param)

class ColorPicker
  picker_code = "<div class='picker'><div class='map'><div class='pointer'></div></div><div class='column value'><div class='selector'></div></div><div class='column op-wrapper'><div class='op-column'><div class='selector'></div></div></div></div>"

  input: null
  el: null
  map: null
  pointer: null
  col: null
  op_wrapper: null
  sel: null
  hsv:
    h: 0
    s: 1
    v: 1
  rgb:
    r: 255
    g: 0
    b: 0
  opacity: 1
  hex: "#FF0000"
  position: "bottom"

  constructor: (input, param)->
    if !input
      console.log "ERROR: Empty first param"

    @el = $ picker_code
    @map = @el.find ".map"
    @pointer = @map.find ".pointer"
    @col = @el.find ".column.value"
    @sel = @col.find ".selector"
    @op_wrapper = @el.find ".column.op-wrapper"
    @op_col = @op_wrapper.find ".op-column"
    @op_sel = @op_col.find ".selector"
    @col.css
      "background": "-webkit-linear-gradient(top, rgba(255, 255, 255, 0), #ffffff)"
      "background-image": "linear-gradient(to bottom, rgba(255, 255, 255, 0), #ffffff)"

    @_recalculateColor()
    @_updateControls()

    @el.click (e)->
      e.stopPropagation()
    @map.on
      mousedown: @_pointerStartmove
    @col.on
      mousedown: @_selectorStartmove
    if param?.opacity is 1
      @op_col.on
        mousedown: @_opselectorStartmove
    else
      @el.addClass "disable-opacity"

    if param?.position
      @position = param.position

    @_bind input

  _bind: (input)=>
    if input && !$(input).next().hasClass "picker"
      @input = $ input
      @input.after @el
      @input.attr 'maxlength', 7
      @input.on
        click: @_showHide
        focus: @_showHide
        input: @_parseColor
      $(document).click ()=>
        @el.hide()
      true
    else false

  _parseColor: (e)=>
    val = @input.val()
    color = val.replace /[^A-Fa-f0-9]/g, ""
    if val[0] isnt '#' || val.length - 1 != color.length
      pos = @input[0].selectionStart;
      @input.val '#' + color
      if pos != val.length
        @input[0].selectionStart = pos - 1
        @input[0].selectionEnd = pos - 1

    rgbarr = []
    if color.length is 0
      color = "FFFFFF"
    if color.length is 3
      color = color[0] + color[0] + color[1] + color[1] + color[2] + color[2]
    else
      while color.length < 6
        color += color[color.length - 1]
    while color.length >= 2
      rgbarr.push parseInt color.substring(0, 2), 16
      color = color.substring 2, color.length
    @rgb =
      r: rgbarr[0]
      g: rgbarr[1]
      b: rgbarr[2]
    @hsv = @cnv.rgbtohsv @rgb
    @hex = @cnv.rgbtohex @rgb
    @_updateControls()



  _showHide: (e)=>
    e.stopPropagation()
    if @el.is ":visible"
      return
    $(".picker").not(@el).each ()->
      $(@).hide()
    position = @input.position()

    switch @position
      when "top"
        @el.css "top", position.top - @el.outerHeight true
        @el.css "left", position.left + parseInt(@input.css("margin-left"), 10)
      when "bottom"
        @el.css "top", position.top + @input.outerHeight true
        @el.css "left", position.left + parseInt(@input.css("margin-left"), 10)
    @el.toggle()

  _bindFocus: ()->
    $("body").addClass "unselectable"
    @input.blur()

  _unbindFocus: ()->
    $("body").removeClass "unselectable"
    @input.focus()

  #MAP
  _pointerStartmove: (e)=>
    $(document).on
      mouseover: @_pointerMove
      mousemove: @_pointerMove
      mouseup: @_pointerStopmove
    @_bindFocus()
    @_pointerMove e

  _pointerStopmove: (e)=>
    @_pointerMove e
    @_unbindFocus()
    $(document).off
      mouseover: @_pointerMove
      mousemove: @_pointerMove
      mouseup: @_pointerStopmove

  _pointerMove: (e)=>
    e.stopPropagation()
    e.preventDefault()
    offset = @map.offset()
    maxW = @map.width()
    maxH = @map.height()
    x = (e.clientX - offset.left) * 100 / maxW
    y = (e.clientY - offset.top) * 100 / maxH
    x = Math.max(Math.min(100, x), 0)
    y = Math.max(Math.min(100, y), 0)
    @pointer.css "top", y + "%"
    @pointer.css "left", x + "%"
    @_setHue x
    @_setValue 100 - y
    @_recalculateColor()
    @_updateControls()

  #SELECTOR 1
  _selectorStartmove: (e)=>
    $(document).on
      mouseover: @_selectorMove
      mousemove: @_selectorMove
      mouseup: @_selectorStopmove
    @_bindFocus()
    @_selectorMove e

  _selectorStopmove: (e)=>
    @_selectorMove e
    @_unbindFocus()
    $(document).off
      mouseover: @_selectorMove
      mousemove: @_selectorMove
      mouseup: @_selectorStopmove

  _selectorMove: (e)=>
    e.stopPropagation()
    e.preventDefault()
    y = (e.clientY - @col.offset().top) * 100 / @col.height()
    y = Math.max(Math.min(100, y), 0)
    @sel.css "top", y + "%"
    @_setSaturation 100 - y
    @_recalculateColor()
    @_updateControls()


  #SELECTOR 2
  _opselectorStartmove: (e)=>
    $(document).on
      mouseover: @_opselectorMove
      mousemove: @_opselectorMove
      mouseup: @_opselectorStopmove
    @_bindFocus()
    @_opselectorMove e

  _opselectorStopmove: (e)=>
    @_opselectorMove e
    @_unbindFocus()
    $(document).off
      mouseover: @_opselectorMove
      mousemove: @_opselectorMove
      mouseup: @_opselectorStopmove

  _opselectorMove: (e)=>
    e.stopPropagation()
    e.preventDefault()
    y = (e.clientY - @op_wrapper.offset().top) * 100 / @op_wrapper.height()
    y = Math.max(Math.min(100, y), 0)
    @op_sel.css "top", y + "%"
    @_setOpacity 100 - y
    @_recalculateColor()
    @_updateControls()


  _setHue: (h)=>
    @hsv.h = h / 100

  _setSaturation: (s)=>
    @hsv.s = s / 100

  _setValue: (v)=>
    @hsv.v = v / 100

  _setOpacity: (o)=>
    @opacity = o / 100

  _recalculateColor: ()=>
    @rgb = @cnv.hsvtorgb @hsv
    @hex = @cnv.rgbtohex @rgb
    @input?.val(@hex)

  _updateControls: ()=>
    @pointer.css "top", (1 - @hsv.v) * 100 + "%"
    @pointer.css "left", @hsv.h * 100 + "%"
    @sel.css "top", (1 - @hsv.s) * 100 + "%"
    @op_sel.css "top", (1 - @opacity) * 100 + "%"
    @map.css
      "background": "-webkit-linear-gradient(top, rgba(255, 255, 255, #{1 - @hsv.s}), #000000), -webkit-linear-gradient(to right, #ff0000 0%, #ffff00, #00ff00, #00ffff, #0000ff, #ff00ff, #ff0000)"
      "background-image": "linear-gradient(to bottom, rgba(255, 255, 255, #{1 - @hsv.s}), #000), linear-gradient(to right, #F00 0%, #FF0, #0F0, #0FF, #00F, #F0F, #F00)"
    @col.css
      "background-color": @cnv.hsvtohex h: @hsv.h, s: 1, v: @hsv.v
    rgba = @getRGBA()
    @op_col.css
      "background-color": "rgba(#{rgba.r},#{rgba.g},#{rgba.b},#{rgba.a})"
    @input?.trigger "changeColor"

  setHSV: ({h, s, v})->
    @hsv = {h, s, v}
    @_recalculateColor()
    @_updateControls()

  setHEX: (hex)->
    if !hex
      return
    @hex = hex
    @rgb = @cnv.hextorgb @hex
    @hsv = @cnv.rgbtohsv @rgb
    @input?.val(@hex)
    @_updateControls()

  setRGBA: ({r,g,b,a})->
    @rgb = {r,g,b}
    @opacity = a
    @hsv = @cnv.rgbtohsv @rgb
    @hex = @cnv.rgbtohex @rgb
    @input?.val(@hex)
    @_updateControls()

  setAlpha: (a)->
    @opacity = a

  getHSV: ()->
    @hsv

  getRGB: ()->
    @rgb

  getHEX: ()->
    @hex

  getAlpha: ()->
    @opacity

  getRGBA: ()->
    $.extend @rgb, a:@opacity

  getHSVA: ()->
    $.extend @rgb, a:@opacity

  getRGBA_string: ()->
    "rgba(#{@rgb.r}, #{@rgb.g}, #{@rgb.b}, #{@opacity.toFixed 2})"

  cnv:
    hsvtohex: (hsv)->
      @rgbtohex @hsvtorgb hsv

    hsvtorgb: (hsv) ->
      {h,s,v} = hsv
      i = Math.floor h * 6
      f = h * 6 - i
      p = v * (1 - s)
      q = v * (1 - f * s)
      t = v * (1 - (1 - f) * s)
      i = i % 6
      [r,g,b] = switch
        when i is 0 then [v, t, p]
        when i is 1 then [q, v, p]
        when i is 2 then [p, v, t]
        when i is 3 then [p, q, v]
        when i is 4 then [t, p, v]
        when i is 5 then [v, p, q]
        else [1, 1, 1]
      r: Math.floor(r * 255)
      g: Math.floor(g * 255)
      b: Math.floor(b * 255)

    rgbtohsv: (rgb) ->
      {r,g,b} = rgb
      r = r / 255
      g = g / 255
      b = b / 255
      max = Math.max r, g, b
      min = Math.min r, g, b
      v = max
      d = max - min;
      s = if max is 0 then 0 else d / max
      if max is min
        h = 0
      else
        switch max
          when r then h = (g - b) / d + (if g < b then 6 else 0)
          when g then h = (b - r) / d + 2
          when b then h = (r - g) / d + 4
        h /= 6;
      {h, s, v}


    rgbtohex: (rgb) ->
      "#" + @ntohex(rgb.r) + @ntohex(rgb.g) + @ntohex(rgb.b)

    ntohex: (n)->
      if !n
        return "00"
      n = Math.max 0, Math.min(n, 255)
      "0123456789ABCDEF".charAt((n - n % 16) / 16) + "0123456789ABCDEF".charAt n % 16

    hextorgb: (hex)->
      res = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec hex
      if !res
        r: 255
        g: 255
        b: 255
      else
        r: parseInt(res[1], 16)
        g: parseInt(res[2], 16)
        b: parseInt(res[3], 16)
