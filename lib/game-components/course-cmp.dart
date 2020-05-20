import 'dart:math';
import 'dart:ui';

import 'package:box2d_flame/box2d.dart';
import 'package:flame/components/component.dart';
import 'package:xc_arcade/units.dart';

class CourseCmp extends Component {

  final geoMeta;
  final world;

  CourseCmp (this.geoMeta, this.world) {

    _createWall('trackright');
    _createWall('trackleft');


  }

   _createWall(String geoName) {
    final wallBodyDef = BodyDef();

    final shape = ChainShape();

    final trackGeo = geoMeta.tmxObjects.firstWhere((e) => e.name == geoName);

    wallBodyDef.position =  Vector2(trackGeo.x.toDouble(), trackGeo.y.toDouble()) * METERS;
    wallBodyDef.type = BodyType.STATIC;

    final List<Point<double>> wall = trackGeo.points;

    final List verts = wall.map<Vector2>((p)=> Vector2(p.x, p.y) * METERS).toList();
    shape.createLoop(verts, verts.length);

    final Body wallBody = world.createBody(wallBodyDef);
    wallBody.createFixtureFromShape(shape);
  }

  @override
  void render(Canvas c) {
    // TODO: implement render
  }

  @override
  void update(double dt) {
    // TODO: implement update
  }



  }
