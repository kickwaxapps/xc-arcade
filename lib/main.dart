import 'package:box2d_flame/box2d.dart';
import 'package:flame/components/component.dart';
import 'package:flame/components/text_component.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flame/spritesheet.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:xc_arcade/flame-overrides/hud.dart';
import 'package:xc_arcade/flame-overrides/tdc.dart';
import 'package:xc_arcade/game-components/controllers/controller.dart';
import 'package:xc_arcade/game-components/controllers/player-ctrl.dart';
import 'package:xc_arcade/game-components/meter-cmp.dart';

import 'game-components/course-cmp.dart';
import 'game-components/racer-cmp.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final Size size = await Flame.util.initialDimensions();

  final String content = await Flame.assets.readFile('tiles/winter.tsx');

  final game = MyGame(TSMP(content));
  runApp(game.widget);
}

class MyGame extends BaseGame with MultiTouchDragDetector, MultiTouchDragDetector {
  Offset lastTouch = Offset.zero;
  double scale = 1.0;

  RacerCmp player;
  MyTiledComponent tc;

  TextComponent _dist;
  TextComponent _playerDist;
  TextComponent _playerLapSplit;
  TextComponent _playerLap;
  MeterCmp _meterCmp;
  World world;

  double cameraRotation = 0;
  double targetCameraRotation = 0;

  CourseCmp course;

  Technique gestureTechnique = Technique.NONE;

  Steering gestureSteering = Steering.none;

  bool debugMode() => false;

  MyGame(tsp) {
    world = World.withPool(Vector2.zero(), DefaultWorldPool(100, 10));
    tc = MyTiledComponent('track2.tmx', tsp);

    _dist = HudText('What', 20, 50);
    _playerDist = HudText('What', 0, 10);
//    _playerLapSplit = HudText('What', ,55);
    _playerLap = HudText('What', 0, 10);

    add(_dist);
    add(_playerDist);
    add(_playerLap);

    final x = MeterCmp();

    _meterCmp = x;
    add(x);

    ///world.debugDraw = CanvasDraw();
    add(tc);

    Flame.audio.loadAll(['dp-hit.wav', 'dp-miss.wav']);
  }

  @override
  void update(dt) {
    if (player == null && tc.loaded()) {
      final List courseGeoObjects = tc.map.objectGroups.firstWhere((e) => e.name == 'geo').tmxObjects;
      course = CourseCmp(courseGeoObjects, world);

      final ss = SpriteSheet(imageName: 'sp.png', textureWidth: 64, textureHeight: 64, columns: 4, rows: 1);
      final dp = SpriteSheet(imageName: 'dp.png', textureWidth: 64, textureHeight: 64, columns: 6, rows: 1);
      //   final tk = SpriteSheet(imageName: 'tk.png', textureWidth: 64, textureHeight: 64, columns: 1, rows: 1);

      final sss = [
        SpriteSheet(imageName: 'walker1.png', textureWidth: 64, textureHeight: 64, columns: 8, rows: 1),
        SpriteSheet(imageName: 'walker2.png', textureWidth: 64, textureHeight: 64, columns: 8, rows: 1),
        SpriteSheet(imageName: 'walker3.png', textureWidth: 64, textureHeight: 64, columns: 8, rows: 1),
        SpriteSheet(imageName: 'walker4.png', textureWidth: 64, textureHeight: 64, columns: 8, rows: 1),
        SpriteSheet(imageName: 'walker5.png', textureWidth: 64, textureHeight: 64, columns: 8, rows: 1)
      ];

      player = RacerCmp(ss, course, world, doublePole: dp, isPlayer: true);
      add(player);
      player.width = 32;
      player.height = 32;

      for (int i = 1; i <= 3; i++) add(RacerCmp(sss[i % 5], course, world, isPlayer: false));

      add(course);

      _meterCmp.x = size.width / 2 + 10;
      _meterCmp.y = size.height / 2 - 10;
      _meterCmp.height = 75;
      _meterCmp.width = 20;
      _dist.text = 'Course Length ${course.length.toStringAsFixed(2)}m';
    }

    if (player == null) {
      return;
    }

    player.controller.setInputSteering(gestureSteering);
    _playerDist.text = 'Player: ' + player.courseProgress.toStringAsFixed(1) + 'm';
    _playerLap.text = 'Lap ${(player.courseProgress / course.length).floor() + 1}';
    camera.x = player.x;
    camera.y = player.y;

    world.stepDt(dt, 10, 10);
    super.update(dt);

    cameraRotation = player.heading.angleToSigned(Vector2(0, -1));
  }

  @override
  void render(Canvas canvas) {
    canvas.save();
    if (player != null) {
      canvas.translate(size.width / 2, size.height / 2);
      canvas.rotate(cameraRotation);
      canvas.translate(-size.width / 2, -size.height / 2);
    }

    canvas.save();
    components.where((e) => !e.isHud()).forEach((comp) => renderComponent(canvas, comp));
    canvas.restore();
    canvas.restore();
    components.where((e) => e.isHud()).forEach((comp) => comp.render(canvas));
  }

  /// This renders a single component obeying BaseGame rules.
  ///
  /// It translates the camera unless hud, call the render method and restore the canvas.
  /// This makes sure the canvas is not messed up by one component and all components render independently.
  void renderComponent(Canvas canvas, Component c) {
    if (!c.loaded()) {
      return;
    }
    if (!c.isHud()) {
      if (player != null) {
        final px = -player.x - 16;
        final py = -player.y - 16;
        final x = px + size.width / 2;
        final y = py + size.height / 2;
        canvas.translate(x, y);
      }
    }

    c.render(canvas);
    canvas.restore();
    canvas.save();
  }

  @override
  onReceiveDrag(DragEvent drag) {
    drag.onUpdate = onDragUpdate;
    drag.onEnd = onDragEnd;
    gestureTechnique = Technique.NONE;
    gestureSteering = Steering.none;
  }

  void onDragUpdate(DragUpdateDetails updateDetails) {
    if (updateDetails.globalPosition.dy < size.height / 2) {
      gestureSteering = updateDetails.delta.dx > 0 ? Steering.slightRight : Steering.slightLeft;
      return;
    }

    if (gestureTechnique != Technique.NONE) {
      return;
    }

    if (updateDetails.delta.dx.abs() > updateDetails.delta.dy.abs()) {
      gestureTechnique = Technique.SKATE_1;
    } else {
      startDoublePoleInput();
    }
  }

  void onDragEnd(DragEndDetails endDetails) {
    if (gestureTechnique == Technique.DOUBLE_POLE) {
      endDoublePoleInput();
    }
    gestureTechnique = Technique.NONE;
    gestureSteering = Steering.none;
  }

  @override
  void onTapDown(int pointerId, TapDownDetails details) {
    //  print('Tap $pointerId');
    super.onTap(pointerId);
  }

  void startDoublePoleInput() {
    gestureTechnique = Technique.DOUBLE_POLE;
    (player.controller as PlayerController).doDoublePoleInput(250);
    _meterCmp.start(1, .75, .9);
  }

  void endDoublePoleInput() {
    final factor = _meterCmp.end();
    if (factor == 1) {
      (player.controller as PlayerController).doDoublePoleInput(1000);
    }
  }
}
