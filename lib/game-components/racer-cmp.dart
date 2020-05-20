import 'dart:ui';

import 'package:box2d_flame/box2d.dart';
import 'package:flame/anchor.dart';
import 'package:flame/animation.dart' as flame_anim;
import 'package:flame/components/component.dart';
import 'package:flame/spritesheet.dart';
import 'package:flutter/cupertino.dart';

import '../racer.dart';
import 'controllers/npc-ctrl.dart';



class RacerCmp extends PositionComponent {
  flame_anim.Animation walkAnimation;
  final world;
  Racer racer;
  final List<Vector2> breadCrumbs;
  NpcController controller;
  Vector2 get heading => racer.forwardNormal;


  RacerCmp(SpriteSheet spriteSheet, breadCrumbs_, this.world) :
      breadCrumbs = pointCleaner(breadCrumbs_, 5 )
  {

    walkAnimation = spriteSheet.createAnimation(0, stepTime: .05);

    final startPos = breadCrumbs.first;
    width = 32;
    height = 32;
    x = startPos.x.toDouble();
    y = startPos.y.toDouble() ;
    anchor = Anchor.center;

    racer = Racer(world);
    controller = NpcController(breadCrumbs, racer);
    racer.controller = controller;
    racer.setPositionAndRotation(startPos.x, startPos.y, 0);

  }

  @override
  void update(double dt) {
    if (!loaded()) return;

    controller.update(dt);
    racer.update(dt);

    x = racer.pxPosition.x;
    y = racer.pxPosition.y;
    angle = racer.angle;

    super.update(dt);
    walkAnimation.update(dt);
  }

    @override
  void render(Canvas c) {

     prepareCanvas(c);
     walkAnimation.getSprite().render(c,
          width: width, height: height);
    }

    @override
    bool loaded() {
      return walkAnimation.loaded()  && x != null && y != null;
    }
}

List<Vector2> pointCleaner(List<Vector2> points, double minThreshold) {

  final List<Vector2> result = List();

  points.forEach((p) {
    if(result.length == 0) {
      result.add(p);
    } else {
      if (p.distanceTo(result.last) > minThreshold ) {
        result.add(p);
      }
    }
  });

  return result;

}
