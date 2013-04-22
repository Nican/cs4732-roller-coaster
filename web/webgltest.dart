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

  num windowHalfX;
  num windowHalfY;
  
  CoasterSpline spline;
  CartController cc;

  Canvas_Geometry_Cube()
  {

  }

  void run()
  {
    spline = new CoasterSpline();
    spline.addPoint(new Vector3(0,0,0), rotation: -Math.PI / 2);
    spline.addPoint(new Vector3(100,0,0));
    spline.addPoint(new Vector3(200,100,0));
    spline.addPoint(new Vector3(300,100,10));
    spline.addPoint(new Vector3(200,100,200));
    spline.addPoint(new Vector3(0,0,200));
    spline.addPoint(new Vector3(-300,0,200));
    spline.addPoint(new Vector3(-400,0,100));
    spline.addPoint(new Vector3(-300,0,000));
    spline.addPoint(new Vector3(-100,0,000));
    
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

    camera.position.y = 150;
    camera.position.z = 500;
    scene.add( camera );

    // Cube

    List materials = [];

    var rnd = new Math.Random();
    for ( int i = 0; i < 6; i ++ ) {
      materials.add( new MeshBasicMaterial( color: rnd.nextDouble() * 0xffffff ) );
    }

    cube = new Mesh( new CubeGeometry( 50, 50, 50, 1, 1, 1, materials ), new MeshFaceMaterial());// { 'overdraw' : true }) );
    cube.position.y = 150;
    //cube.overdraw = true; //TODO where is this prop?
    scene.add( cube );
    
    var coaster = new Mesh( new RollerCoaster( spline ), new MeshBasicMaterial( color: 0xe0e0e0, overdraw: true )  );
    scene.add(coaster);
    

    // Renderer
    renderer = new CanvasRenderer();
    renderer.setSize( window.innerWidth, window.innerHeight );

     container.nodes.add( renderer.domElement );
  }

  void animate(num highResTime)
  {
    render(highResTime);
    window.requestAnimationFrame(animate);
  }
  
  num lastTime = 0;
  void render(num t)
  {
    num delta = Math.min(t-lastTime, 100.0);
    cube.position = cc.getNextPoint(delta);
    cube.position.y += 50;

    renderer.render( scene, camera );
    lastTime = t;
  }
}

void main() {
  new Canvas_Geometry_Cube().run();
}