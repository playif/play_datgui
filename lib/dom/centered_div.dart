part of datgui;

class CenteredDiv {
  DivElement backgroundElement,domElement;

  CenteredDiv() {
    this.backgroundElement = new DivElement();
    this.backgroundElement.style
    ..backgroundColor='rgba(0,0,0,0.8)'
    ..top=0
    ..left=0
    ..display='none'
    ..zIndex='1000'
    ..opacity=0
    ..transition='opacity 0.2s linear';


    DOM.makeFullscreen(this.backgroundElement);
    this.backgroundElement.style.position = 'fixed';

    this.domElement = new DivElement();
    this.domElement.style
    ..position='fixed'
    ..display='none'
    ..zIndex='1001'
    ..opacity=0
    ..transition='transform 0.2s ease-out, opacity 0.2s linear';


    document.body.append(this.backgroundElement);
    document.body.append(this.domElement);

    var _this = this;
    DOM.bind(this.backgroundElement, 'click', (e) {
    _this.hide();
    });
  }

  show () {

    var _this = this;



    this.backgroundElement.style.display = 'block';

    this.domElement.style.display = 'block';
    this.domElement.style.opacity = 0;
//    this.domElement.style.top = '52%';
    this.domElement.style.transform = 'scale(1.1)';

    this.layout();

    common.defer(() {
    _this.backgroundElement.style.opacity = 1;
    _this.domElement.style.opacity = 1;
    _this.domElement.style.webkitTransform = 'scale(1)';
    });

  }

  hide () {

    var _this = this;

    Function hide = (e) {

      _this.domElement.style.display = 'none';
      _this.backgroundElement.style.display = 'none';

      DOM.unbind(_this.domElement, 'webkitTransitionEnd', hide);
      DOM.unbind(_this.domElement, 'transitionend', hide);
      DOM.unbind(_this.domElement, 'oTransitionEnd', hide);

    };

    DOM.bind(this.domElement, 'webkitTransitionEnd', hide);
    DOM.bind(this.domElement, 'transitionend', hide);
    DOM.bind(this.domElement, 'oTransitionEnd', hide);

    this.backgroundElement.style.opacity = 0;
//    this.domElement.style.top = '48%';
    this.domElement.style.opacity = 0;
    this.domElement.style.webkitTransform = 'scale(1.1)';

  }

  layout() {
    this.domElement.style.left = window.innerWidth/2 - DOM.getWidth(this.domElement) / 2 + 'px';
    this.domElement.style.top = window.innerHeight/2 - DOM.getHeight(this.domElement) / 2 + 'px';
  }

  lockScroll(e) {
    window.console.log(e);
  }


}
