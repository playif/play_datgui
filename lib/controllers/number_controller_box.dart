part of datgui;

roundToDecimal(value, decimals) {
  var tenTo = pow(10, decimals);
  return (value * tenTo).round() / tenTo;
}

class NumberControllerBox extends NumberController {
  TextInputElement __input;
  bool __truncationSuspended;

  NumberControllerBox(Object object, String property, params) : super(object, property, params) {
    /**
     * {Number} Previous mouse y position
     * @ignore
     */
    num prev_y;

    this.__input = new TextInputElement();
    //this.__input.setAttribute('type', 'text');

    // Makes it so manually specified values are not truncated.

    onMouseDrag(e) {
      num diff = prev_y - e.clientY;
      this.setValue(this.getValue() + diff * this.__impliedStep);
      prev_y = e.clientY;
    }

    onMouseUp(e) {
      DOM.unbind(window, 'mousemove', onMouseDrag);
      DOM.unbind(window, 'mouseup', onMouseUp);
    }

    onChange() {
      num attempted = num.parse(this.__input.value);
      if (!attempted.isNaN) this.setValue(attempted);
    }

    onBlur() {
      onChange();
      if (this.__onFinishChange) {
        this.__onFinishChange(this.getValue());
      }
    }

    onMouseDown(e) {
      DOM.bind(window, 'mousemove', onMouseDrag);
      DOM.bind(window, 'mouseup', onMouseUp);
      prev_y = e.clientY;
    }

    DOM.bind(this.__input, 'change', onChange);
    DOM.bind(this.__input, 'blur', onBlur);
    DOM.bind(this.__input, 'mousedown', onMouseDown);
    DOM.bind(this.__input, 'keydown', (e) {
      // When pressing entire, you can be as precise as you want.
      if (e.keyCode == 13) {
        this.__truncationSuspended = true;
        __input.blur();
        this.__truncationSuspended = false;
      }
    });


    this.updateDisplay();

    this.domElement.append(this.__input);

  }

  updateDisplay() {

    this.__input.value = this.__truncationSuspended ? this.getValue() : roundToDecimal(this.getValue(), this.__precision);
    return super.updateDisplay.call();
  }

}
