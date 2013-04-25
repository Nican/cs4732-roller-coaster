library RollerCoaster;

import 'dart:html';
import 'dart:math' as Math;
import 'dart:async';
import 'package:three/three.dart';
import 'package:three/extras/core/curve_utils.dart' as CurveUtils;
part 'CartController.dart';
part 'RollerCoaster.dart';
part 'CoasterSpline.dart';

class Canvas_Geometry_Cube
{
  PerspectiveCamera camera = new PerspectiveCamera( 70, window.innerWidth / window.innerHeight, 1, 10000 );
  Scene scene = new Scene();
  CanvasRenderer renderer;

  Mesh cube;
  Mesh direction;

  num windowHalfX;
  num windowHalfY;
  
  CoasterSpline spline = new CoasterSpline();
  CartController cc;
  
  var mouseX = 0, mouseY = 0;

  Canvas_Geometry_Cube()
  {

  }

  void run()
  {
    /*
    spline.addPoint(new Vector3(-400,0,0));
    spline.addPoint(new Vector3(-300,0,0));
    spline.addPoint(new Vector3(300,100,0));
    spline.addPoint(new Vector3(400,100,0));
    
    spline.addPoint(new Vector3(450,100, 50));
    
    spline.addPoint(new Vector3(400,100,100));
    spline.addPoint(new Vector3(300,100,100));
    spline.addPoint(new Vector3(-300,0,100));
    spline.addPoint(new Vector3(-400,0,100));
    
    spline.addPoint(new Vector3(-450,0, 50));
    */
  
    /*
    spline.addPoint(new Vector3(0,0,0), rotation: 0);
    spline.addPoint(new Vector3(100,0,0));
    spline.addPoint(new Vector3(200,100,0));
    spline.addPoint(new Vector3(300,100,100));
    spline.addPoint(new Vector3(200,100,200));
    spline.addPoint(new Vector3(0,0,200));
    spline.addPoint(new Vector3(-300,0,200));
    spline.addPoint(new Vector3(-400,0,100));
    spline.addPoint(new Vector3(-300,0,000));
    spline.addPoint(new Vector3(-100,0,000));
    */
    spline.addPoint(new Vector3(0,0,0), rotation: 0);
    spline.addPoint(new Vector3(0,0,300));
    spline.addPoint(new Vector3(150,50,300));
    spline.addPoint(new Vector3(300,100,300));
    spline.addPoint(new Vector3(300,100,0));
    
    
    cc = new CartController(spline, .16, .001);
    
    init();
    animate(0.0);
    
    
  }

  void init()
  {
    windowHalfX = window.innerWidth / 2;
    windowHalfY = window.innerHeight / 2;

    Element container = new Element.tag('div');
    document.body.nodes.add( container );
    
    document.onMouseMove.listen(onDocumentMouseMove);

    camera.position.y = 150;
    camera.position.z = 500;
    scene.add( camera );

    // Cube

    List materials = [];

    var rnd = new Math.Random();
    for ( int i = 0; i < 6; i ++ ) {
      materials.add( new MeshBasicMaterial( color: rnd.nextDouble() * 0xffffff ) );
    }

    cube = new Mesh( new CubeGeometry( 20, 20, 20, 1, 1, 1, materials ), new MeshFaceMaterial());// { 'overdraw' : true }) );
    cube.position.y = 150;
    //cube.overdraw = true; //TODO where is this prop?
    scene.add( cube );
    
    var coaster = new Mesh( new RollerCoaster( spline ), new MeshBasicMaterial( color: 0xe0e0e0, wireframe: true )  );
    scene.add(coaster);
    
    spline.points.forEach((CoasterSplineItem point){
      Mesh sphere = new Mesh( new SphereGeometry(8), new MeshBasicMaterial( color: 0xff0000, overdraw: true )  );
      sphere.position = point.position;
      scene.add(sphere);
    });
    
    Geometry geometry = new Geometry();
    geometry.vertices = spline.getPoints(500);
    var line = new Line(geometry, new LineBasicMaterial(color: 0xff0000));
    scene.add(line);
    
    direction = new Mesh( new SphereGeometry(8), new MeshBasicMaterial( color: 0x0000ff, overdraw: true )  );
    scene.add(direction);

    // Renderer
    renderer = new CanvasRenderer();
    renderer.setSize( window.innerWidth, window.innerHeight );

     container.nodes.add( renderer.domElement );
  }
  
  onDocumentMouseMove(MouseEvent event) {
    mouseX = ( event.clientX - window.innerWidth / 2 ) * 2;
    mouseY = ( event.clientY - window.innerHeight / 2 ) * 2;
  }

  void animate(num highResTime)
  {
    render(highResTime/4);
    window.requestAnimationFrame(animate);
  }
  
  Quaternion quarternionFromVecs( Vector3 v1, Vector3 v2 ){
    v1 = v1.clone().normalize();
    v2 = v2.clone().normalize();
    num dot = v1.dot(v2);
    
    if( dot >= 1.0 )
      return new Quaternion();
    
    //if((dot-1).abs() < 0.001 )
    //  return new Quaternion(0, 1, 0, 0);
    Quaternion q = new Quaternion();
    num s = Math.sqrt ((1+dot) * 2);
    num invs = 1 / s;
    Vector3 c = v1.clone().crossSelf(v2);
    
    q.x = c.x * invs;
    q.y = c.y * invs;
    q.z = c.z * invs;
    q.w = s * 0.5;
    
    q.normalize();
    
    return q;
  }
  
  num lastTime = 0;
  void render(num t)
  {
    camera.position.x += ( mouseX - camera.position.x ) * .1;
    camera.position.y += ( - mouseY - camera.position.y ) * .1;

    camera.lookAt( scene.position );
    
    num delta = Math.min(t-lastTime, 100.0);
    cc.update(delta);
    cube.position = cc.getCurPoint();
    num progress = (cc.traveledDist/cc.totalDist)%1;
    
        
    Quaternion quaternion = spline.getQuaternion(progress);
    
    //Vector3 forward = spline.getForward(progress);
    //Vector3 actualUp = new Vector3(0,1,0).crossSelf(forward).crossSelf(forward).negate().normalize(); 
    //Vector3 up = spline.getUp(progress);
    
    Vector3 p1 = spline.getPointAt(progress);
    Vector3 p2 = spline.getPointAt(progress+0.001);
    
    //direction.position = cube.position.clone().addSelf( spline.getForward(progress).multiplyScalar(50) );
    direction.position = p1.clone();

    
    Quaternion quaternion2 = quarternionFromVecs(new Vector3(0,0,1), p2.subSelf(p1) );
    
    //quaternion2.setFromAxisAngle(spline.getUp(progress).crossSelf(spline.getForward(progress)), 0);
    
    
    //Vector3 offset = quaternion.multiplyVector3(spline.getUp(progress));
    Vector3 offset = new Vector3(0,1,0);
    
    
    
    //cube.position.addSelf( offset.multiplyScalar(29) );
    
    cube.rotation.setEulerFromQuaternion(quaternion2);
    
    
    renderer.render( scene, camera );
    lastTime = t;
  }
}

void main() {
  new Canvas_Geometry_Cube().run();
}