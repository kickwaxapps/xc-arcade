import 'dart:math';
import 'dart:ui';

import 'package:box2d_flame/box2d.dart';
import 'package:flame/anchor.dart';
import 'package:flame/animation.dart' as flame_anim;
import 'package:flame/components/animation_component.dart';


import 'package:flame/components/component.dart';
import 'package:flame/palette.dart';
import 'package:flame/sprite.dart';
import 'package:flame/spritesheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:xc_arcade/units.dart';

import 'controllers/npc.dart';



class NPCCmp extends PositionComponent {
  final Sprite sprite;
  flame_anim.Animation walkAnimation;
  final world;
  Racer racer;
  final List<Vector2> breadCrumbs;
  Controller controller;
  Vector2 get heading => racer.forwardNormal;


  NPCCmp(this.sprite, breadCrumbs_, this.world) :
      breadCrumbs = pointCleaner(breadCrumbs_, 5 )
  {

    final ss = SpriteSheet(imageName: 'walker0.png', textureWidth:64,textureHeight: 64, columns:8, rows: 1);
    walkAnimation = ss.createAnimation(0, stepTime: .05);

    final startPos = breadCrumbs.first;
    width = 32;
    height = 32;
    x = startPos.x.toDouble();
    y = startPos.y.toDouble() ;
    anchor = Anchor.center;

    racer = Racer(world);
    controller = Controller(breadCrumbs, racer);
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
          width: 32, height: 32);
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
class NPCCmpx extends PositionComponent {
  final Sprite sprite;
  final world;

  double speed = 0;

  Paint overridePaint;

  CircleShape shape;
  Body body;

  Vector2 f;
  Vector2 t;

  Vector2 heading;

  double targetAngle;
  int targetIndex = 1;


  NPCCmpx(this.sprite, this.breadCrumbs, this.world) {
    final startPos = breadCrumbs.first;
    width = 32;
    height = 32;
    x = startPos.x.toDouble();
    y = startPos.y.toDouble() ;

    anchor = Anchor.center;



    shape = CircleShape(); //build in shape, just set the radius
    shape.p.setFrom(Vector2.zero());
    shape.radius = 1; //10cm ball


    BodyDef bd = BodyDef();
    bd.linearVelocity = Vector2.zero();
    bd.position = Vector2(x,y)*METERS;

    bd.type = BodyType.DYNAMIC;
    body = world.createBody(bd);
    body.userData = this;

    FixtureDef fd = FixtureDef();

    fd.density = 1;
    fd.restitution = 1;
    fd.friction = 10;
    fd.shape = shape;
    body.createFixtureFromFixtureDef(fd);

  }

  final List<Vector2> breadCrumbs;


  @override
  void update(double dt) {
    final prevIndex = targetIndex == 0 ? breadCrumbs.length -1 : targetIndex -1,
      nextIndex = targetIndex,
      prev = breadCrumbs[prevIndex],
      next = breadCrumbs[nextIndex],
      dirHint = (next - prev).normalized();



    final  s = dirHint * speed;
    x = body.position.x * PIXELS;
    y = body.position.y * PIXELS;
    heading = (next-prev).normalized();
    final perp = Vector2(heading.y, -heading.x);

    
    final angleFromDesired  = body.linearVelocity.angleTo(heading);
   if (angleFromDesired > 0 ) {
      body.applyForceToCenter(perp * 100);
    } else {
      body.applyForceToCenter(perp * 100);
    }


    targetAngle = heading.angleToSigned(Vector2(0,-1));

    final prev2Pos = Vector2(x,y) - prev,
      segment = next - prev,
    projCoef  =  (prev2Pos.dot(segment) /  segment.dot(segment));

    if (projCoef.abs() > .95) {
      targetIndex++;
      if (targetIndex == breadCrumbs.length) {
        targetIndex = 0;
      }
    }


    final baseDiff = targetAngle - angle,
        diff360 = 180 * DEGREES - baseDiff,
        diff =baseDiff;

    final dir = diff.sign;
    final mag = diff.abs();
    double step = 0;
    if  (mag > 45*DEGREES) {
      step = .1;
    } else if (mag > 20*DEGREES) {
      step = 0.05;
    }
    else if (mag > 10*DEGREES) {
      step = 0.025;
    }
    else if (mag > 2*DEGREES) {
      step = 0.0125;
    }
    else {
      step = 0;
      angle = targetAngle;
    }

    angle = angle + dir * step;
//speed = 0;
    if (speed > 0) {
      speed -= .25;
    }

    speed = max(0,min(speed,100));

    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    prepareCanvas(canvas);
    sprite.render(canvas,
        width: 32, height: 32, overridePaint: overridePaint);


  }

  @override
  bool loaded() {
    return sprite != null && sprite.loaded() && x != null && y != null;
  }

  void onTap() {
  speed = 30;
  body.linearVelocity = heading * 10;

  //body.applyLinearImpulse(heading*1, body.worldCenter, true);

  }
}