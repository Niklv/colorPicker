$.fn.colorPicker = (action="init", params)->
  switch action
    when "init"
      @.each ()->
        new ColorPicker @, params
    else
      console.log "nothing"
  @

class ColorPicker
  picker_code = "<div class='picker'><div class='color-map'><div class='pointer'></div></div><div class='column'><div class='selector'></div></div></div>"

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


  constructor: (input, params={})->
    if !input
      console.log "ERROR: Empty first param"

    @el = $ picker_code
    @map = @el.find ".color-map"
    @pointer = @map.find ".pointer"
    @col = @el.find ".column"
    @sel = @col.find ".selector"

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

  _pointerStartmove: (e)=>
    @_setPointerPosition e
    $("body").addClass "unselectable"
    $(document).on
      mouseover: @_setPointerPosition
      mousemove: @_setPointerPosition
      mouseup: @_pointerStopmove
    @input.blur ()->
      @.focus()

  _pointerStopmove: (e)=>
    @input.off "blur"
    $(document).off
      mouseover: @_setPointerPosition
      mousemove: @_setPointerPosition
      mouseup: @_pointerStopmove
    $("body").removeClass "unselectable"
    @_setPointerPosition e

  _setPointerPosition: (e)=>
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
    @_setSelectorPosition e
    $("body").addClass "unselectable"
    $(document).on
      mouseover: @_setSelectorPosition
      mousemove: @_setSelectorPosition
      mouseup: @_selectorStopmove
    @input.blur ()->
      @.focus()

  _selectorStopmove: (e)=>
    @input.off "blur"
    $(document).off
      mouseover: @_setSelectorPosition
      mousemove: @_setSelectorPosition
      mouseup: @_selectorStopmove
    $("body").removeClass "unselectable"
    @_setSelectorPosition e

  _setSelectorPosition: (e)=>
    y = (e.clientY - @col.offset().top) * 100 / @col.height()
    y = Math.max(Math.min(100, y), 0)
    @sel.css "top", y + "%"
    @_setSaturation 100 - y
    @_recalculateColor()

  _setHue: (h)=>
    @hsv.h = h / 100 #* 2 * Math.PI

  _setSaturation: (s)=>
    @hsv.s = s / 100

  _setValue: (v)=>
    @hsv.v = v / 100

  _recalculateColor: ()=>
    @rgb = @_hsvtorgb @hsv
    @hex = @_rgbtohex @rgb
    console.log @hsv, @rgb, @hex
    @col.css "background-color", @hex
    console.log @map.css "background-image"

  _rgbtohex: (rgb) ->
    "#" + @_toHex(rgb.r) + @_toHex(rgb.g) + @_toHex(rgb.b)

  _toHex: (n)->
    if !n
      return "00"
    n = Math.max 0, Math.min(n, 255)
    "0123456789ABCDEF".charAt((n - n % 16) / 16) + "0123456789ABCDEF".charAt n % 16


  _hsvtorgb: (hsv) ->
    {h,s,v} = hsv
    i = Math.floor h * 6
    f = h * 6 - i
    p = v * (1 - s)
    q = v * (1 - f * s)
    t = v * (1 - (1 - f) * s)
    switch i % 6
      when 0 then [r,g,b] = [v,t,p]
      when 1 then [r,g,b] = [q,v,p]
      when 2 then [r,g,b] = [p,v,t]
      when 3 then [r,g,b] = [p,q,v]
      when 4 then [r,g,b] = [t,p,v]
      when 5 then [r,g,b] = [v,p,q]
      else
    r: Math.floor(r * 255)
    g: Math.floor(g * 255)
    b: Math.floor(b * 255)


new ColorPicker()
$(".colorpicker").colorPicker()




