import "package:play_datgui/datgui.dart" as dat;

class FizzyText {
  String message;
  num speed;
  bool displayOutline;

  FizzyText(){
    this.message = 'dat.gui';
    this.speed = 0.8;
    this.displayOutline = false;
  }

//this.explode = function() { ... };
// Define render logic ...
}

main(){
  var text = new FizzyText();
  var gui = new dat.GUI();
  gui.add(text, 'message');
  gui.add(text, 'speed', [-5, 5]);
  gui.add(text, 'displayOutline');
  gui.add(text, 'explode');
}
