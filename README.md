#colorPicker


Super customizable HTML5 color picker.
Using CoffeeScript and LESS.
All graphic draw with css3 gradients.
Require jQuery.
No images require.

Support IE10+, FF, Chrome, Safari

##Usage
html:
```html
<input class="colorpicker">
```
js:
```js
$(".colorpicker").colorPicker();
$(".colorpicker").colorPicker("setHEX","#123456");
$(".colorpicker").colorPicker("getHEX");
```

input fires "changeColor" event

##example
see index.html

