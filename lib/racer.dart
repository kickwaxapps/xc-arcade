import 'package:box2d_flame/box2d.dart';

import 'game-components/controllers/controller.dart';
import 'units.dart';

class Racer {
  Controller controller;

  Technique technique = Technique.NONE;

  Steering userSteer =  Steering.none;

  Vector2 get heading => body.getWorldVector(Vector2(0, -1));

  Vector2 get forwardNormal => body.getWorldVector(Vector2(0, -1));

  Vector2 get rightNormal => body.getWorldVector(Vector2(-1, 0));

  double get speed => getForwardVelocity().dot(forwardNormal);

  Vector2 get pxPosition => body.position * PIXELS;

  Vector2 perp;

  Steering steering = Steering.none;

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
    bd.position = Vector2(0, 0);
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
    Vector2 impulse = lateralVelocity * body.mass * -1;
    if (impulse.length > maxLateralImpulse) impulse = impulse * maxLateralImpulse / impulse.length;
    body.applyLinearImpulse(impulse, body.worldCenter, true);

    //angular velocity
    body.applyAngularImpulse(body.angularVelocity * 0.1 * body.getInertia() * -1);

    //forward linear velocity
    Vector2 currentForwardNormal = getForwardVelocity();
    double currentForwardSpeed = currentForwardNormal.normalize();
    double dragForceMagnitude = -2 * currentForwardSpeed;
    body.applyForce(currentForwardNormal * dragForceMagnitude, body.worldCenter);
  }

  void update(double dt) {
    updateFriction();
    updateSpeed(dt);
    updateSteering(dt);
  }

  void updateSpeed(double dt) {
    var s = speed, maxSpeed = 100.0, driveForce = 45.0;
    double bonus = 0;

    switch (technique) {
      case Technique.NONE:
        maxSpeed = 10;
        driveForce = 10;
        bonus = 0;
        break;
      case Technique.SKATE_1:
        bonus = 6;
        break;
      case Technique.SKATE_2:
        bonus = 40;
        break;
      case Technique.DOUBLE_POLE:
        bonus = 5;
        break;
      case Technique.SPRINT:
        bonus = 70;
        break;
      case Technique.TUCK:
      // TODO: Handle this case.
        break;
    }

    double force = 0;
    if (s < maxSpeed) {
      force += (driveForce+bonus);
    } else if (s > maxSpeed) {
      force += -(driveForce+bonus);
    } else {
      return;
    }

    body.applyForceToCenter(forwardNormal * force);
  }

  void updateSteering(double dt) {
    double desiredTorque = 0;
    switch (steering) {
      case Steering.none:
        break;
      case Steering.slightLeft:
        desiredTorque = -5;
        break;
      case Steering.slightRight:
        desiredTorque = 5;
        break;
      case Steering.hardLeft:
        desiredTorque = -15;
        break;
      case Steering.hardRight:
        desiredTorque = 15;
        break;
    }
    body.angularVelocity = desiredTorque / 3;
    //body.applyTorque(-1100);
  }

  void setPositionAndRotation(double x, double y, double angle) {
    body.setTransform(Vector2(x, y), angle);
  }

  Vector2 get lateralVelocity {
    return rightNormal * rightNormal.dot(body.linearVelocity);
  }

  Vector2 getForwardVelocity() {
    return forwardNormal * forwardNormal.dot(body.linearVelocity);
  }


}
