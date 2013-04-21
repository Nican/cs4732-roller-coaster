part of RollerCoaster;

class RollerCoaster extends Geometry {
  
  int segmentsRadius = 4;
  
  RollerCoaster( SplineCurve3 curve ) : super() {
    
    num delta = 0.01;
    
    for(num t = 0; t <= 1.0; t += delta ){
      Vector3 position = curve.getPoint(t);
      Vector3 next = curve.getPoint(t += delta );
      Vector3 normal = new Vector3().sub(next, position).normalize();
      
      addRing( position, normal );
      
      //addSegment( curve.getPoint(t), curve.getPoint(t+delta), curve.getPoint((t+delta*2)%1) );
    }
    
    
    computeCentroids();
    mergeVertices();
  }
  
  void addRing( Vector3 position, Vector3 normal )
  {
    Vector3 cross = new Vector3().cross( normal, new Vector3(0,1,0) ).normalize().multiplyScalar(10);
    
    vertices.add( new Vector3().add(position, cross) );
    vertices.add( new Vector3().sub(position, cross) );
    vertices.add( new Vector3().add(position, new Vector3(0,1,0)) );
    vertices.add( new Vector3().add(position, new Vector3(0,-1,0)) );    
  }
  
  void addSegment( Vector3 position, Vector3 next, Vector3 next2 )
  {
    Vector3 normal = new Vector3().sub(next, position).normalize();
    Vector3 cross = new Vector3().cross( normal, new Vector3(0,1,0) ).normalize().multiplyScalar(10);
    
    Vector3 normal2 = new Vector3().sub(next2, next).normalize();
    Vector3 cross2 = new Vector3().cross( normal2, new Vector3(0,1,0)  ).normalize().multiplyScalar(10);
    var offset = vertices.length;
    
    vertices.add( new Vector3().add(position, cross) );
    vertices.add( new Vector3().sub(position, cross) );
    vertices.add( new Vector3().add(next, cross2) );
    vertices.add( new Vector3().sub(next, cross2) );
    
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