
import '../racer-cmp.dart';

enum Technique { NONE, SKATE_1, SKATE_2, DOUBLE_POLE, SPRINT, TUCK }

enum Steering {
  none,
  slightLeft,
  slightRight,
  hardLeft,
  hardRight,
}

enum Kick {
  none,
  left,
  right,
}

class Controller {

  final RacerCmp racerCmp;

  Controller(this.racerCmp);

  void update(double dt) {
    updateSteering(dt);
    updateTechnique(dt);
  }

  void setInputSteering(Steering steering) {}


  void updateTechnique(double dt){

  }
  void updateSteering(double dt) {

  }
}
