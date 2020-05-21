import 'package:box2d_flame/box2d.dart';
import 'package:xc_arcade/units.dart';

import '../../racer.dart';
import 'controller.dart';

class NpcController {
  NpcController(this.breadCrumbs, this.racer);

  final Racer racer;
  int targetIndex = 1;

  final List<Vector2> breadCrumbs;

  void update(double dt) {
    final prevIndex = targetIndex == 0 ? breadCrumbs.length - 1 : targetIndex - 1,
        nextIndex = targetIndex,
        prev = breadCrumbs[prevIndex],
        next = breadCrumbs[nextIndex],
        courseHeading = (next - prev).normalized(),
        diff = racer.heading.angleToSigned(courseHeading),
        lr = diff.sign,
        diffMag = diff.abs();

    final prev2Pos = racer.body.position - prev,
        segment = next - prev,
        projCoef = (prev2Pos.dot(segment) / segment.dot(segment)),
        projectPoint = segment * projCoef;

    if (projCoef.abs() > .95) {
      targetIndex++;
      if (targetIndex == breadCrumbs.length) {
        targetIndex = 0;
      }
    }

    Steeering desiredSteering = Steeering.none;
    if (diffMag < 10 * DEGREES) {
      desiredSteering = Steeering.none;
    } else if (diffMag < 20 * DEGREES) {
      desiredSteering = lr < 0 ? Steeering.slightLeft : Steeering.slightRight;
    } else {
      desiredSteering = lr < 0 ? Steeering.hardLeft : Steeering.hardRight;
    }
    if (desiredSteering == Steeering.none && projCoef.abs() < .80) {
      final dist = prev2Pos.distanceTo(projectPoint);
      if (dist > 1) {
        final side = segment.cross(prev2Pos) * -1;
        if (side > 0) {
          desiredSteering = Steeering.slightRight;
        } else if (side < 0) {
          desiredSteering = Steeering.slightLeft;
        }
      }
    }
    racer.steering = desiredSteering;
  }
}
