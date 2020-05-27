import 'package:xc_arcade/units.dart';

import 'controller.dart';

class NpcController  extends Controller {

  NpcController(racerCmp): super(racerCmp);



  void updateTechnique(double dt) {
    racerCmp.racer.technique = Technique.SKATE_1;
  }

  void updateSteering(double dt) {
   final racer = racerCmp.racer,
      segment = racerCmp.segment,
      segmentStart = racerCmp.segmentStart,
      diff = racerCmp.heading.angleToSigned(segment),
      lr = diff.sign,
      diffMag = diff.abs();


    final segProgress = racerCmp.segmentProgress;
    Steering desiredSteering = Steering.NONE;
    if (diffMag < 10 * DEGREES) {
      desiredSteering = Steering.NONE;
    } else if (diffMag < 20 * DEGREES) {
      desiredSteering = lr < 0 ? Steering.SLIGHT_LEFT : Steering.SLIGHT_RIGHT;
    } else {
      desiredSteering = lr < 0 ? Steering.HARD_LEFT : Steering.HARD_RIGHT;
    }
    if (desiredSteering == Steering.NONE && segProgress.abs() < .80) {
      final projectPoint = segment * segProgress;
      final prev2Pos = racer.body.position - segmentStart;
      final dist = prev2Pos.distanceTo(projectPoint);
      if (dist > 1) {
        final side = segment.cross(prev2Pos) * -1;
        if (side > 0) {
          desiredSteering = Steering.SLIGHT_RIGHT;
        } else if (side < 0) {
          desiredSteering = Steering.SLIGHT_LEFT;
        }
      }
    }
    racer.steering = desiredSteering;
  }
}
