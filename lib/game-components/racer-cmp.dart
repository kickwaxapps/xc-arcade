import 'dart:math';
import 'dart:ui';

import 'package:box2d_flame/box2d.dart';
import 'package:flame/anchor.dart';
import 'package:flame/animation.dart' as flame_anim;
import 'package:flame/components/component.dart';
import 'package:flame/spritesheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:xc_arcade/game-components/controllers/controller.dart';
import 'package:xc_arcade/game-components/controllers/player-ctrl.dart';

import '../racer.dart';
import 'controllers/npc-ctrl.dart';
import 'race-cmp.dart';


enum RacerMode {
  START_LINE,
  RACING,
  FINISHED
}

class RacerCmp extends PositionComponent {

  bool done = false;
  flame_anim.Animation walkAnimation;
  flame_anim.Animation doublePoleAnimation;
  flame_anim.Animation tuckAnimation;
  final world;
  final RaceCmp race;
  Racer racer;
  Controller controller;
  RacerMode mode = RacerMode.START_LINE;
  int targetSegment = 1;
  double segmentProgress = 0;

  Vector2 segmentStart= Vector2.zero();
  Vector2 segmentEnd = Vector2.zero();
  Vector2 segment = Vector2.zero();

  double completedSegmentProgress = 0;
  Duration finishTime;

  List<Vector2> get  breadCrumbs => race.course.breadCrumbs;
  Vector2 get heading => racer.forwardNormal;

  RacerCmp(SpriteSheet spriteSheet, this.race, this.world, {SpriteSheet doublePole , SpriteSheet tuck, bool isPlayer})  {
    walkAnimation = spriteSheet.createAnimation(0, stepTime: .15);
    doublePoleAnimation = doublePole?.createAnimation(0, stepTime: .1);
   // tuckAnimation = tuck?.createAnimation(0, stepTime: .15);

    final startPos = breadCrumbs.first;
    width = 32;
    height = 32;
    x = startPos.x.toDouble();
    y = startPos.y.toDouble();
    anchor = Anchor.center;

    racer = Racer(world);
    controller = isPlayer ? PlayerController(this) : NpcController(this);
    racer.controller = controller;
    racer.setPositionAndRotation(startPos.x, startPos.y, this.race.course.startAngle);
  }

  setMode(RacerMode m) {
    mode = m;
  }

  @override bool destroy() {
    return done;
  }

  @override
  void update(double dt) {
    if (!loaded()) return;

    if (mode == RacerMode.RACING) {
      updateTracking(dt);
      controller.update(dt);
      if (courseProgress > race.distance) {
        mode = RacerMode.FINISHED;
        finishTime = race.elapsedTime;
      }
    }

    racer.update(dt);

    x = racer.pxPosition.x;
    y = racer.pxPosition.y;
    angle = racer.angle;

    super.update(dt);
    walkAnimation.update(dt);
    if (doublePoleAnimation != null) {
      doublePoleAnimation.update(dt);
    }

  }

  @override
  void render(Canvas c) {
    prepareCanvas(c);

    if (racer.technique == Technique.DOUBLE_POLE) {
      doublePoleAnimation.getSprite().render(c, width: width, height: height);
    } else {
      walkAnimation.getSprite().render(c, width: width, height: height);
    }
  }

  @override
  bool loaded() {
    if (doublePoleAnimation!=null)
    return walkAnimation.loaded() && doublePoleAnimation.loaded()

        && x != null && y != null;
    else return walkAnimation.loaded();
  }

  void updateTracking(double dt) {
    final prevIndex = targetSegment == 0 ? breadCrumbs.length - 1 : targetSegment - 1,
        nextIndex = targetSegment,
        prev = breadCrumbs[prevIndex],
        next = breadCrumbs[nextIndex];

    segment = (next - prev);
    segmentStart = prev;
    segmentEnd = next;

    final prev2Pos = racer.body.position - segmentStart;
    segmentProgress =  (prev2Pos.dot(segment) / segment.dot(segment));

    if (segmentProgress > 0 && segmentProgress > .99) {
      targetSegment++;
      completedSegmentProgress += segment.length;
      if (targetSegment == breadCrumbs.length) {
        targetSegment = 0;
      }
    }
  }
  double get courseProgress => completedSegmentProgress + max(0,min(segmentProgress,1)) * segment.length;



}


