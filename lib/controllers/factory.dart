part of datgui;

class Factory {

  Factory (Object object, String property,[var args]) {

    var initialValue =  reflect(object).getField(new Symbol(property)).reflectee;

    // Providing options?
    if (args is Map) {
      return new OptionController(object, property, args);
    }

    // Providing a map?

    if (initialValue is num) {

      if ( args is List) {

        // Has min and max.
        return new NumberControllerSlider(object, property, args[2], args[3]);

      } else {

        return new NumberControllerBox(object, property, { min: args[2], max: args[3] });

      }

    }

    if (initialValue is String) {
      return new StringController(object, property);
    }

    if (initialValue is Function) {
      return new FunctionController(object, property, '');
    }

    if (initialValue is bool) {
      return new BooleanController(object, property);
    }

  }
}
