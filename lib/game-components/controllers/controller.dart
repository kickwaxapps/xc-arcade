
import '../racer-cmp.dart';

enum Technique { NONE, SKATE_1, SKATE_2, DOUBLE_POLE, SPRINT, TUCK }

enum Steering {
  NONE,
  SLIGHT_LEFT,
  SLIGHT_RIGHT,
  HARD_LEFT,
  HARD_RIGHT,
}

enum Kick {
  NONE,
  LEFT,
  RIGHT,
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
