

import 'package:box2d_flame/box2d.dart';
import 'package:flutter/material.dart';
import 'package:xc_arcade/units.dart';

enum Technique {
  SKATE_1,
  SKATE_2,
  DOUBLE_POLE,
  SPRINT,
  TUCK
}

enum Steeering {
  none,
  slightLeft,
  slightRight,
  hardLeft,
  hardRight,
}


class Controller {
  Controller(this.breadCrumbs, this.racer);


  final Racer racer;
  int targetIndex = 1;

  final List<Vector2> breadCrumbs;

  void update(double dt) {

      final prevIndex = targetIndex == 0 ? breadCrumbs.length -1 : targetIndex -1,
          nextIndex = targetIndex,
          prev = breadCrumbs[prevIndex],
          next = breadCrumbs[nextIndex],
          courseHeading = (next - prev).normalized(),
          diff = racer.heading.angleToSigned(courseHeading),
          lr = diff.sign ,
          diffMag = diff.abs();

     // print(diffMag*DEGREES);

      


      final prev2Pos = racer.body.position - prev,
          segment = next - prev,
          projCoef  =  (prev2Pos.dot(segment) /  segment.dot(segment)),
          projectPoint = segment * projCoef;
      

      if (projCoef.abs() > .95) {
        targetIndex++;
        if (targetIndex == breadCrumbs.length) {
          targetIndex = 0;
        }
      }


      Steeering desiredSteering  = Steeering.none;
      if (diffMag < 10*DEGREES) {
        desiredSteering = Steeering.none;
      }
      else if (diffMag < 20*DEGREES) {
        desiredSteering= lr < 0 ? Steeering.slightLeft : Steeering.slightRight;
      }
      else  {
        desiredSteering = lr < 0 ? Steeering.hardLeft : Steeering.hardRight;
      }
      if (desiredSteering == Steeering.none && projCoef.abs() < .80) {
        final dist = prev2Pos.distanceTo(projectPoint);
        if (dist > 1 ) {
          final side = segment.cross(prev2Pos)* -1 ;
          if (side > 0 ) {
            desiredSteering = Steeering.slightRight;
          } else if (side < 0 ){
            desiredSteering = Steeering.slightLeft;
          }

        }


      }


      print(desiredSteering);
      racer.steering = desiredSteering;
  }



}

class Racer {

  Controller controller;

  Vector2 get heading => body.getWorldVector(Vector2(0,-1));

  Vector2 get forwardNormal => body.getWorldVector(Vector2(0,-1));
  Vector2 get rightNormal => body.getWorldVector(Vector2(-1,0));

  double get speed => getForwardVelocity().dot(forwardNormal);

  Vector2 get pxPosition => body.position * PIXELS;

  Vector2 perp;

  Steeering steering = Steeering.none;

  CircleShape shape;

  final World world;
  Body body;

  Racer(this.world) {
    init();
  }

  double get angle => body.getAngle();

  void init() {
    shape = CircleShape(); //build in shape, just set the radius
    shape.p.setFrom(Vector2.zero());
    shape.radius = 1;


    BodyDef bd = BodyDef();
    bd.linearVelocity = Vector2.zero();
    bd.position = Vector2(0,0);
        bd.type = BodyType.DYNAMIC;
    body = world.createBody(bd);
    body.userData = this;

    FixtureDef fd = FixtureDef();

    fd.density = 1;
    fd.restitution = 1;
//    fd.friction = 10;
    fd.shape = shape;
    body.createFixtureFromFixtureDef(fd);

  }

  void updateFriction() {
    //lateral linear velocity
    double maxLateralImpulse = 2.5;
    Vector2 impulse =lateralVelocity *  body.mass * -1 ;
    if ( impulse.length > maxLateralImpulse )
    impulse = impulse * maxLateralImpulse / impulse.length;
    body.applyLinearImpulse( impulse, body.worldCenter, true );

    //angular velocity
    body.applyAngularImpulse( body.angularVelocity * 0.1 * body.getInertia() * -1 );

    //forward linear velocity
    Vector2 currentForwardNormal = getForwardVelocity();
    double currentForwardSpeed = currentForwardNormal.normalize();
    double dragForceMagnitude = -2 * currentForwardSpeed;
    body.applyForce( currentForwardNormal * dragForceMagnitude , body.worldCenter);
  }
  void update(double dt ) {
    updateFriction();
    updateSpeed(dt);
    updateSteering(dt);
  }

  void updateSpeed(double dt) {
    final s = speed,
      maxSpeed = 90.0,
      driveForce = 45.0;

    double force = 0;
    if (s < maxSpeed) {
       force += driveForce;
    } else if ( s > maxSpeed) {
       force += -driveForce;
    } else {
      return;
    }

    body.applyForceToCenter(forwardNormal * force);
  }

  void updateSteering(double dt) {
    double  desiredTorque = 0;
    switch ( steering) {
      case Steeering.none:
        break;
      case Steeering.slightLeft:
        desiredTorque = -5;
        break;
      case Steeering.slightRight:
        desiredTorque = 5;
        break;
      case Steeering.hardLeft:
        desiredTorque = -15;
        break;
      case Steeering.hardRight:
        desiredTorque = 15;
        break;
    }
    body.angularVelocity = desiredTorque/3;
    //body.applyTorque(-1100);
  }

  void setPositionAndRotation(double x, double y, double angle) {
    body.setTransform(Vector2(x,y), angle);
  }



  Vector2 get lateralVelocity {
    return rightNormal * rightNormal.dot(body.linearVelocity);
  }

  Vector2 getForwardVelocity() {
    return forwardNormal * forwardNormal.dot(body.linearVelocity );
  }

}