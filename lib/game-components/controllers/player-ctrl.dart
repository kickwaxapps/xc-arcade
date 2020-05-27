import 'package:xc_arcade/game-components/racer-cmp.dart';

import 'controller.dart';

class PlayerController extends Controller{
  Steering inputSteering;

  Technique inputTechnique;
  double  inputTechniqueTime = 0;
  PlayerController(RacerCmp racerCmp) : super(racerCmp);


  void setInputSteering(Steering steering) {
    inputSteering = steering;
  }

  @override
  void updateTechnique(double dt) {

    inputTechniqueTime -= dt;
    if (inputTechniqueTime < 0) {
      inputTechniqueTime = 0;
      inputTechnique = Technique.NONE;
    }

    racerCmp.racer.technique = inputTechnique;
    super.updateTechnique(dt);
  }

  @override
  void updateSteering(double dt) {
  racerCmp.racer.steering = inputSteering;
  inputSteering = Steering.NONE;

  }

  void doDoublePoleInput(int time) {
    inputTechnique = Technique.DOUBLE_POLE;
    inputTechniqueTime += time/ 1000;
  }

}