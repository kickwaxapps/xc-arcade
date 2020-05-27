import 'dart:math';
import 'dart:ui';

import 'package:box2d_flame/box2d.dart';
import 'package:flame/components/component.dart';
import 'package:tiled/tiled.dart';
import 'package:xc_arcade/units.dart';

class CourseCmp extends Component {
  final List geos;
  final world;
  final List<Vector2> breadCrumbs;

  double get length => _length ?? getLength();
  double get startAngle =>  90 * DEGREES;
  double _length;

  CourseCmp(List geos_, this.world) :
         geos = geos_,
         breadCrumbs = _pointCleaner(getGeo(geos_, 'breadcrumbs'), 5) {
    _createWallByName('trackright');
    _createWallByName('trackleft');
    _createWalls();
  }

  static getGeo(List geos_, String name) {
    return geos_.firstWhere((e) => e.name == name, orElse: ()=>null);
  }

  static Iterable getWallGeos(List geos_) {
    return geos_.where((e) => e.name.substring(0, 4) == 'wall');
  }
    double getLength() {
    final l = breadCrumbs.length,
      getSegmentLength  = <double> (int i0) => (breadCrumbs[(i0+1) % l] - breadCrumbs[i0]).length;
    double r= 0;
    for (int i = 0; i < l; i++) {
       r += getSegmentLength(i);
    }
    _length = r;
    return _length;
  }
  _createWalls() {
    getWallGeos(geos).forEach((wallGeo) => _createWall(wallGeo));
  }


  _createWall(TmxObject geo) {
    final wallBodyDef = BodyDef();

    final shape = ChainShape();

    wallBodyDef.position = Vector2(geo.x.toDouble(), geo.y.toDouble()) * METERS;
    wallBodyDef.type = BodyType.STATIC;

    final List<Point<double>> wall = geo.points;

    final List verts = wall.map<Vector2>((p) => Vector2(p.x, p.y) * METERS).toList();
    shape.createLoop(verts, verts.length);

    final Body wallBody = world.createBody(wallBodyDef);
    wallBody.createFixtureFromShape(shape);
  }

  _createWallByName(String geoName) {
    final trackGeo = getGeo(geos, geoName);
    if (trackGeo != null) {
      _createWall(trackGeo);
    }
  }

  static List<Vector2> _pointCleaner(TmxObject bc, double minThreshold) {
    final List<Vector2> points = bc.points.map((p) => Vector2(bc.x + p.x, bc.y+p.y)*METERS).toList();
    final List<Vector2> result = List();

    points.forEach((p) {
      if (result.length == 0) {
        result.add(p);
      } else {
        if (p.distanceTo(result.last) > minThreshold) {
          result.add(p);
        }
      }
    });

    return result;
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
