picker_code = "<div class='picker' style='display: none;'>
<div class='color-map'><div class='pointer'></div></div>
<div class='saturation'><div class='selector'></div></div>
</div>"

$.fn.colorPicker = (action)->
  if !action
    @.each ()->
      if !$(@).next().hasClass "picker"
        p = $(picker_code);
        p.click (e)->
          e.stopPropagation()

        startmove = (e, r,t)->
          x = if e.offsetX isnt null then e.offsetX else e.originalEvent.layerX
          y = if e.offsetY isnt null then e.offsetY else e.originalEvent.layerY
          pointer = $ ".pointer:visible"
          pointer.css "top", y + "px"
          pointer.css "left", x + "px"
          $(document).on
            mouseover: moving
            mousemove: moving

        moving = (e)->
          x = if e.offsetX isnt null then e.offsetX else e.originalEvent.layerX
          y = if e.offsetY isnt null then e.offsetY else e.originalEvent.layerY
          pointer = $ ".pointer:visible"
          pointer.css "top", y + "px"
          pointer.css "left", x + "px"

        stopmove = (e)->
          pointer = $ ".pointer:visible"
          x = if e.offsetX isnt null then e.offsetX else e.originalEvent.layerX
          y = if e.offsetY isnt null then e.offsetY else e.originalEvent.layerY
          $(document).off
            mouseover: moving
            mousemove: moving
          pointer.css "top", y + "px"
          pointer.css "left", x + "px"

        p.find(".color-map").on
          mousedown: startmove
          mouseup: stopmove
        #$(document).on
        #  mouseup: stopmove

        $(@).after p

    $("body").on "click", ".colorpicker", (e)->
      p = $(@).next()
      if p.is ":visible"
        return
      $(".picker").each ()->
        if (p[0] isnt $(@)[0]) and ($(@).is ":visible")
          $(@).hide()
      p.css "top", $(@).position().top + $(@).outerHeight true
      p.css "left", $(@).position().left + parseInt($(@).css("margin-left"), 10)
      p.toggle()
      e.stopPropagation()
    $(document).click ()->
      $(".picker:visible").hide()
  #false
  @

$(".colorpicker").colorPicker()

