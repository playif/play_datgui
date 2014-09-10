part of datgui;

class Common {
  static Map BREAK = {
  };

  static extend(Map target, Map arguments) {
    each(target, (obj) {
      for (var key in obj)
        if (!isUndefined(obj[key]))
          target[key] = obj[key];
    });
    return target;
  }

  static defaults(target, arguments) {
    each(target, (obj) {
      for (var key in obj)
        if (isUndefined(target[key]))
          target[key] = obj[key];
    });
    return target;
  }

  static compose() {
    var toCall = ARR_SLICE.call(arguments);
    return () {
      var args = ARR_SLICE.call(arguments);
      for (var i = toCall.length - 1; i >= 0; i--) {
        args = [toCall[i].apply(this, args)];
      }
      return args[0];
    };
  }

  static each(Map obj, Function itr) {
    obj.forEach(itr);
//    if (obj == null) return;
//
//    if (ARR_EACH && obj.forEach && obj.forEach == ARR_EACH) {
//
//
//
//    } else if (obj.length == obj.length + 0) {
//      // Is number but not NaN
//
//      for (var key = 0, l = obj.length; key < l; key++)
//        if (obj.containsKey(key) && itr(obj[key], key) == BREAK) return;
//
//    }
//    else {
//
//      for (var key in obj)
//        if (itr(obj[key], key) == BREAK)
//          return;
//
//    }

  }

  static defer(fnc) {
    setTimeout(fnc, 0);
  }

  static toArray(obj) {
    if (obj.toArray) return obj.toArray();
    return ARR_SLICE.call(obj);
  }

  static isUndefined(obj) {
    return obj == null;
  }

  static isNull(obj) {
    return obj == null;
  }

  isNaN(obj) {
    return obj != obj;
  }

  static isArray(obj) {
    return obj is List;
  }

  isObject(obj) {
    return obj is Object;
  }

  isNumber(obj) {
    return obj == obj + 0;
  }

  isString(obj) {
    return obj == obj + '';
  }

  isBoolean(obj) {
    return obj == false || obj == true;
  }

  isFunction(obj) {
    return obj is Function;
  }

}
