part of datgui;

class BooleanController extends Controller {
  var __prev;
  CheckboxInputElement __checkbox;

  BooleanController(Object object, String property):super(object, property) {

    this.__prev = this.getValue();

    this.__checkbox = new CheckboxInputElement();
    //this.__checkbox.setAttribute('type', 'checkbox');

    onChange() {
      this.setValue(this.__prev == null ? false : this.__prev);
    }

    DOM.bind(this.__checkbox, 'change', onChange, false);

    this.domElement.append(this.__checkbox);

    // Match original value
    this.updateDisplay();


  }


  setValue(v) {
    var toReturn = super.setValue(v);
    if (this.__onFinishChange) {
      this.__onFinishChange.call(this, this.getValue());
    }
    this.__prev = this.getValue();
    return toReturn;
  }

  updateDisplay() {

    if (this.getValue() == true) {
      this.__checkbox.setAttribute('checked', 'checked');
      this.__checkbox.checked = true;
    } else {
      this.__checkbox.checked = false;
    }

    return super.updateDisplay();
  }

}
