part of datgui;

class StringController extends Controller {
  TextInputElement __input;

  StringController(Object object, String property) : super(object, property) {

    this.__input = new TextInputElement();
    //this.__input.setAttribute('type', 'text');

    onChange() {
      this.setValue(this.__input.value);
    }

    onBlur() {
      if (this.__onFinishChange) {
        this.__onFinishChange.call(this, this.getValue());
      }
    }

    DOM.bind(this.__input, 'keyup', onChange);
    DOM.bind(this.__input, 'change', onChange);
    DOM.bind(this.__input, 'blur', onBlur);
    DOM.bind(this.__input, 'keydown', (e) {
      if (e.keyCode == 13) {
        __input.blur();
      }
    });


    this.updateDisplay();

    this.domElement.append(this.__input);

  }

  updateDisplay() {
    // Stops the caret from moving on account of:
    // keyup -> setValue -> updateDisplay
    if (!DOM.isActive(this.__input)) {
      this.__input.value = this.getValue();
    }
    return super.updateDisplay();
  }
}
