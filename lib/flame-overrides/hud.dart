import 'package:flame/components/text_component.dart';
import 'package:flame/palette.dart';
import 'package:flame/text_config.dart';

class HudText extends TextComponent {
  static TextConfig regular = TextConfig(fontSize: 12, color: BasicPalette.black.withRed(128).color);
  HudText(String text, double _x, double _y) : super(text, config: regular) {
    x = _x;
    y = _y;
}


  @override
  bool isHud() {
    return true;
  }
}
