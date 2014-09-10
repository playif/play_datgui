part of datgui;


//CSS.inject(styleSheet);
/** Outer-most className for GUI's */
var CSS_NAMESPACE = 'dg';

var HIDE_KEY_CODE = 72;

/** The only value shared between the JS and SCSS. Use caution. */
var CLOSE_BUTTON_HEIGHT = 20;

var DEFAULT_DEFAULT_PRESET_NAME = 'Default';

var SUPPORTS_LOCAL_STORAGE = true;

var SAVE_DIALOGUE;

/** Have we yet to create an autoPlace GUI? */
var auto_place_virgin = true;

/** Fixed position div that auto place GUI's go inside */
var auto_place_container;

/** Are we hiding the GUI's ? */
bool hide = false;

/** GUI's which should be hidden */
List hideable_guis = [];

/**
 * A lightweight controller library for JavaScript. It allows you to easily
 * manipulate variables and fire functions on the fly.
 * @class
 *
 * @member dat.gui
 *
 * @param {Object} [params]
 * @param {String} [params.name] The name of this GUI.
 * @param {Object} [params.load] JSON object representing the saved state of
 * this GUI.
 * @param {Boolean} [params.auto=true]
 * @param {dat.gui.GUI} [params.parent] The GUI I'm nested in.
 * @param {Boolean} [params.closed] If true, starts closed
 */
class GUI {

  DivElement domElement;
  UListElement __ul;

  /// Nested GUI's by name
  Map __folders;
  List<Controller> __controllers;

  /// List of objects I'm remembering for save, only used in top level GUI
  List<Object> __rememberedObjects;

  /// Maps the index of remembered objects to a map of controllers, only used
  Map __rememberedObjectIndecesToControllers;


  List<Controller> __listening;

  DivElement __closeButton;

  Map params;

  DivElement title_row_name;

  GUI([Map params={
  }]) {

    this.params=params;


    /**
     * Outermost DOM Element
     * @type DOMElement
     */
    this.domElement = new DivElement();
    this.__ul = new UListElement();
    this.domElement.append(this.__ul);

    DOM.addClass(this.domElement, CSS_NAMESPACE);

    this.__folders = {
    };

    this.__controllers = [];

    this.__rememberedObjects = [];

    this.__rememberedObjectIndecesToControllers = [];

    this.__listening = [];


    params = Common.defaults(params, {
        'autoPlace': true,
        'width': GUI.DEFAULT_WIDTH
    });

    params = Common.defaults(params, {
        'resizable': params['autoPlace'],
        'hideable': params['autoPlace']
    });


    if (!params.containsKey('load')) {
      // Explicit preset
      if (params.containsKey(preset)) params['load']['preset'] = params['preset'];
    } else {
      params['load'] = {
          preset: DEFAULT_DEFAULT_PRESET_NAME
      };
    }

    if (params.containsKey(parent) && params.containsKey(hideable)) {
      hideable_guis.add(this);
    }

    // Only root level GUI's are resizable.
    params['resizable'] = params.containsKey(parent) && params['resizable'];


    if (params.containsKey(autoPlace) && params.containsKey('scrollable')) {
      params['scrollable'] = true;
    }
//    params.scrollable = common.isUndefined(params.parent) && params.scrollable === true;

    // Not part of params because I don't want people passing this in via
    // constructor. Should be a 'remembered' value.
    var use_local_storage =
    SUPPORTS_LOCAL_STORAGE &&
    window.localStorage.getItem(getLocalStorageHash(this, 'isLocal')) == 'true';

    var saveToLocalStorage;

    if (!params.containsKey(parent)) {

      params['closed'] = false;

      DOM.addClass(this.domElement, GUI.CLASS_MAIN);
      DOM.makeSelectable(this.domElement, false);

// Are we supposed to be loading locally?
      if (SUPPORTS_LOCAL_STORAGE) {

        if (use_local_storage) {

          this.useLocalStorage = true;

          var saved_gui = localStorage.getItem(getLocalStorageHash(this, 'gui'));

          if (saved_gui) {
            params['load'] = JSON.encode(saved_gui);
          }

        }

      }

      this.__closeButton = new DivElement();
      this.__closeButton.innerHtml = GUI.TEXT_CLOSED;
      DOM.addClass(this.__closeButton, GUI.CLASS_CLOSE_BUTTON);
      this.domElement.append(this.__closeButton);

      DOM.bind(this.__closeButton, 'click', (e) {
        this.closed = !this.closed;
      });


// Oh, you're a nested GUI!
    } else {

      if (params.containsKey('closed')) {
        params['closed'] = true;
      }

      title_row_name = document.createElement(params['name']);
      DOM.addClass(title_row_name, 'controller-name');

      var title_row = addRow(this, title_row_name);

      var on_click_title = (e) {
        e.preventDefault();
        this.closed = !this.closed;
        return false;
      };

      DOM.addClass(this.__ul, GUI.CLASS_CLOSED);

      DOM.addClass(title_row, 'title');
      DOM.bind(title_row, 'click', on_click_title);

      if (!params['closed']) {
        this.closed = false;
      }

    }

    if (params['autoPlace']) {

      if (params.containsKey('parent')) {

        if (auto_place_virgin) {
          auto_place_container = document.createElement('div');
          DOM.addClass(auto_place_container, CSS_NAMESPACE);
          DOM.addClass(auto_place_container, GUI.CLASS_AUTO_PLACE_CONTAINER);
          document.body.append(auto_place_container);
          auto_place_virgin = false;
        }

// Put it in the dom for you.
        auto_place_container.appendChild(this.domElement);

// Apply the auto styles
        DOM.addClass(this.domElement, GUI.CLASS_AUTO_PLACE);

      }


// Make it not elastic.
      if (this.parent == null) setWidth(this, params['width']);

    }

    DOM.bind(window, 'resize', (e) {
      this.onResize();
    });
    DOM.bind(this.__ul, 'webkitTransitionEnd', (e) {
      this.onResize();
    });
    DOM.bind(this.__ul, 'transitionend', (e) {
      this.onResize();
    });
    DOM.bind(this.__ul, 'oTransitionEnd', (e) {
      this.onResize();
    });
    this.onResize();


    if (params['resizable']) {
      addResizeHandle(this);
    }

    saveToLocalStorage = () {
      if (SUPPORTS_LOCAL_STORAGE && localStorage.getItem(getLocalStorageHash(_this, 'isLocal')) == 'true') {
        localStorage.setItem(getLocalStorageHash(_this, 'gui'), JSON.stringify(_this.getSaveObject()));
      }
    };

// expose this method publicly
    this.saveToLocalStorageIfPossible = saveToLocalStorage;

    var root = this.getRoot();

    resetWidth() {
      var root = this.getRoot();
      root.width += 1;
      Common.defer(() {
        root.width -= 1;
      });
    }

    if (params['parent'] == null) {
      resetWidth();
    }

    //};


    DOM.bind(window, 'keydown', (e) {

      if (document.activeElement.type != 'text' &&
          (e.which == HIDE_KEY_CODE || e.keyCode == HIDE_KEY_CODE)) {
        GUI.toggleHide();
      }

    }, false);

  }

  static toggleHide() {

    hide = !hide;
    Common.each(hideable_guis, (gui) {
      gui.domElement.style.zIndex = hide ? -999 : 999;
      gui.domElement.style.opacity = hide ? 0 : 1;
    });
  }


  static const String CLASS_AUTO_PLACE = 'a';
  static const String CLASS_AUTO_PLACE_CONTAINER = 'ac';
  static const String CLASS_MAIN = 'main';
  static const String CLASS_CONTROLLER_ROW = 'cr';
  static const String CLASS_TOO_TALL = 'taller-than-window';
  static const String CLASS_CLOSED = 'closed';
  static const String CLASS_CLOSE_BUTTON = 'close-button';
  static const String CLASS_DRAG = 'drag';

  static const String DEFAULT_WIDTH = 245;
  static const String TEXT_CLOSED = 'Close Controls';
  static const String TEXT_OPEN = 'Open Controls';

  /// The parent [GUI]
  GUI get parent {
    return params['parent'];
  }

  bool get scrollable {
    return params['scrollable'];
  }


  /// Handles [GUI]'s element placement for you
  bool get autoPlace {
    return params['autoPlace'];
  }

  /// The identifier for a set of saved values
  String get preset {
    if (this.parent) {
      return this.getRoot().preset;
    } else {
      return params['load'].preset;
    }
  }

  set preset(String v) {
    if (this.parent) {
      this.getRoot().preset = v;
    } else {
      params['load'].preset = v;
    }
    setPresetSelectIndex(this);
    this.revert();
  }


  /// The width of [GUI] element
  num get width {
    return params['width'];
  }

  set width(num v) {
    params['width'] = v;
    setWidth(this, v);
  }

  /// The name of GUI. Used for folders. i.e a folder's name
  String get name {
    return params['name'];
  }

  set name(String v) {
    // TODO Check for collisions among sibling folders
    params['name'] = v;
    if (title_row_name) {
      title_row_name.innerHtml = params['name'];
    }
  }

  //},

  /**
   * Whether the <code>GUI</code> is collapsed or not
   * @type Boolean
   */
  //osed: {

  get closed {
    return params['closed'];
  }

  set closed(v) {
    params['closed'] = v;
    if (params['closed']) {
      DOM.addClass(this.__ul, GUI.CLASS_CLOSED);
    } else {
      DOM.removeClass(this.__ul, GUI.CLASS_CLOSED);
    }
    // For browsers that aren't going to respect the CSS transition,
    // Lets just check our height against the window height right off
    // the bat.
    this.onResize();

    if (this.__closeButton) {
      this.__closeButton.innerHtml = v ? GUI.TEXT_OPEN : GUI.TEXT_CLOSED;
    }
  }

//}

  /**
   * Contains all presets
   * @type Object
   */
//load: {

  get load {
    return params['load'];
  }


  /**
   * Determines whether or not to use <a href="https://developer.mozilla.org/en/DOM/Storage#localStorage">localStorage</a> as the means for
   * <code>remember</code>ing
   * @type Boolean
   */
//useLocalStorage: {

  get useLocalStorage {
    return use_local_storage;
  }

  set useLocalStorage(bool) {
    if (SUPPORTS_LOCAL_STORAGE) {
      use_local_storage = bool;
      if (bool) {
        Dom.bind(window, 'unload', saveToLocalStorage);
      } else {
        Dom.unbind(window, 'unload', saveToLocalStorage);
      }
      localStorage.setItem(getLocalStorageHash(_this, 'isLocal'), bool);
    }
  }

//}

//});

// Are we a root level GUI?


//common.extend(

//GUI.prototype,

  /** @lends dat.gui.GUI */
//{

  /**
   * @param object
   * @param property
   * @returns {dat.controllers.Controller} The new controller that was added.
   * @instance
   */

  add(Object object, String property, [List args]) {

    return add(
        this,
        object,
        property,
        {
            factoryArgs: args
        }
    );

  }

  /**
   * @param object
   * @param property
   * @returns {dat.controllers.ColorController} The new controller that was added.
   * @instance
   */

  addColor(Object object, String property) {

    return add(
        this,
        object,
        property,
        {
            color: true
        }
    );
  }

  /**
   * @param controller
   * @instance
   */

  remove(Controller controller) {

// TODO listening?
    controller.__li.remove();
    this.__controllers.remove(controller);
    var _this = this;
    Common.defer(() {
      _this.onResize();
    });

  }

  destroy() {

    if (this.autoPlace) {
      auto_place_container.removeChild(this.domElement);
    }

  }

  /**
   * @param name
   * @returns {dat.gui.GUI} The new folder.
   * @throws {Error} if this GUI already has a folder by the specified
   * name
   * @instance
   */

  addFolder(String name) {

// We have to prevent collisions on names in order to have a key
// by which to remember saved values
    if (this.__folders[name] != null) {
      throw new Exception('You already have a folder in this GUI by the' +
                          ' name "' + name + '"');
    }

    var new_gui_params = {
        name: name, parent: this
    };

// We need to pass down the autoPlace trait so that we can
// attach event listeners to open/close folder actions to
// ensure that a scrollbar appears if the window is too short.
    new_gui_params.autoPlace = this.autoPlace;

// Do we have saved appearance data for this folder?

    if (this.load && // Anything loaded?
        this.load.folders && // Was my parent a dead-end?
        this.load.folders[name]) {
      // Did daddy remember me?

// Start me closed if I was closed
      new_gui_params.closed = this.load.folders[name].closed;

// Pass down the loaded data
      new_gui_params.load = this.load.folders[name];

    }

    var gui = new GUI(new_gui_params);
    this.__folders[name] = gui;

    var li = addRow(this, gui.domElement);
    DOM.addClass(li, 'folder');
    return gui;

  }

  open() {
    this.closed = false;
  }

  close() {
    this.closed = true;
  }

  onResize() {

    var root = this.getRoot();

    if (root.scrollable) {

      var top = DOM.getOffset(root.__ul).top;
      var h = 0;

      root.__ul.childNodes.forEach((node) {
        if (!(root.autoPlace && node == root.__save_row))
          h += DOM.getHeight(node);
      });

      if (window.innerHeight - top - CLOSE_BUTTON_HEIGHT < h) {
        DOM.addClass(root.domElement, GUI.CLASS_TOO_TALL);
        root.__ul.style.height = window.innerHeight - top - CLOSE_BUTTON_HEIGHT + 'px';
      } else {
        DOM.removeClass(root.domElement, GUI.CLASS_TOO_TALL);
        root.__ul.style.height = 'auto';
      }

    }

    if (root.__resize_handle) {
      Common.defer(() {
        root.__resize_handle.style.height = root.__ul.offsetHeight + 'px';
      });
    }

    if (root.__closeButton) {
      root.__closeButton.style.width = root.width + 'px';
    }

  }

  /**
   * Mark objects for saving. The order of these objects cannot change as
   * the GUI grows. When remembering new objects, append them to the end
   * of the list.
   *
   * @param {Object...} objects
   * @throws {Error} if not called on a top level GUI.
   * @instance
   */

  remember() {

    if (Common.isUndefined(SAVE_DIALOGUE)) {
      SAVE_DIALOGUE = new CenteredDiv();
      SAVE_DIALOGUE.domElement.innerHTML = saveDialogueContents;
    }

    if (this.parent) {
      throw new Error("You can only call remember on a top level GUI.");
    }

    var _this = this;

    Common.each(Array.prototype.slice.call(arguments), (object) {
      if (_this.__rememberedObjects.length == 0) {
        addSaveMenu(_this);
      }
      if (_this.__rememberedObjects.indexOf(object) == -1) {
        _this.__rememberedObjects.add(object);
      }
    });

    if (this.autoPlace) {
// Set save row width
      setWidth(this, this.width);
    }

  }

  /**
   * @returns {dat.gui.GUI} the topmost parent GUI of a nested GUI.
   * @instance
   */

  GUI getRoot() {
    var gui = this;
    while (gui.parent) {
      gui = gui.parent;
    }
    return gui;
  }

  /**
   * @returns {Object} a JSON object representing the current state of
   * this GUI as well as its remembered properties.
   * @instance
   */

  getSaveObject() {

    var toReturn = this.load;

    toReturn.closed = this.closed;

// Am I remembering any values?
    if (this.__rememberedObjects.length > 0) {

      toReturn.preset = this.preset;

      if (!toReturn.remembered) {
        toReturn.remembered = {
        };
      }

      toReturn.remembered[this.preset] = getCurrentPreset(this);

    }

    toReturn.folders = {
    };
    Common.each(this.__folders, (element, key) {
      toReturn.folders[key] = element.getSaveObject();
    });

    return toReturn;

  }

  save() {

    if (!this.load.remembered) {
      this.load.remembered = {
      };
    }

    this.load.remembered[this.preset] = getCurrentPreset(this);
    markPresetModified(this, false);
    this.saveToLocalStorageIfPossible();

  }

  saveAs(presetName) {

    if (!this.load.remembered) {

// Retain default values upon first save
      this.load.remembered = {
      };
      this.load.remembered[DEFAULT_DEFAULT_PRESET_NAME] = getCurrentPreset(this, true);

    }

    this.load.remembered[presetName] = getCurrentPreset(this);
    this.preset = presetName;
    addPresetOption(this, presetName, true);
    this.saveToLocalStorageIfPossible();

  }

  revert([GUI gui]) {

    Common.each(this.__controllers, (controller) {
// Make revert work on Default.
      if (!this.getRoot().load.remembered) {
        controller.setValue(controller.initialValue);
      } else {
        recallSavedValue(gui || this.getRoot(), controller);
      }
    });

    Common.each(this.__folders, (folder) {
      folder.revert(folder);
    });

    if (gui == null) {
      markPresetModified(this.getRoot(), false);
    }


  }

  listen(Controller controller) {

    bool init = this.__listening.length == 0;
    this.__listening.add(controller);
    if (init) updateDisplays(this.__listening);

  }

}

//);

add(GUI gui, object, property, [params]) {

  if (object[property] == undefined) {
    throw new Exception("Object " + object + " has no property \"" + property + "\"");
  }

  var controller;

  if (params.color) {

    controller = new ColorController(object, property);

  } else {

    var factoryArgs = [object, property].concat(params.factoryArgs);
    controller = controllerFactory.apply(gui, factoryArgs);

  }

  if (params.before is Controller) {
    params.before = params.before.__li;
  }

  recallSavedValue(gui, controller);

  DOM.addClass(controller.domElement, 'c');

  var name = document.createElement('span');
  DOM.addClass(name, 'property-name');
  name.innerHTML = controller.property;

  var container = document.createElement('div');
  container.appendChild(name);
  container.appendChild(controller.domElement);

  var li = addRow(gui, container, params.before);

  DOM.addClass(li, GUI.CLASS_CONTROLLER_ROW);
  DOM.addClass(li, controller.getValue());

  augmentController(gui, li, controller);

  gui.__controllers.add(controller);

  return controller;

}

/**
 * Add a row to the end of the GUI or before another row.
 *
 * @param gui
 * @param [dom] If specified, inserts the dom content in the new row
 * @param [liBefore] If specified, places the new row before another row
 */

addRow(GUI gui, HtmlElement dom, [liBefore]) {
  LIElement li = new LIElement();

  if (dom) li.append(dom);
  if (liBefore) {
    gui.__ul.insertBefore(li, params['before']);
  } else {
    gui.__ul.append(li);
  }
  gui.onResize();
  return li;
}

augmentController(gui, li, controller) {

  controller.__li = li;
  controller.__gui = gui;

  Common.extend(controller, {

      options: (options) {

        if (arguments.length > 1) {
          controller.remove();

          return add(
              gui,
              controller.object,
              controller.property,
              {
                  before: controller.__li.nextElementSibling,
                  factoryArgs: [Common.toArray(arguments)]
              }
          );

        }

        if (Common.isArray(options) || Common.isObject(options)) {
          controller.remove();

          return add(
              gui,
              controller.object,
              controller.property,
              {
                  before: controller.__li.nextElementSibling,
                  factoryArgs: [options]
              }
          );

        }

      },

      name: (v) {
        controller.__li.firstElementChild.firstElementChild.innerHTML = v;
        return controller;
      },

      listen: () {
        controller.__gui.listen(controller);
        return controller;
      },

      remove: () {
        controller.__gui.remove(controller);
        return controller;
      }

  });

  // All sliders should be accompanied by a box.
  if (controller is NumberControllerSlider) {

    NumberControllerBox box = new NumberControllerBox(controller.object, controller.property,
    {
        'min': controller.__min, 'max': controller.__max, 'step': controller.__step
    });

    Common.each(['updateDisplay', 'onChange', 'onFinishChange'], (method) {
      var pc = controller[method];
      var pb = box[method];
      controller[method] = box[method] = () {
        var args = Array.prototype.slice.call(arguments);
        pc.apply(controller, args);
        return pb.apply(box, args);
      };
    });

    DOM.addClass(li, 'has-slider');
    controller.domElement.insertBefore(box.domElement, controller.domElement.firstElementChild);

  }
  else if (controller is NumberControllerBox) {

    var r = (returned) {

      // Have we defined both boundaries?
      if (Common.isNumber(controller.__min) && Common.isNumber(controller.__max)) {

        // Well, then lets just replace this with a slider.
        controller.remove();
        return add(
            gui,
            controller.object,
            controller.property,
            {
                before: controller.__li.nextElementSibling,
                factoryArgs: [controller.__min, controller.__max, controller.__step]
            });

      }

      return returned;

    };

    controller.min = Common.compose(r, controller.min);
    controller.max = Common.compose(r, controller.max);

  }
  else if (controller is BooleanController) {

      DOM.bind(li, 'click', () {
        DOM.fakeEvent(controller.__checkbox, 'click');
      });

      DOM.bind(controller.__checkbox, 'click', (e) {
        e.stopPropagation();
        // Prevents double-toggle
      });

    }
    else if (controller is FunctionController) {

        DOM.bind(li, 'click', () {
          DOM.fakeEvent(controller.__button, 'click');
        });

        DOM.bind(li, 'mouseover', () {
          DOM.addClass(controller.__button, 'hover');
        });

        DOM.bind(li, 'mouseout', () {
          DOM.removeClass(controller.__button, 'hover');
        });

      }
      else if (controller is ColorController) {

          DOM.addClass(li, 'color');
          controller.updateDisplay = Common.compose((r) {
            li.style.borderLeftColor = controller.__color.toString();
            return r;
          }, controller.updateDisplay);

          controller.updateDisplay();

        }

  controller.setValue = Common.compose((r) {
    if (gui.getRoot().__preset_select && controller.isModified()) {
      markPresetModified(gui.getRoot(), true);
    }
    return r;
  }, controller.setValue);

}

recallSavedValue(GUI gui, Controller  controller) {

  // Find the topmost GUI, that's where remembered objects live.
  var root = gui.getRoot();

  // Does the object we're controlling match anything we've been told to
  // remember?
  var matched_index = root.__rememberedObjects.indexOf(controller.object);

  // Why yes, it does!
  if (matched_index != -1) {

    // Let me fetch a map of controllers for thcommon.isObject.
    var controller_map =
    root.__rememberedObjectIndecesToControllers[matched_index];

    // Ohp, I believe this is the first controller we've created for this
    // object. Lets make the map fresh.
    if (controller_map == null) {
      controller_map = {
      };
      root.__rememberedObjectIndecesToControllers[matched_index] =
      controller_map;
    }

    // Keep track of this controller
    controller_map[controller.property] = controller;

    // Okay, now have we saved any values for this controller?
    if (root.load && root.load.remembered) {

      var preset_map = root.load.remembered;

      // Which preset are we trying to load?
      var preset;

      if (preset_map[gui.preset]) {

        preset = preset_map[gui.preset];

      } else if (preset_map[DEFAULT_DEFAULT_PRESET_NAME]) {

        // Uhh, you can have the default instead?
        preset = preset_map[DEFAULT_DEFAULT_PRESET_NAME];

      } else {

        // Nada.

        return;

      }


      // Did the loaded object remember thcommon.isObject?
      if (preset[matched_index] &&

          // Did we remember this particular property?
          preset[matched_index][controller.property] != undefined) {

        // We did remember something for this guy ...
        var value = preset[matched_index][controller.property];

        // And that's what it is.
        controller.initialValue = value;
        controller.setValue(value);

      }

    }

  }

}

getLocalStorageHash(GUI gui, String key) {
  // TODO how does this deal with multiple GUI's?
  return document.location.href + '.' + key;

}

addSaveMenu(GUI gui) {

  var div = gui.__save_row = document.createElement('li');

  DOM.addClass(gui.domElement, 'has-save');

  gui.__ul.insertBefore(div, gui.__ul.firstChild);

  DOM.addClass(div, 'save-row');

  var gears = document.createElement('span');
  gears.innerHTML = '&nbsp;';
  DOM.addClass(gears, 'button gears');

  // TODO replace with FunctionController
  var button = document.createElement('span');
  button.innerHTML = 'Save';
  DOM.addClass(button, 'button');
  DOM.addClass(button, 'save');

  var button2 = document.createElement('span');
  button2.innerHTML = 'New';
  DOM.addClass(button2, 'button');
  DOM.addClass(button2, 'save-as');

  var button3 = document.createElement('span');
  button3.innerHTML = 'Revert';
  DOM.addClass(button3, 'button');
  DOM.addClass(button3, 'revert');

  var select = gui.__preset_select = document.createElement('select');

  if (gui.load && gui.load.remembered) {

    Common.each(gui.load.remembered, (value, key) {
      addPresetOption(gui, key, key == gui.preset);
    });

  } else {
    addPresetOption(gui, DEFAULT_DEFAULT_PRESET_NAME, false);
  }

  DOM.bind(select, 'change', () {


    for (var index = 0; index < gui.__preset_select.length; index++) {
      gui.__preset_select[index].innerHTML = gui.__preset_select[index].value;
    }

    gui.preset = this.value;

  });

  div.appendChild(select);
  div.appendChild(gears);
  div.appendChild(button);
  div.appendChild(button2);
  div.appendChild(button3);

  if (SUPPORTS_LOCAL_STORAGE) {

    var saveLocally = document.getElementById('dg-save-locally');
    var explain = document.getElementById('dg-local-explain');

    saveLocally.style.display = 'block';

    var localStorageCheckBox = document.getElementById('dg-local-storage');

    if (localStorage.getItem(getLocalStorageHash(gui, 'isLocal')) == 'true') {
      localStorageCheckBox.setAttribute('checked', 'checked');
    }

    showHideExplain() {
      explain.style.display = gui.useLocalStorage ? 'block' : 'none';
    }

    showHideExplain();

    // TODO: Use a boolean controller, fool!
    DOM.bind(localStorageCheckBox, 'change', () {
      gui.useLocalStorage = !gui.useLocalStorage;
      showHideExplain();
    });

  }

  var newConstructorTextArea = document.getElementById('dg-new-constructor');

  DOM.bind(newConstructorTextArea, 'keydown', (e) {
    if (e.metaKey && (e.which == 67 || e.keyCode == 67)) {
      SAVE_DIALOGUE.hide();
    }
  });

  DOM.bind(gears, 'click', () {
    newConstructorTextArea.innerHTML = JSON.stringify(gui.getSaveObject(), undefined, 2);
    SAVE_DIALOGUE.show();
    newConstructorTextArea.focus();
    newConstructorTextArea.select();
  });

  DOM.bind(button, 'click', () {
    gui.save();
  });

  DOM.bind(button2, 'click', () {
    var presetName = prompt('Enter a new preset name.');
    if (presetName) gui.saveAs(presetName);
  });

  DOM.bind(button3, 'click', () {
    gui.revert();
  });

//    div.appendChild(button2);

}

addResizeHandle(gui) {

  gui.__resize_handle = document.createElement('div');

  Common.extend(gui.__resize_handle.style, {

      width: '6px',
      marginLeft: '-3px',
      height: '200px',
      cursor: 'ew-resize',
      position: 'absolute'
//      border: '1px solid blue'

  });

  var pmouseX;

  DOM.bind(gui.__resize_handle, 'mousedown', dragStart);
  DOM.bind(gui.__closeButton, 'mousedown', dragStart);

  gui.domElement.insertBefore(gui.__resize_handle, gui.domElement.firstElementChild);

  dragStart(e) {

    e.preventDefault();

    pmouseX = e.clientX;

    DOM.addClass(gui.__closeButton, GUI.CLASS_DRAG);
    DOM.bind(window, 'mousemove', drag);
    DOM.bind(window, 'mouseup', dragStop);

    return false;

  }

  drag(e) {

    e.preventDefault();

    gui.width += pmouseX - e.clientX;
    gui.onResize();
    pmouseX = e.clientX;

    return false;

  }

  dragStop() {
    DOM.removeClass(gui.__closeButton, GUI.CLASS_DRAG);
    DOM.unbind(window, 'mousemove', drag);
    DOM.unbind(window, 'mouseup', dragStop);
  }

}

setWidth(GUI gui, w) {
  gui.domElement.style.width = w + 'px';
  // Auto placed save-rows are position fixed, so we have to
  // set the width manually if we want it to bleed to the edge
  if (gui.__save_row && gui.autoPlace) {
    gui.__save_row.style.width = w + 'px';
  }
  if (gui.__closeButton) {
    gui.__closeButton.style.width = w + 'px';
  }
}

getCurrentPreset(GUI gui, [bool useInitialValues=true]) {

  var toReturn = {
  };

  // For each object I'm remembering
  Common.each(gui.__rememberedObjects, (val, index) {

    var saved_values = {
    };

    // The controllers I've made for thcommon.isObject by property
    var controller_map =
    gui.__rememberedObjectIndecesToControllers[index];

    // Remember each value for each property
    Common.each(controller_map, (controller, property) {
      saved_values[property] = useInitialValues ? controller.initialValue : controller.getValue();
    });

    // Save the values for thcommon.isObject
    toReturn[index] = saved_values;

  });

  return toReturn;

}

addPresetOption(GUI gui, String name, setSelected) {
  var opt = document.createElement('option');
  opt.innerHTML = name;
  opt.value = name;
  gui.__preset_select.appendChild(opt);
  if (setSelected) {
    gui.__preset_select.selectedIndex = gui.__preset_select.length - 1;
  }
}

setPresetSelectIndex(GUI gui) {
  for (var index = 0; index < gui.__preset_select.length; index++) {
    if (gui.__preset_select[index].value == gui.preset) {
      gui.__preset_select.selectedIndex = index;
    }
  }
}

markPresetModified(GUI gui, modified) {
  var opt = gui.__preset_select[gui.__preset_select.selectedIndex];
//    console.log('mark', modified, opt);
  if (modified) {
    opt.innerHTML = opt.value + "*";
  } else {
    opt.innerHTML = opt.value;
  }
}

updateDisplays(List controllerArray) {
  if (controllerArray.length != 0) {
    window.requestAnimationFrame((dt) {
      updateDisplays(controllerArray);
    });
  }

  controllerArray.forEach((c) {
    c.updateDisplay();
  });
}

