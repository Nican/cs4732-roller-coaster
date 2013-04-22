library RollerCoaster;

import 'dart:html';
import 'dart:math' as Math;
import 'dart:async';
import 'package:three/three.dart';
part 'CartController.dart';
part  'RollerCoaster.dart';


class Canvas_Geometry_Cube
{
  Element container;

  PerspectiveCamera camera = new PerspectiveCamera( 70, window.innerWidth / window.innerHeight, 1, 10000 );
  Scene scene = new Scene();
  CanvasRenderer renderer;

  Mesh cube;

  num targetRotation;
  num targetRotationOnMouseDown;

  num mouseX;
  num mouseXOnMouseDown;

  num windowHalfX;
  num windowHalfY;
  
  SplineCurve3 spline;
  CartController cc;

  Canvas_Geometry_Cube()
  {

  }

  void run()
  {
    spline = new SplineCurve3([
                               new Vector3(0,0,0),
                               new Vector3(100,0,0),
                               new Vector3(200,100,0),
                               new Vector3(300,100,10),
                               new Vector3(200,100,200),
                               new Vector3(0,0,200),
                               new Vector3(-100,0,100),
                               new Vector3(0,0,0)
                               ]);
    cc = new CartController(spline, .16, .001);
    init();
    animate(0.0);
    
    
  }

  void init()
  {
    targetRotation = 0;
    targetRotationOnMouseDown = 0;

    mouseX = 0;
    mouseXOnMouseDown = 0;

    windowHalfX = window.innerWidth / 2;
    windowHalfY = window.innerHeight / 2;

    container = new Element.tag('div');
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