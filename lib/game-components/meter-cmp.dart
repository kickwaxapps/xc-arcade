import 'dart:ui';

import 'package:flame/components/component.dart';
import 'package:flame/palette.dart';

enum Stroke {Power, Recovery}

class MeterCmp extends PositionComponent {

  Paint paint = BasicPalette.white.withBlue(128).paint;

  Paint fillPaint = BasicPalette.black.withRed(255).withAlpha(128).paint;
  Paint zonePaint = BasicPalette.black.withGreen(128).paint;

  final double minValue = 0;
  final double maxValue = 1;

  Stroke stroke = Stroke.Power;

  double  minPowerZone = .75;
  double  maxPowerZone = .90;

  double  minRecoveryZone = .0;
  double  maxRecoveryZone = .25;

  double energy = 1;
  double energyTime = 20;
  double recoveryTime = 10;


  double value = .75;

  double renderValue = 0;

  bool get inPowerZone => renderValue >= minPowerZone && renderValue <= maxPowerZone;
  bool get inRecoveryZone => renderValue >= minRecoveryZone && renderValue <= maxRecoveryZone;

  void update(double dt) {

    final delta = (value - renderValue) * .1;
    stroke = delta > 0 ? Stroke.Power : Stroke.Recovery;
    renderValue = renderValue + delta;
  }

  @override
  void render(Canvas c) {

    final drawZone = (double min, double max) {
      final r = Rect.fromLTWH(x+2, y+2+(height-2)*min, (width-2*2) , (height-2)*(max - min));
    c.drawRect(r, zonePaint);
    };

    Rect r = Rect.fromLTWH(x, y, width, height);
    c.drawRect(r, paint);
    drawZone(minPowerZone, maxPowerZone);
    drawZone(minRecoveryZone, maxRecoveryZone);

    r = Rect.fromLTWH(x+2, y+2, (width-2*2), (height-2)*renderValue);
    c.drawRect(r, fillPaint);
  }

  bool isHud() {
    return true;
  }

  void start(double v, f, t) {
    value = v;
    doResponse(inRecoveryZone);
  }

  double  end() {
    value = 0;
    doResponse(inPowerZone);

    return stroke == Stroke.Power && inPowerZone || stroke == Stroke.Recovery && inRecoveryZone ? 1 : .25;
  }

  void doResponse(success) {
    if ( success) {
      energy  *= .99;
    //  Flame.audio.play('dp-hit.wav');
    }
    else
    {
      energy  *= .90;
      //Flame.audio.play('dp-miss.wav');
    }
  }



}