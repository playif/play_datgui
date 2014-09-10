part of datgui;

class DOM {

  static makeSelectable(HtmlElement elem, [bool selectable=true]) {
    if (elem == null) return;

    elem.onSelectStart.listen(selectable ? (e) {
      return false;
    } : (e) {
    });

    elem.style.userSelect = selectable ? 'auto' : 'none';
  }

  static makeFullscreen(HtmlElement elem, [bool horizontal=true, bool vertical=true]) {
    elem.style.position = 'absolute';

    if (horizontal) {
      elem.style.left = 0;
      elem.style.right = 0;
    }
    if (vertical) {
      elem.style.top = 0;
      elem.style.bottom = 0;
    }
  }

  fakeEvent(HtmlElement elem, eventType, params, aux) {
    params = params || {
    };
    var className = EVENT_MAP_INV[eventType];
    if (!className) {
      throw new Exception('Event type ' + eventType + ' not supported.');
    }
    var evt = document.createEvent(className);
    switch (className) {
      case 'MouseEvents':
        var clientX = params.x || params.clientX || 0;
        var clientY = params.y || params.clientY || 0;
        evt.initMouseEvent(eventType, params.bubbles || false,
        params.cancelable || true, window, params.clickCount || 1,
        0, //screen X
        0, //screen Y
        clientX, //client X
        clientY, //client Y
        false, false, false, false, 0, null);
        break;
      case 'KeyboardEvents':
        var init = evt.initKeyboardEvent || evt.initKeyEvent;
        // webkit || moz
        common.defaults(params, {
            cancelable: true,
            ctrlKey: false,
            altKey: false,
            shiftKey: false,
            metaKey: false,
            keyCode: undefined,
            charCode: undefined
        });
        init(eventType, params.bubbles || false,
        params.cancelable, window,
        params.ctrlKey, params.altKey,
        params.shiftKey, params.metaKey,
        params.keyCode, params.charCode);
        break;
      default:
        evt.initEvent(eventType, params.bubbles || false,
        params.cancelable || true);
        break;
    }
    common.defaults(evt, aux);
    elem.dispatchEvent(evt);
  }

  /**
   *
   * @param elem
   * @param event
   * @param func
   * @param bool
   */

  bind(HtmlElement elem, Event event, EventListener func, [bool useCapture=false]) {
    elem.addEventListener(event, func, useCapture);
  }

  /**
   *
   * @param elem
   * @param event
   * @param func
   * @param bool
   */

  unbind(HtmlElement elem, Event event, EventListener func, [bool useCapture=false]) {
    elem.removeEventListener(event, func, useCapture);
  }

  /**
   *
   * @param elem
   * @param className
   */

  addClass(HtmlElement elem, String className) {
    elem.classes.add(className);
//    if (elem.className == null) {
//      elem.className = className;
//    } else if (elem.className != className) {
//      var classes = elem.className.split(/ +/);
//      if (classes.indexOf(className) == -1) {
//        classes.push(className);
//        elem.className = classes.join(' ').replace(/^\s+/, '').replace(/\s+$/, '');
//      }
//    }
//    return dom;
  }

  /**
   *
   * @param elem
   * @param className
   */

  removeClass(HtmlElement elem, String className) {
    elem.classes.remove(className);
//    if (className) {
//      if (elem.className == undefined) {
//        // elem.className = className;
//      } else if (elem.className == className) {
//        elem.removeAttribute('class');
//      } else {
//        var classes = elem.className.split(/ +/);
//        var index = classes.indexOf(className);
//        if (index != -1) {
//          classes.splice(index, 1);
//          elem.className = classes.join(' ');
//        }
//      }
//    } else {
//      elem.className = undefined;
//    }
//    return dom;
  }

  hasClass(HtmlElement elem, String className) {
    return elem.classes.contains(className);
    //return new RegExp('(?:^|\\s+)' + className + '(?:\\s+|$)').test(elem.className) || false;
  }

  /**
   *
   * @param elem
   */

  getWidth(HtmlElement elem) {

    var style = getComputedStyle(elem);

    return cssValueToPixels(style['border-left-width']) +
           cssValueToPixels(style['border-right-width']) +
           cssValueToPixels(style['padding-left']) +
           cssValueToPixels(style['padding-right']) +
           cssValueToPixels(style['width']);
  }

  /**
   *
   * @param elem
   */

  getHeight(HtmlElement elem) {

    var style = getComputedStyle(elem);

    return cssValueToPixels(style['border-top-width']) +
           cssValueToPixels(style['border-bottom-width']) +
           cssValueToPixels(style['padding-top']) +
           cssValueToPixels(style['padding-bottom']) +
           cssValueToPixels(style['height']);
  }

  /**
   *
   * @param elem
   */

  getOffset(HtmlElement elem) {
    Map offset = {
        'left': 0, 'top':0
    };
    if (elem.offsetParent != null) {
      do {
        offset['left'] += elem.offsetLeft;
        offset['top'] += elem.offsetTop;
        elem = elem.offsetParent;
      } while (elem != null);
    }
    return offset;
  }

  // http://stackoverflow.com/posts/2684561/revisions
  /**
   *
   * @param elem
   */

  isActive(HtmlElement elem) {
    return elem == document.activeElement;
  }

}
