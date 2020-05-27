import 'dart:ui';

import 'package:flame/components/component.dart';
import 'package:flutter/cupertino.dart';
import 'package:xc_arcade/game-components/course-cmp.dart';

enum NordicDiscipline { CLASSIC, SKATE }

enum RaceFormat { TIME_TRIAL, MASS_START }

enum RaceCategory { DISTANCE, SPRINT }

class RaceCmp extends Component {
  final CourseCmp course;
  final RaceCategory category;
  final RaceFormat format;
  final NordicDiscipline discipline;

  final int laps;

  RaceCmp( {this.course, this.category, this.format, this.discipline, this.laps, this.skierProfiles});

  bool completed = false;

  double get distanceKm => (course.length*laps/1000);
  double get distance => course.length * laps;

  final List<SkierProfile> skierProfiles;

  DateTime startTime;
  Duration get elapsedTime => DateTime.now().difference(startTime);

  @override
  void render(Canvas c) {}

  @override
  void update(double dt) {}

  @override
  bool isHud() {
    return true;
  }

  String get description => [
    discipline == NordicDiscipline.CLASSIC ? 'Classic' : 'Skate',
    format == RaceFormat.TIME_TRIAL ? 'Ind. ' : 'Mass' ,
    category == RaceCategory.DISTANCE ? '' : 'SP',
    laps.toString() + 'x' + distanceKm.toStringAsFixed(1)+'km'
  ].where((e)=>e!= '').join('|');
}

class SkierProfile {
  final String firstName;
  final String lastName;
  final int bib;

  final String nationCode;

  SkierProfile({this.firstName, this.lastName, this.bib, this.nationCode});
}
