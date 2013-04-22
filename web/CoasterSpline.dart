part of RollerCoaster;

class CoasterSplineItem {
  Vector3 position;
  Vector3 up;
  num rotation;
  
  CoasterSplineItem(this.position, this.up, this.rotation);
  
  num get x            => position.x;
  num get y            => position.y;
  num get z            => position.z;
}

class CoasterSpline extends Curve3D 
{
  final Vector3 up = new Vector3(0,1,0);
  
  List<CoasterSplineItem> points = [];
  
  CoasterSpline() : super() {
  }

  void addPoint( Vector3 point, {Vector3 normal: null, num rotation: 0} )
  {
    points.add(new CoasterSplineItem(
      point,
      normal == null ? up : normal,
      rotation
    ));   
  }
  
  List<CoasterSplineItem> getItems( int intPoint ){    
    return [ points[ intPoint == 0 ? points.length - 1 : intPoint - 1 ],
             points[ intPoint % points.length ],
             points[ (intPoint + 1) % points.length ],
             points[ (intPoint + 2) % points.length ] ];
    
  }
  
  Vector3 getPoint( num t ) {
    var point = points.length * t,
        intPoint = point.floor().toInt(),
        weight = point - intPoint,
        pt = getItems( intPoint );

    return new Vector3(
        CurveUtils.interpolate(pt[0].x, pt[1].x, pt[2].x, pt[3].x, weight),
        CurveUtils.interpolate(pt[0].y, pt[1].y, pt[2].y, pt[3].y, weight),
        CurveUtils.interpolate(pt[0].z, pt[1].z, pt[2].z, pt[3].z, weight)
    );
  }
  
  Vector3 getUp( num t ) {
    var point = points.length * t,
        intPoint = point.floor().toInt(),
        weight = point - intPoint,
        pt = getItems( intPoint );

    return new Vector3(
        CurveUtils.interpolate(pt[0].up.x, pt[1].up.x, pt[2].up.x, pt[3].up.x, weight),
        CurveUtils.interpolate(pt[0].up.y, pt[1].up.y, pt[2].up.y, pt[3].up.y, weight),
        CurveUtils.interpolate(pt[0].up.z, pt[1].up.z, pt[2].up.z, pt[3].up.z, weight)
    );
  }
  
  Vector3 getForward( t, [num delta = 0.005]){
    Vector3 p1 = getPoint(t);
    Vector3 p2 = getPoint(t+delta);
    return p2.subSelf(p1).normalize();
  }
  
  num getRotation( num t ){
    var point = points.length * t,
        intPoint = point.floor().toInt(),
        weight = point - intPoint,
        pt = getItems( intPoint );
    
    return CurveUtils.interpolate(
        pt[0].rotation, 
        pt[1].rotation, 
        pt[2].rotation, 
        pt[3].rotation, 
        weight
    );
  }
  
  Quaternion getQuaternion( num t, [num extraRotation = 0] ){
    return new Quaternion().setFromAxisAngle(getForward(t), getRotation(t) + extraRotation);
  }
  
}