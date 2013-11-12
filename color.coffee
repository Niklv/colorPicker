$.fn.colorPicker = (action = "init")->
  switch action
    when "init"
      @.each ()->
        new ColorPicker @
    else
      console.log "nothing"
  @

class ColorPicker
  picker_code = "<div class='picker'><div class='map'><div class='pointer'></div></div><div class='column'><div class='selector'></div></div></div>"

  input: null
  el: null
  map: null
  pointer: null
  col: null
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


  constructor: (input)->
    if !input
      console.log "ERROR: Empty first param"

    @el = $ picker_code
    @map = @el.find ".map"
    @pointer = @map.find ".pointer"
    @col = @el.find ".column"
    @sel = @col.find ".selector"
    @col.css
      "background": "-webkit-linear-gradient(top, rgba(255, 255, 255, 0), #ffffff)"
      "background-image": "linear-gradient(to bottom, rgba(255, 255, 255, 0), #ffffff)"

    @_recalculateColor()

    @el.click (e)->
      e.stopPropagation()
    @map.on
      mousedown: @_pointerStartmove
      mouseup: @_pointerStopmove
    @col.on
      mousedown: @_selectorStartmove
      mouseup: @_selectorStopmove
    @_bind input

  _bind: (input)=>
    if input && !$(input).next().hasClass "picker"
      @input = $ input
      @input.after @el
      @input.click @_showHide
      @input.focus @_showHide
      $(document).click ()=>
        @el.hide()
      true
    else false

  _showHide: (e)=>
    e.stopPropagation()
    if @el.is ":visible"
      return
    $(".picker").not(@el).each ()->
      $(@).hide()
    position = @input.position()
    @el.css "top", position.top + @input.outerHeight true
    @el.css "left", position.left + parseInt(@input.css("margin-left"), 10)
    @el.toggle()

  _bindFocus: ()->
    $("body").addClass "unselectable"
    @input.blur()

  _unbindFocus: ()->
    $("body").removeClass "unselectable"
    @input.focus()

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

  _setHue: (h)=>
    @hsv.h = h / 100

  _setSaturation: (s)=>
    @hsv.s = s / 100

  _setValue: (v)=>
    @hsv.v = v / 100

  _recalculateColor: ()=>
    @rgb = @cnv.hsvtorgb @hsv
    @hex = @cnv.rgbtohex @rgb
    @map.css
      "background": "-webkit-linear-gradient(top, rgba(255, 255, 255, #{1 - @hsv.s}), #000000), -webkit-linear-gradient(to right, #ff0000 0%, #ffff00, #00ff00, #00ffff, #0000ff, #ff00ff, #ff0000)"
      "background-image": "linear-gradient(to bottom, rgba(255, 255, 255, #{1 - @hsv.s}), #000), linear-gradient(to right, #F00 0%, #FF0, #0F0, #0FF, #00F, #F0F, #F00)"
    @col.css
      "background-color": @cnv.hsvtohex h: @hsv.h, s: 1, v: @hsv.v
    @input?.val(@hex).trigger "changeColor"

  _updateControls: ()=>
    @pointer.css "top", (1 - @hsv.v) * 100 + "%"
    @pointer.css "left", @hsv.h * 100 + "%"
    @sel.css "top", (1 - @hsv.s) * 100 + "%"

  setHSV: (h = 0, s = 1, v = 1)->
    if !h || !s || !v
      return
    @hsv = {h, s, v}
    @_recalculateColor()
    @_updateControls()

  getHSV: ()->
    @hsv

  getRGB: ()->
    @rgb

  getHEX: ()->
    @hex

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
      switch i % 6
        when 0 then [r,g,b] = [v, t, p]
        when 1 then [r,g,b] = [q, v, p]
        when 2 then [r,g,b] = [p, v, t]
        when 3 then [r,g,b] = [p, q, v]
        when 4 then [r,g,b] = [t, p, v]
        when 5 then [r,g,b] = [v, p, q]
        else
      r: Math.floor(r * 255)
      g: Math.floor(g * 255)
      b: Math.floor(b * 255)

    rgbtohex: (rgb) ->
      "#" + @ntohex(rgb.r) + @ntohex(rgb.g) + @ntohex(rgb.b)

    ntohex: (n)->
      if !n
        return "00"
      n = Math.max 0, Math.min(n, 255)
      "0123456789ABCDEF".charAt((n - n % 16) / 16) + "0123456789ABCDEF".charAt n % 16

$(".colorpicker").colorPicker()




