part of RollerCoaster;

class CoasterEditor implements GameState {
  
  SpiderCoaster coaster;
  StreamSubscription<MouseEvent> mouseDownEvent;
  StreamSubscription<MouseEvent> mouseUpEvent;
  StreamSubscription<MouseEvent> mouseMoveEvent;
  
  Projector projector = new Projector();
  List<SelectMesh> objects = new List();
  
  FirstPersonControls controls;
  
  SelectMesh movingMesh = null;
  Vector2 startPosition; 
  Vector3 splineStartPosition;
  Vector3 normal;
  
  CoasterEditor(this.coaster)
  {
    controls = new FirstPersonControls (coaster.camera, document.body);
    mouseDownEvent =  document.body.onMouseDown.listen(onDocumentMouseDown);
    mouseMoveEvent =  document.body.onMouseMove.listen(onDocumentMouseMove);
    mouseUpEvent =  document.body.onMouseUp.listen(onDocumentMouseUp);
    
    mouseDownEvent.pause();
    mouseUpEvent.pause();
    mouseMoveEvent.pause();
  }
  
  void begin(){
    mouseDownEvent.resume();
    mouseUpEvent.resume();
    mouseMoveEvent.resume();
    
    coaster.spline.points.forEach(addSplineItem);
  }
  
  void end(){
    mouseDownEvent.pause();
    mouseUpEvent.pause();
    mouseMoveEvent.pause();
    
    objects.forEach( coaster.scene.remove );
    objects.clear();
  }
  
  void addSplineItem( CoasterSplineItem splinePoint )
  {
    CubeGeometry geometry = new CubeGeometry( 20, 20, 20, 1, 1, 1 );
    
    SelectMesh mesh = new SelectMesh(splinePoint, geometry, coaster.normalMaterial );
    objects.add(mesh);
    coaster.scene.add(mesh);
  }
  
  void onDocumentMouseDown( MouseEvent event )
  {
    event.preventDefault();

    Vector3 vector = new Vector3( ( event.clientX / window.innerWidth ) * 2 - 1, - ( event.clientY / window.innerHeight ) * 2 + 1, 0.5 );
    projector.unprojectVector( vector, coaster.camera );

    Ray ray = new Ray( coaster.camera.position, vector.subSelf( coaster.camera.position ).normalize() );

    List<Intersect> intersects = ray.intersectObjects( objects );
    
    if( !intersects.isEmpty ){
      Intersect intersect = intersects.first;
      SelectMesh mesh = intersect.object as SelectMesh;
      startPosition = new Vector2( event.page.x, event.page.y );
      
      splineStartPosition = mesh.splinePoint.position.clone();
      normal = intersect.face.normal;

      movingMesh = mesh;
    }
  }
  
  void onDocumentMouseUp( MouseEvent event )
  {
    event.preventDefault();
  
    if( movingMesh != null )
    {
      movingMesh.splinePoint.position = movingMesh.position.clone();
      coaster.spline.updateArcLengths();
      coaster.coasterGeometry.updateGeomtry();
    }
    
    movingMesh = null;
  }
  
  void onDocumentMouseMove( MouseEvent event )
  {
    if( movingMesh == null )
      return;
    
    movingMesh.position = splineStartPosition.clone().addSelf( new Vector3(event.page.x - startPosition.x, event.page.y - startPosition.y, 0) );
  }
  
  void update(num delta)
  {
    if( movingMesh == null )
      controls.update(delta / 4);
  }
  
  
  
}

class SelectMesh extends Mesh {
  
  CoasterSplineItem splinePoint;
  
  SelectMesh(this.splinePoint, Geometry geometry, Material material) : super(geometry, material){
    this.position = splinePoint.position;
    
  }
  
  
}