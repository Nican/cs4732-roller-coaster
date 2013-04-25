part of RollerCoaster;

class RollerCoaster extends Geometry {
  
  int segmentsRadius = 8;
  num delta = 0.01;
  num radius = 2.0;
  CoasterSpline curve;
  
  RollerCoaster( this.curve ) : super() {
    createRail( Math.PI / 2 );
    createRail( Math.PI / -2 );
    
    computeCentroids();
    computeFaceNormals();
    computeVertexNormals();
    mergeVertices();
  }
  
  void createRail( num offset ){
    int firstRing = null;
    int lastRing = null;
    
    for(num t = 0; t <= 1.0; t += delta ){
      Vector3 position = curve.getPoint(t);
      Quaternion quaternion = curve.getQuaternion(t, offset);
      Quaternion quaternion2 = new Quaternion().rotationBetween(new Vector3(0,0,1), curve.getForward(t) );
      quaternion.multiplySelf( quaternion2 );
      
      Vector3 ringOffset = quaternion.multiplyVector3(curve.getUp(t)).multiplyScalar(5);
      
      int newRing = addRing( position.clone().addSelf(ringOffset), quaternion ); //.clone().addSelf(ringOffset)
      
      if( firstRing == null )
        firstRing = newRing;
      
      if( lastRing != null ){
        createCylinderFaces( lastRing, newRing );
      }
      
      lastRing = newRing;
    }
    
    createCylinderFaces( lastRing, firstRing );
  }
  
  int addRing( Vector3 position, Quaternion quaternion )
  {
    Vector3 cross = quaternion.multiplyVector3(new Vector3(0,radius,0));
    int index = vertices.length;
    
    for( int i = 0; i < segmentsRadius; i++ )
    {
      num a = i / segmentsRadius * Math.PI * 2;
      num c = Math.cos(a);
      num s = Math.sin(a);
      Vector3 vec = new Vector3(c * radius, s * radius, 0);
      
      vertices.add( position.clone().addSelf( quaternion.multiplyVector3(vec) ) );
    }
    
    return index;
  }
  
  void createCylinderFaces( int lastIndex, int newIndex ){
    
    for( int i = 0; i < segmentsRadius; i++ )
    {
      var a = lastIndex + i;
      var b = lastIndex + i + 1;
      var c = newIndex + i + 1;
      var d = newIndex + i;
 
      if( b == lastIndex + segmentsRadius )
        b = lastIndex;
      
      
      if( c == newIndex + segmentsRadius )
        c = newIndex;
      
      faces.add( new Face4( a, b, c, d ) );
      
      List faceVertexUV = faceVertexUvs[ 0 ];
      faceVertexUV.add( [
                         new UV( 0, 0 ),
                         new UV( 0, 1 ),
                         new UV( 1, 1 ),
                         new UV( 1, 0 ),
                         ] );
    }
    
  }
}