part of datgui;

// An "abstract" class that represents a given property of an object.
abstract class Controller {

  var initialValue;

  /// Those who extend this class will put their DOM elements in here.
  HtmlElement domElement;

  /// The object to manipulate
  Object object;

  /// The name of the property to manipulate
  String property;

  /// The function to be called on change.
  EventListener __onChange;

  /// The function to be called on finishing change.
  EventListener __onFinishChange;

  LIElement __li;

  Controller(Object object, String property) {

    this.initialValue = reflect(object).getField(new Symbol(property)).reflectee;

    this.domElement = new DivElement();

    this.object = object;

    this.property = property;

    this.__onChange = null;

    this.__onFinishChange = null;
  }

  /**
   * Specify that a function fire every time someone changes the value with
   * this Controller.
   *
   * @param {Function} fnc This function will be called whenever the value
   * is modified via this Controller.
   * @returns {dat.controllers.Controller} this
   */
  onChange(EventListener fnc) {
    this.__onChange = fnc;
    return this;
  }

  /**
   * Specify that a function fire every time someone "finishes" changing
   * the value wih this Controller. Useful for values that change
   * incrementally like numbers or strings.
   *
   * @param {Function} fnc This function will be called whenever
   * someone "finishes" changing the value via this Controller.
   * @returns {dat.controllers.Controller} this
   */
  onFinishChange(EventListener fnc) {
    this.__onFinishChange = fnc;
    return this;
  }

  /**
   * Change the value of <code>object[property]</code>
   *
   * @param {Object} newValue The new value of <code>object[property]</code>
   */
  setValue(newValue) {
    reflect(object).setField(new Symbol(this.property),newValue);
    //this.object[this.property] = newValue;
    if (this.__onChange != null) {
      this.__onChange(newValue);
    }
    this.updateDisplay();
    return this;
  }

  /**
   * Gets the value of <code>object[property]</code>
   *
   * @returns {Object} The current value of <code>object[property]</code>
   */
  getValue() {
    return reflect(object).getField(new Symbol(property)).reflectee;
  }

  /**
   * Refreshes the visual display of a Controller in order to keep sync
   * with the object's current value.
   * @returns {dat.controllers.Controller} this
   */
  updateDisplay() {
    return this;
  }

  /**
   * @returns {Boolean} true if the value has deviated from initialValue
   */
  isModified() {
    return this.initialValue != this.getValue();
}

}
