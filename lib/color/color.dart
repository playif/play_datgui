part of datgui;


class Color {

  List<String> COMPONENTS = ['r', 'g', 'b', 'h', 's', 'v', 'hex', 'a'];

  get a {
    this.__state.a;
  }

  set a(value) {
    this.__state.a = value;
  }

  get hex {
    if (!this.__state.space != 'HEX') {
      this.__state.hex = math.rgb_to_hex(this.r, this.g, this.b);
    }
    return this.__state.hex;
  }

  set hex(v) {
    this.__state.space = 'HEX';
    this.__state.hex = v;
  }

  get r {
    if (this.__state.space == 'RGB') {
      return this.__state['r'];
    }
    recalculateRGB(this, 'r', 2);
    return this.__state['r'];
  }

  set r(String value) {
    if (this.__state.space != 'RGB') {
      recalculateRGB(this, 'r', 2);
      this.__state.space = 'RGB';
    }
    this.__state['r'] = v;
  }


  Color() {
    this.__state = interpret.apply(this, arguments);

    if (this.__state == false) {
      throw 'Failed to interpret color arguments';
    }

    this.__state.a = this.__state.a || 1;
  }


  toOriginal() {
    return this.__state.conversion.write(this);
  }


  recalculateRGB(String component, componentHexIndex) {

    if (this.__state.space == 'HEX') {

      this.__state[component] = math.component_from_hex(this.__state.hex, componentHexIndex);

    } else if (this.__state.space == 'HSV') {

      common.extend(color.__state, math.hsv_to_rgb(this.__state.h, this.__state.s, this.__state.v));

    } else {

      throw 'Corrupted color state';

    }

  }

  recalculateHSV() {

    var result = math.rgb_to_hsv(this.r, this.g, this.b);

    common.extend(color.__state,
    {
        s: result.s,
        v: result.v
    }
    );

    if (!common.isNaN(result.h)) {
      color.__state.h = result.h;
    } else if (common.isUndefined(color.__state.h)) {
      color.__state.h = 0;
    }

  }
}
