part of datgui;


map(v, i1, i2, o1, o2) {
  return o1 + (o2 - o1) * ((v - i1) / (i2 - i1));
}

class NumberControllerSlider extends NumberController {
  DivElement __background;
  DivElement __foreground;


  NumberControllerSlider(object, property, min, max, step)
  :super(object, property, {
      min: min, max: max, step: step
  }) {

    this.__background = new DivElement();
    this.__foreground = new DivElement();


    DOM.addClass(this.__background, 'slider');
    DOM.addClass(this.__foreground, 'slider-fg');


    onMouseDrag(e) {
      e.preventDefault();
      var offset = DOM.getOffset(this.__background);
      var width = DOM.getWidth(this.__background);
      this.setValue(
          map(e.clientX, offset.left, offset.left + width, this.__min, this.__max)
      );
      return false;
    }

    onMouseUp() {
      DOM.unbind(window, 'mousemove', onMouseDrag);
      DOM.unbind(window, 'mouseup', onMouseUp);
      if (this.__onFinishChange) {
        this.__onFinishChange(this.getValue());
      }
    }


    onMouseDown(e) {
      DOM.bind(window, 'mousemove', onMouseDrag);
      DOM.bind(window, 'mouseup', onMouseUp);
      onMouseDrag(e);
    }


    this.updateDisplay();

    this.__background.append(this.__foreground);
    this.domElement.append(this.__background);


    DOM.bind(this.__background, 'mousedown', onMouseDown);

  }


  static useDefaultStyles() {
    CSS.inject(styleSheet);
  }

  updateDisplay() {
    var pct = (this.getValue() - this.__min) / (this.__max - this.__min);
    this.__foreground.style.width = pct * 100 + '%';
    return super.updateDisplay();
  }

}
