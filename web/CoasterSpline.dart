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
    //c[ 0 ] = intPoint == 0 ? intPoint : intPoint - 1;
    //c[ 1 ] = intPoint;
    //c[ 2 ] = intPoint  > points.length - 2 ? points.length - 1 : intPoint + 1;
    //c[ 3 ] = intPoint  > points.length - 3 ? points.length - 1 : intPoint + 2;
    
    int p1 = intPoint == 0 ? points.length - 1 : intPoint - 1;
    int p2 = intPoint % points.length;
    int p3 = (intPoint + 1) % points.length;
    int p4 = (intPoint + 2) % points.length;
    
    return [ points[ p1 ],
             points[ p2 ],
             points[ p3 ],
             points[ p4 ] ];
    
  }
  
  Vector3 getPoint( num t ) {
    var point = points.length * t,
        intPoint = point.floor().toInt(),
        weight = point - intPoint,
        pt = getItems( intPoint );

    return new Vector3(
        CRSpline(pt[0].x, pt[1].x, pt[2].x, pt[3].x, weight),
        CRSpline(pt[0].y, pt[1].y, pt[2].y, pt[3].y, weight),
        CRSpline(pt[0].z, pt[1].z, pt[2].z, pt[3].z, weight)
    );
  }
  
  Vector3 getUp( num t ) {
    var point = points.length * t,
        intPoint = point.floor().toInt(),
        weight = point - intPoint,
        pt = getItems( intPoint );

    Vector3 up = new Vector3(
        CurveUtils.interpolate(pt[0].up.x, pt[1].up.x, pt[2].up.x, pt[3].up.x, weight),
        CurveUtils.interpolate(pt[0].up.y, pt[1].up.y, pt[2].up.y, pt[3].up.y, weight),
        CurveUtils.interpolate(pt[0].up.z, pt[1].up.z, pt[2].up.z, pt[3].up.z, weight)
    );
    //Vector3 forward = getForward(t);
    //Vector3 cross = up.crossSelf(forward);
    //Vector3 result = cross.crossSelf(new Vector3(0,1,0)).normalize();
    return up;
    
  }
  
  /*
  Vector3 getForward( t, [num delta = 0.0001]){
    Vector3 p1 = getPoint(t);
    Vector3 p2 = getPoint(t+delta);
    return p2.subSelf(p1).normalize();
  }
  */
  Vector3 getForward( t ){
    var point = points.length * t,
        intPoint = point.floor().toInt(),
        weight = point - intPoint,
        pt = getItems( intPoint );

    return new Vector3(
        CRSplineDirection(pt[0].x, pt[1].x, pt[2].x, pt[3].x, weight),
        CRSplineDirection(pt[0].y, pt[1].y, pt[2].y, pt[3].y, weight),
        CRSplineDirection(pt[0].z, pt[1].z, pt[2].z, pt[3].z, weight)
    ).normalize();
  }
  
  num CRSpline( num p1, num p2, num p3, num p4, num t ){
    return 1/2 * (
        t * t * t * (  -p1 + 3*p2 - 3*p3 + p4 ) +
        t * t *     ( 2*p1 - 5*p2 + 4*p3 - p4 ) +
        t *         (  -p1        +   p3      ) + 
                    (         2*p2            ));
  }
  
  //The derivate of the CRSpline will give the velocity/direction
  num CRSplineDirection( num p1, num p2, num p3, num p4, num t ){
    return
        3/2 * t * t * (  -p1 + 3*p2 - 3*p3 + p4 ) +
        1   * t *     ( 2*p1 - 5*p2 + 4*p3 - p4 ) +
        1/2 *         (  -p1        +   p3      );
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