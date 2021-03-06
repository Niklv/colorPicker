// Generated by CoffeeScript 1.6.3
(function() {
  var ColorPicker,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  $.fn.colorPicker = function(action, param) {
    if (action == null) {
      action = "init";
    }
    switch (action) {
      case "init":
        return this.each(function() {
          var data;
          data = $(this).data("colorpicker");
          return $(this).data('colorpicker', new ColorPicker(this, param));
        });
      default:
        return this.eq(0).data("colorpicker")[action](param);
    }
  };

  ColorPicker = (function() {
    var picker_code;

    picker_code = "<div class='picker'><div class='map'><div class='pointer'></div></div><div class='column value'><div class='selector'></div></div><div class='column op-wrapper'><div class='op-column'><div class='selector'></div></div></div></div>";

    ColorPicker.prototype.input = null;

    ColorPicker.prototype.el = null;

    ColorPicker.prototype.map = null;

    ColorPicker.prototype.pointer = null;

    ColorPicker.prototype.col = null;

    ColorPicker.prototype.op_wrapper = null;

    ColorPicker.prototype.sel = null;

    ColorPicker.prototype.hsv = {
      h: 0,
      s: 1,
      v: 1
    };

    ColorPicker.prototype.rgb = {
      r: 255,
      g: 0,
      b: 0
    };

    ColorPicker.prototype.opacity = 1;

    ColorPicker.prototype.hex = "#FF0000";

    ColorPicker.prototype.position = "bottom";

    function ColorPicker(input, param) {
      this._updateControls = __bind(this._updateControls, this);
      this._recalculateColor = __bind(this._recalculateColor, this);
      this._setOpacity = __bind(this._setOpacity, this);
      this._setValue = __bind(this._setValue, this);
      this._setSaturation = __bind(this._setSaturation, this);
      this._setHue = __bind(this._setHue, this);
      this._opselectorMove = __bind(this._opselectorMove, this);
      this._opselectorStopmove = __bind(this._opselectorStopmove, this);
      this._opselectorStartmove = __bind(this._opselectorStartmove, this);
      this._selectorMove = __bind(this._selectorMove, this);
      this._selectorStopmove = __bind(this._selectorStopmove, this);
      this._selectorStartmove = __bind(this._selectorStartmove, this);
      this._pointerMove = __bind(this._pointerMove, this);
      this._pointerStopmove = __bind(this._pointerStopmove, this);
      this._pointerStartmove = __bind(this._pointerStartmove, this);
      this._showHide = __bind(this._showHide, this);
      this._parseColor = __bind(this._parseColor, this);
      this._bind = __bind(this._bind, this);
      if (!input) {
        console.log("ERROR: Empty first param");
      }
      this.el = $(picker_code);
      this.map = this.el.find(".map");
      this.pointer = this.map.find(".pointer");
      this.col = this.el.find(".column.value");
      this.sel = this.col.find(".selector");
      this.op_wrapper = this.el.find(".column.op-wrapper");
      this.op_col = this.op_wrapper.find(".op-column");
      this.op_sel = this.op_col.find(".selector");
      this.col.css({
        "background": "-webkit-linear-gradient(top, rgba(255, 255, 255, 0), #ffffff)",
        "background-image": "linear-gradient(to bottom, rgba(255, 255, 255, 0), #ffffff)"
      });
      this._recalculateColor();
      this._updateControls();
      this.el.click(function(e) {
        return e.stopPropagation();
      });
      this.map.on({
        mousedown: this._pointerStartmove
      });
      this.col.on({
        mousedown: this._selectorStartmove
      });
      if ((param != null ? param.opacity : void 0) === 1) {
        this.op_col.on({
          mousedown: this._opselectorStartmove
        });
      } else {
        this.el.addClass("disable-opacity");
      }
      if (param != null ? param.position : void 0) {
        this.position = param.position;
      }
      this._bind(input);
    }

    ColorPicker.prototype._bind = function(input) {
      var _this = this;
      if (input && !$(input).next().hasClass("picker")) {
        this.input = $(input);
        this.input.after(this.el);
        this.input.attr('maxlength', 7);
        this.input.on({
          click: this._showHide,
          focus: this._showHide,
          input: this._parseColor
        });
        $(document).click(function() {
          return _this.el.hide();
        });
        return true;
      } else {
        return false;
      }
    };

    ColorPicker.prototype._parseColor = function(e) {
      var color, pos, rgbarr, val;
      val = this.input.val();
      color = val.replace(/[^A-Fa-f0-9]/g, "");
      if (val[0] !== '#' || val.length - 1 !== color.length) {
        pos = this.input[0].selectionStart;
        this.input.val('#' + color);
        if (pos !== val.length) {
          this.input[0].selectionStart = pos - 1;
          this.input[0].selectionEnd = pos - 1;
        }
      }
      rgbarr = [];
      if (color.length === 0) {
        color = "FFFFFF";
      }
      if (color.length === 3) {
        color = color[0] + color[0] + color[1] + color[1] + color[2] + color[2];
      } else {
        while (color.length < 6) {
          color += color[color.length - 1];
        }
      }
      while (color.length >= 2) {
        rgbarr.push(parseInt(color.substring(0, 2), 16));
        color = color.substring(2, color.length);
      }
      this.rgb = {
        r: rgbarr[0],
        g: rgbarr[1],
        b: rgbarr[2]
      };
      this.hsv = this.cnv.rgbtohsv(this.rgb);
      this.hex = this.cnv.rgbtohex(this.rgb);
      return this._updateControls();
    };

    ColorPicker.prototype._showHide = function(e) {
      var position;
      e.stopPropagation();
      if (this.el.is(":visible")) {
        return;
      }
      $(".picker").not(this.el).each(function() {
        return $(this).hide();
      });
      position = this.input.position();
      switch (this.position) {
        case "top":
          this.el.css("top", position.top - this.el.outerHeight(true));
          this.el.css("left", position.left + parseInt(this.input.css("margin-left"), 10));
          break;
        case "bottom":
          this.el.css("top", position.top + this.input.outerHeight(true));
          this.el.css("left", position.left + parseInt(this.input.css("margin-left"), 10));
      }
      return this.el.toggle();
    };

    ColorPicker.prototype._bindFocus = function() {
      $("body").addClass("unselectable");
      return this.input.blur();
    };

    ColorPicker.prototype._unbindFocus = function() {
      $("body").removeClass("unselectable");
      return this.input.focus();
    };

    ColorPicker.prototype._pointerStartmove = function(e) {
      $(document).on({
        mouseover: this._pointerMove,
        mousemove: this._pointerMove,
        mouseup: this._pointerStopmove
      });
      this._bindFocus();
      return this._pointerMove(e);
    };

    ColorPicker.prototype._pointerStopmove = function(e) {
      this._pointerMove(e);
      this._unbindFocus();
      return $(document).off({
        mouseover: this._pointerMove,
        mousemove: this._pointerMove,
        mouseup: this._pointerStopmove
      });
    };

    ColorPicker.prototype._pointerMove = function(e) {
      var maxH, maxW, offset, x, y;
      e.stopPropagation();
      e.preventDefault();
      offset = this.map.offset();
      maxW = this.map.width();
      maxH = this.map.height();
      x = (e.clientX - offset.left) * 100 / maxW;
      y = (e.clientY - offset.top) * 100 / maxH;
      x = Math.max(Math.min(100, x), 0);
      y = Math.max(Math.min(100, y), 0);
      this.pointer.css("top", y + "%");
      this.pointer.css("left", x + "%");
      this._setHue(x);
      this._setValue(100 - y);
      this._recalculateColor();
      return this._updateControls();
    };

    ColorPicker.prototype._selectorStartmove = function(e) {
      $(document).on({
        mouseover: this._selectorMove,
        mousemove: this._selectorMove,
        mouseup: this._selectorStopmove
      });
      this._bindFocus();
      return this._selectorMove(e);
    };

    ColorPicker.prototype._selectorStopmove = function(e) {
      this._selectorMove(e);
      this._unbindFocus();
      return $(document).off({
        mouseover: this._selectorMove,
        mousemove: this._selectorMove,
        mouseup: this._selectorStopmove
      });
    };

    ColorPicker.prototype._selectorMove = function(e) {
      var y;
      e.stopPropagation();
      e.preventDefault();
      y = (e.clientY - this.col.offset().top) * 100 / this.col.height();
      y = Math.max(Math.min(100, y), 0);
      this.sel.css("top", y + "%");
      this._setSaturation(100 - y);
      this._recalculateColor();
      return this._updateControls();
    };

    ColorPicker.prototype._opselectorStartmove = function(e) {
      $(document).on({
        mouseover: this._opselectorMove,
        mousemove: this._opselectorMove,
        mouseup: this._opselectorStopmove
      });
      this._bindFocus();
      return this._opselectorMove(e);
    };

    ColorPicker.prototype._opselectorStopmove = function(e) {
      this._opselectorMove(e);
      this._unbindFocus();
      return $(document).off({
        mouseover: this._opselectorMove,
        mousemove: this._opselectorMove,
        mouseup: this._opselectorStopmove
      });
    };

    ColorPicker.prototype._opselectorMove = function(e) {
      var y;
      e.stopPropagation();
      e.preventDefault();
      y = (e.clientY - this.op_wrapper.offset().top) * 100 / this.op_wrapper.height();
      y = Math.max(Math.min(100, y), 0);
      this.op_sel.css("top", y + "%");
      this._setOpacity(100 - y);
      this._recalculateColor();
      return this._updateControls();
    };

    ColorPicker.prototype._setHue = function(h) {
      return this.hsv.h = h / 100;
    };

    ColorPicker.prototype._setSaturation = function(s) {
      return this.hsv.s = s / 100;
    };

    ColorPicker.prototype._setValue = function(v) {
      return this.hsv.v = v / 100;
    };

    ColorPicker.prototype._setOpacity = function(o) {
      return this.opacity = o / 100;
    };

    ColorPicker.prototype._recalculateColor = function() {
      var _ref;
      this.rgb = this.cnv.hsvtorgb(this.hsv);
      this.hex = this.cnv.rgbtohex(this.rgb);
      return (_ref = this.input) != null ? _ref.val(this.hex) : void 0;
    };

    ColorPicker.prototype._updateControls = function() {
      var rgba, _ref;
      this.pointer.css("top", (1 - this.hsv.v) * 100 + "%");
      this.pointer.css("left", this.hsv.h * 100 + "%");
      this.sel.css("top", (1 - this.hsv.s) * 100 + "%");
      this.op_sel.css("top", (1 - this.opacity) * 100 + "%");
      this.map.css({
        "background": "-webkit-linear-gradient(top, rgba(255, 255, 255, " + (1 - this.hsv.s) + "), #000000), -webkit-linear-gradient(to right, #ff0000 0%, #ffff00, #00ff00, #00ffff, #0000ff, #ff00ff, #ff0000)",
        "background-image": "linear-gradient(to bottom, rgba(255, 255, 255, " + (1 - this.hsv.s) + "), #000), linear-gradient(to right, #F00 0%, #FF0, #0F0, #0FF, #00F, #F0F, #F00)"
      });
      this.col.css({
        "background-color": this.cnv.hsvtohex({
          h: this.hsv.h,
          s: 1,
          v: this.hsv.v
        })
      });
      rgba = this.getRGBA();
      this.op_col.css({
        "background-color": "rgba(" + rgba.r + "," + rgba.g + "," + rgba.b + "," + rgba.a + ")"
      });
      return (_ref = this.input) != null ? _ref.trigger("changeColor") : void 0;
    };

    ColorPicker.prototype.setHSV = function(_arg) {
      var h, s, v;
      h = _arg.h, s = _arg.s, v = _arg.v;
      this.hsv = {
        h: h,
        s: s,
        v: v
      };
      this._recalculateColor();
      return this._updateControls();
    };

    ColorPicker.prototype.setHEX = function(hex) {
      var _ref;
      if (!hex) {
        return;
      }
      this.hex = hex;
      this.rgb = this.cnv.hextorgb(this.hex);
      this.hsv = this.cnv.rgbtohsv(this.rgb);
      if ((_ref = this.input) != null) {
        _ref.val(this.hex);
      }
      return this._updateControls();
    };

    ColorPicker.prototype.setRGBA = function(_arg) {
      var a, b, g, r, _ref;
      r = _arg.r, g = _arg.g, b = _arg.b, a = _arg.a;
      this.rgb = {
        r: r,
        g: g,
        b: b
      };
      this.opacity = a;
      this.hsv = this.cnv.rgbtohsv(this.rgb);
      this.hex = this.cnv.rgbtohex(this.rgb);
      if ((_ref = this.input) != null) {
        _ref.val(this.hex);
      }
      return this._updateControls();
    };

    ColorPicker.prototype.setAlpha = function(a) {
      return this.opacity = a;
    };

    ColorPicker.prototype.getHSV = function() {
      return this.hsv;
    };

    ColorPicker.prototype.getRGB = function() {
      return this.rgb;
    };

    ColorPicker.prototype.getHEX = function() {
      return this.hex;
    };

    ColorPicker.prototype.getAlpha = function() {
      return this.opacity;
    };

    ColorPicker.prototype.getRGBA = function() {
      return $.extend(this.rgb, {
        a: this.opacity
      });
    };

    ColorPicker.prototype.getHSVA = function() {
      return $.extend(this.rgb, {
        a: this.opacity
      });
    };

    ColorPicker.prototype.getRGBA_string = function() {
      return "rgba(" + this.rgb.r + ", " + this.rgb.g + ", " + this.rgb.b + ", " + (this.opacity.toFixed(2)) + ")";
    };

    ColorPicker.prototype.cnv = {
      hsvtohex: function(hsv) {
        return this.rgbtohex(this.hsvtorgb(hsv));
      },
      hsvtorgb: function(hsv) {
        var b, f, g, h, i, p, q, r, s, t, v, _ref;
        h = hsv.h, s = hsv.s, v = hsv.v;
        i = Math.floor(h * 6);
        f = h * 6 - i;
        p = v * (1 - s);
        q = v * (1 - f * s);
        t = v * (1 - (1 - f) * s);
        i = i % 6;
        _ref = (function() {
          switch (false) {
            case i !== 0:
              return [v, t, p];
            case i !== 1:
              return [q, v, p];
            case i !== 2:
              return [p, v, t];
            case i !== 3:
              return [p, q, v];
            case i !== 4:
              return [t, p, v];
            case i !== 5:
              return [v, p, q];
            default:
              return [1, 1, 1];
          }
        })(), r = _ref[0], g = _ref[1], b = _ref[2];
        return {
          r: Math.floor(r * 255),
          g: Math.floor(g * 255),
          b: Math.floor(b * 255)
        };
      },
      rgbtohsv: function(rgb) {
        var b, d, g, h, max, min, r, s, v;
        r = rgb.r, g = rgb.g, b = rgb.b;
        r = r / 255;
        g = g / 255;
        b = b / 255;
        max = Math.max(r, g, b);
        min = Math.min(r, g, b);
        v = max;
        d = max - min;
        s = max === 0 ? 0 : d / max;
        if (max === min) {
          h = 0;
        } else {
          switch (max) {
            case r:
              h = (g - b) / d + (g < b ? 6 : 0);
              break;
            case g:
              h = (b - r) / d + 2;
              break;
            case b:
              h = (r - g) / d + 4;
          }
          h /= 6;
        }
        return {
          h: h,
          s: s,
          v: v
        };
      },
      rgbtohex: function(rgb) {
        return "#" + this.ntohex(rgb.r) + this.ntohex(rgb.g) + this.ntohex(rgb.b);
      },
      ntohex: function(n) {
        if (!n) {
          return "00";
        }
        n = Math.max(0, Math.min(n, 255));
        return "0123456789ABCDEF".charAt((n - n % 16) / 16) + "0123456789ABCDEF".charAt(n % 16);
      },
      hextorgb: function(hex) {
        var res;
        res = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
        if (!res) {
          return {
            r: 255,
            g: 255,
            b: 255
          };
        } else {
          return {
            r: parseInt(res[1], 16),
            g: parseInt(res[2], 16),
            b: parseInt(res[3], 16)
          };
        }
      }
    };

    return ColorPicker;

  })();

}).call(this);
