import 'package:box2d_flame/box2d.dart';
import 'package:flame/components/component.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flame/spritesheet.dart';
import 'package:flame/text_config.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:xc_arcade/flame-overrides/tdc.dart';

import 'game-components/course-cmp.dart';
import 'game-components/racer-cmp.dart';
import 'units.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final Size size = await Flame.util.initialDimensions();

  final String content = await Flame.assets.readFile('tiles/winter.tsx');

  final game = MyGame(TSMP(content));
  runApp(game.widget);
}

class MyGame extends BaseGame with /*PanDetector, */ ScaleDetector {
  Offset lastTouch = Offset.zero;
  double scale = 1.0;

  RacerCmp player;
  MyTiledComponent tc;

  World world;

  double cameraRotation = 0;
  double targetCameraRotation = 0;

  bool debugMode() => false;

  MyGame(tsp) {
    world = World.withPool(Vector2.zero(), DefaultWorldPool(100, 10));
    tc = MyTiledComponent('track2.tmx', tsp);

    ///world.debugDraw = CanvasDraw();
    add(tc);
  }

  @override
  void update(dt) {
    if (player == null && tc.loaded()) {
      final geoMeta = tc.map.objectGroups.firstWhere((e) => e.name == 'geo');
      final bc = geoMeta.tmxObjects.firstWhere((e) => e.name == 'breadcrumbs');
      final ss = SpriteSheet(imageName: 'walker0.png', textureWidth: 64, textureHeight: 64, columns: 8, rows: 1);
      final sss = [
        SpriteSheet(imageName: 'walker1.png', textureWidth: 64, textureHeight: 64, columns: 8, rows: 1),
        SpriteSheet(imageName: 'walker2.png', textureWidth: 64, textureHeight: 64, columns: 8, rows: 1),
        SpriteSheet(imageName: 'walker3.png', textureWidth: 64, textureHeight: 64, columns: 8, rows: 1),
        SpriteSheet(imageName: 'walker4.png', textureWidth: 64, textureHeight: 64, columns: 8, rows: 1),
        SpriteSheet(imageName: 'walker5.png', textureWidth: 64, textureHeight: 64, columns: 8, rows: 1)
      ];

      player = RacerCmp(
          ss,
          bc.points
              .map((p) => Vector2(bc.x.toDouble() + p.x.toDouble(), bc.y.toDouble() + p.y.toDouble()) * METERS)
              .toList(),
          world);
      add(player);
      player.width = 48;
      player.height = 48;

      for (int i = 1; i <= 100; i++)
        add(RacerCmp(
            sss[i % 5],
            bc.points
                .map((p) =>
                    Vector2(bc.x.toDouble() + p.x.toDouble() + 2.0 * i, bc.y.toDouble() + p.y.toDouble()) * METERS)
                .toList(),
            world));

      add(CourseCmp(geoMeta, world));
    }

    if (player != null) {
      camera.x = player.x;
      camera.y = player.y;

      final double b = (player.heading == null) ? 0 : player.heading.angleToSigned(Vector2(0, -1));
      targetCameraRotation = b;
    }

    world.stepDt(dt, 10, 10);

    ///world.clearForces();
    super.update(dt);

    final baseDiff = targetCameraRotation - cameraRotation,
        diff360 = 360 * DEGREES - baseDiff,
        diff = (baseDiff.abs() < diff360.abs()) ? baseDiff : diff360;

    final dir = diff.sign;
    final mag = diff.abs();
    double step = 0;
    if (mag > 45 * DEGREES) {
      step = .1;
    } else if (mag > 20 * DEGREES) {
      step = 0.05;
    } else if (mag > 10 * DEGREES) {
      step = 0.025;
    } else if (mag > 2 * DEGREES) {
      step = 0.00125;
    } else {
      step = 0;
      //dcameraRotation = targetCameraRotation;
    }

    cameraRotation = cameraRotation + dir * step / 5;
  }

  final xxx = const TextConfig(color: const Color(0xFF0000FF));

  @override
  void render(Canvas canvas) {
    canvas.save();
    if (player != null) {
      canvas.translate(size.width / 2, size.height / 2);
      canvas.rotate(cameraRotation);
      canvas.translate(-size.width / 2, -size.height / 2);
    }

    canvas.save();
    components.forEach((comp) => renderComponent(canvas, comp));
    canvas.restore();
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
  void onTapDown(TapDownDetails details) {
    //player.onTap();
  }

  @override
  void onScaleStart(ScaleStartDetails details) {
    lastTouch = details.focalPoint;
    print(details);
  }

  @override
  void onScaleUpdate(ScaleUpdateDetails details) {
    if (details.scale == 1.0) {
      /*  Offset dir = details.focalPoint - lastTouch;
      final travelX = dir.dx.sign;
      final travelY = dir.dy.sign;
      camera += flame_pos.Position(5* travelX ,5 * travelY );
      lastTouch = details.focalPoint;*/
    } else {
      print("Scale: ${details.scale}");
      scale = details.scale;
    }
  }
}
