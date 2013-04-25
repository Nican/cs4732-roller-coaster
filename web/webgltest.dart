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
  PerspectiveCamera camera = new PerspectiveCamera( 90, window.innerWidth / window.innerHeight, 0.01, 100000 );
  Scene scene = new Scene();
  WebGLRenderer renderer;

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
    spline.addPoint(new Vector3(0,0,0), rotation: Math.PI);
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
    
    MeshNormalMaterial mat = new MeshNormalMaterial( shading: SmoothShading );
    
    var coaster = new Mesh( new RollerCoaster( spline ), mat  );
    scene.add(coaster);
    
    spline.points.forEach((CoasterSplineItem point){
      //Mesh sphere = new Mesh( new SphereGeometry(8), new MeshBasicMaterial( color: 0xff0000, overdraw: true )  );
     // sphere.position = point.position;
      //scene.add(sphere);
    });
    
    Geometry geometry = new Geometry();
    geometry.vertices = spline.getPoints(500);
    var line = new Line(geometry, new LineBasicMaterial(color: 0xff0000));
    scene.add(line);
    
    Mesh floor = new Mesh( new PlaneGeometry(5000, 5000, 5, 5), new MeshNormalMaterial( shading: SmoothShading )  );
    floor.position.y -= 50;
    floor.rotation.x += -Math.PI / 2;
    scene.add(floor);
    
    //direction = new Mesh( new SphereGeometry(8), new MeshBasicMaterial( color: 0x0000ff, overdraw: true )  );
    //scene.add(direction);

    // Renderer
    renderer = new WebGLRenderer( clearColorHex: 0xffffff );
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
  
  num lastTime = 0;
  void render(num t)
  {
    camera.position.x += ( mouseX - camera.position.x ) * .1;
    camera.position.y += ( - mouseY - camera.position.y ) * .1;
    camera.lookAt( scene.position );
    
    num delta = Math.min(t-lastTime, 100.0);
    
    cc.update(delta);
    cube.position = cc.getCurPoint();
    
    Vector3 forward = spline.getForward(cc.cur_t);        
    Quaternion quaternion = spline.getQuaternion(cc.cur_t);    
    Quaternion quaternion2 = new Quaternion().rotationBetween(new Vector3(0,0,-1), forward );
    quaternion.multiplySelf( quaternion2 );
    
    cube.rotation.setEulerFromQuaternion(quaternion);
    cube.position.addSelf( quaternion.multiplyVector3(new Vector3(0,1,0)).multiplyScalar(18) );
    
    camera.position = cube.position;
    camera.rotation = cube.rotation;
    
    renderer.render( scene, camera );
    lastTime = t;
  }
}

void main() {
  new Canvas_Geometry_Cube().run();
}