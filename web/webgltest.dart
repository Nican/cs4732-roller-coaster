library RollerCoaster;

import 'dart:html';
import 'dart:math' as Math;
import 'dart:async';
import 'package:three/three.dart';
import 'package:three/extras/core/curve_utils.dart' as CurveUtils;
import 'package:three/extras/controls/firstpersoncontrols.dart';
part 'CartController.dart';
part 'RollerCoaster.dart';
part 'CoasterSpline.dart';
part 'CoasterEditor.dart';

class Canvas_Geometry_Cube
{
  PerspectiveCamera camera = new PerspectiveCamera( 90, window.innerWidth / window.innerHeight, 0.01, 100000 );
  FirstPersonControls controls;
  Scene scene = new Scene();
  WebGLRenderer renderer;

  Mesh cube;
  
  CoasterSpline spline = new CoasterSpline();
  CartController cc;
  
  var mouseX = 0, mouseY = 0;

  Canvas_Geometry_Cube()
  {
    
  }

  void run()
  {
    spline.addPoint(new Vector3(0,0,0), rotation: Math.PI);
    spline.addPoint(new Vector3(0,0,300));
    spline.addPoint(new Vector3(150,50,300));
    spline.addPoint(new Vector3(300,100,300));
    spline.addPoint(new Vector3(300,100,0));
    
    
    cc = new CartController(spline, .16, .001);
    
    init();
    window.requestAnimationFrame(animate);
  }

  void init()
  {
    controls = new FirstPersonControls (this.camera, document.body);

    Element container = new Element.tag('div');
    document.body.nodes.add( container );
    
    document.onMouseMove.listen(onDocumentMouseMove);

    camera.position.y = 150;
    camera.position.z = 500;
    scene.add( camera );

    // Cube

    MeshNormalMaterial mat = new MeshNormalMaterial( shading: SmoothShading );
    
    cube = new Mesh( new CubeGeometry( 20, 20, 20, 1, 1, 1 ), mat );
    scene.add( cube );
    
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
    num delta = Math.min(t-lastTime, 100.0);
    
    cc.update(delta);
    cube.position = cc.getCurPoint();
    
    Vector3 forward = spline.getForward(cc.cur_t);        
    Quaternion quaternion = spline.getQuaternion(cc.cur_t);    
    Quaternion quaternion2 = new Quaternion().rotationBetween(new Vector3(0,0,-1), forward );
    quaternion.multiplySelf( quaternion2 );
    
    cube.rotation.setEulerFromQuaternion(quaternion);
    cube.position.addSelf( quaternion.multiplyVector3(new Vector3(0,1,0)).multiplyScalar(18) );
    
    //camera.position = cube.position;
    //camera.rotation = cube.rotation;
    controls.update(delta / 4);
    
    renderer.render( scene, camera );
    lastTime = t;
  }
}

void main() {
  new Canvas_Geometry_Cube().run();
}