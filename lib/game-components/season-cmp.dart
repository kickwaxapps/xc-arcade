import 'dart:math';
import 'dart:ui';

import 'package:flame/components/component.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import 'package:xc_arcade/flame-overrides/hud.dart';
import 'package:xc_arcade/game-components/race-cmp.dart';
import 'package:xc_arcade/main.dart';

import 'racer-cmp.dart';


enum SeasonMode {
  COUNTDOWN,
  INIT_RACE,
  IN_RACE,
  RACE_OVER
}

class Season extends Component {
  MyGame game;
  int year;
  final Paint _paint  = BasicPalette.white.paint;
  final List<Event>  events;

  HudText _titleText;
  HudText _eventText;
  HudText _raceText;
  HudText _countdownText;

  Event event;
  RaceCmp race;

  SeasonMode mode = SeasonMode.COUNTDOWN;

  double _time = 10;
  Season(this.game, {this.year, this.events}){
   _titleText = HudText('Title', 10, 50);
   _eventText = HudText('Event', 0, 50);
   _raceText = HudText('Race', 0, 50);
   _countdownText = HudText('Ready In: $_time', 0, 50);
  }

  @override
  bool isHud() {
    // TODO: implement isHud
    return true;
  }

  @override
  void render(Canvas c) {
      if (_time < 0) {
        return;
      }
      c.drawRect(Rect.fromLTWH(0,0,1024,1024), _paint);
      _titleText.render(c);
      _eventText.render(c);
      _raceText.render(c);
      _countdownText.render(c);
  }

  @override
  void update(double dt) {
    event  = currentEvent;
    race  = event.currentRace;
    _time -= dt;

    _titleText.text = 'Season: $year - ${year+1}';
    _eventText.text = 'Event: ${event.description}';
    _raceText.text = 'Race: ${race.description}';
    _countdownText.text = 'Ready: ${_time.toStringAsFixed(1)}';

    switch (mode) {
      case SeasonMode.COUNTDOWN:
        if (_time < 0) {
          mode = SeasonMode.INIT_RACE;
        }
        break;
      case SeasonMode.INIT_RACE:
        game.player = RacerCmp(game.sprintSheet, race, game.world, doublePole: game.doublePoleSheet, isPlayer: true);
        game.npcs = race.skierProfiles.map((s)=> RacerCmp(game.npcSheets[Random().nextInt(5)], race, game.world, isPlayer: false)).toList();
        race.startTime = DateTime.now();
        mode = SeasonMode.IN_RACE;
        break;

      case SeasonMode.IN_RACE:

        // TODO: Handle this case.
        break;
      case SeasonMode.RACE_OVER:
        // TODO: Handle this case.
        break;
    }

  }

  Event get currentEvent => events.where((e) => !e.complete).first;

  bool get inRace => _time > 0;
}


class Event {
  bool complete = false;
  final DateTime from;
  final List<RaceCmp> races;
  final String description;

  Event({this.from, this.races, this.description});



  RaceCmp get currentRace => races.where((r) => !r.completed).first;
}