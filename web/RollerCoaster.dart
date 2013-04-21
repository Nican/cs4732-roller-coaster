part of RollerCoaster;

class RollerCoaster extends Geometry {
  
  int segmentsRadius = 4;
  num delta = 0.01;
  SplineCurve3 curve;
  
  RollerCoaster( this.curve ) : super() {
    createRail( -5 );
    createRail( 5 );
    
    computeCentroids();
    mergeVertices();
  }
  
  void createRail( num offset ){
    int firstRing = null;
    int lastRing = null;
    
    for(num t = 0; t <= 1.0; t += delta ){
      Vector3 position = curve.getPoint(t);
      Vector3 next = curve.getPoint(t += delta );
      Vector3 normal = new Vector3().sub(next, position).normalize();
      Vector3 cross = new Vector3().cross( normal, new Vector3(0,1,0) ).normalize().multiplyScalar(offset);
      
      int newRing = addRing( new Vector3().add(position, cross), normal, 2 );
      
      if( firstRing == null )
        firstRing = newRing;
      
      if( lastRing != null ){
        createCylinderFaces( lastRing, newRing );
      }
      
      lastRing = newRing;
    }
    
    createCylinderFaces( firstRing, lastRing  );
  }
  
  int addRing( Vector3 position, Vector3 normal, num radius )
  {
    Vector3 cross = new Vector3().cross( normal, new Vector3(0,1,0) ).normalize().multiplyScalar(radius);
    int index = vertices.length;
    
    vertices.add( new Vector3().add(position, new Vector3(0,radius,0)) );
    vertices.add( new Vector3().add(position, cross) );
    vertices.add( new Vector3().sub(position, new Vector3(0,radius,0)) );    
    vertices.add( new Vector3().sub(position, cross) );
    
    return index;
  }
  
  void createCylinderFaces( int lastIndex, int newIndex ){
    
    for( int i = 0; i < segmentsRadius; i++ )
    {
      var a = lastIndex + i;
      var b = lastIndex + i + 1;
      var c = newIndex + i + 1;
      var d = newIndex + i;
 
      if( b == lastIndex + 4 )
        b = lastIndex;
      
      
      if( c == newIndex + 4 )
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
  
  void addSegment( Vector3 position, Vector3 next, Vector3 next2 )
  {
    Vector3 normal = new Vector3().sub(next, position).normalize();
    Vector3 cross = new Vector3().cross( normal, new Vector3(0,1,0) ).normalize().multiplyScalar(10);
    
    Vector3 normal2 = new Vector3().sub(next2, next).normalize();
    Vector3 cross2 = new Vector3().cross( normal2, new Vector3(0,1,0)  ).normalize().multiplyScalar(10);
    var offset = vertices.length;
    
    vertices.add( new Vector3().sub(next, cross2) );
    vertices.add( new Vector3().add(position, cross) );
    vertices.add( new Vector3().add(next, cross2) );
    vertices.add( new Vector3().sub(position, cross) );
    
    faces.add( new Face4( 0 + offset, 2 + offset, 3 + offset, 1 + offset ) );
    
    List faceVertexUV = faceVertexUvs[ 0 ];
    faceVertexUV.add( [
      new UV( 0, 0 ),
      new UV( 0, 1 ),
      new UV( 1, 1 ),
      new UV( 1, 0 ),
    ] );
    
    
  }
}