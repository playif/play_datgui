part of datgui;

numDecimals(x) {
  x = x.toString();
  if (x.indexOf('.') > -1) {
    return x.length - x.indexOf('.') - 1;
  } else {
    return 0;
  }
}

class NumberController extends Controller {
  num __min;
  num __max;
  num __step;
  num __impliedStep;
  num __precision;

  NumberController(object, property, params) : super(object, property) {
//    params = params || {
//    };

    this.__min = params['min'];
    this.__max = params['max'];
    this.__step = params['step'];

    if (this.__step == null) {

      if (this.initialValue == 0) {
        this.__impliedStep = 1;
        // What are we, psychics?
      } else {
        // Hey Doug, check this out.
        this.__impliedStep = pow(10, (log(this.initialValue) / LN10).floor()) / 10;
      }

    } else {

      this.__impliedStep = this.__step;

    }

    this.__precision = numDecimals(this.__impliedStep);
  }

  setValue(v) {

    if (this.__min != null && v < this.__min) {
      v = this.__min;
    } else if (this.__max != null && v > this.__max) {
      v = this.__max;
    }

    if (this.__step != null && v % this.__step != 0) {
      v = (v / this.__step).round() * this.__step;
    }

    return super.setValue(v);

  }

  /**
   * Specify a minimum value for <code>object[property]</code>.
   *
   * @param {Number} minValue The minimum value for
   * <code>object[property]</code>
   * @returns {dat.controllers.NumberController} this
   */

  min(v) {
    this.__min = v;
    return this;
  }

  /**
   * Specify a maximum value for <code>object[property]</code>.
   *
   * @param {Number} maxValue The maximum value for
   * <code>object[property]</code>
   * @returns {dat.controllers.NumberController} this
   */

  max(v) {
    this.__max = v;
    return this;
  }

  /**
   * Specify a step value that dat.controllers.NumberController
   * increments by.
   *
   * @param {Number} stepValue The step value for
   * dat.controllers.NumberController
   * @default if minimum and maximum specified increment is 1% of the
   * difference otherwise stepValue is 1
   * @returns {dat.controllers.NumberController} this
   */

  step(v) {
    this.__step = v;
    this.__impliedStep = v;
    this.__precision = numDecimals(v);
    return this;
  }
}
