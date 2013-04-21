library RollerCoaster;

import 'dart:html';
import 'dart:math' as Math;
import 'dart:async';
import 'package:three/three.dart';
import 'CartController.dart';

part  'RollerCoaster.dart';


class Canvas_Geometry_Cube
{
  Element container;

  PerspectiveCamera camera;
  Scene scene;
  CanvasRenderer renderer;

  Mesh cube;
  Mesh plane;

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
    //document.body.appendChild( container );
    document.body.nodes.add( container );

    Element info = new Element.tag('div');
    info.style.position = 'absolute';
    info.style.top = '10px';
    info.style.width = '100%';
    info.style.textAlign = 'center';
    info.innerHtml = 'Drag to spin the cube';
    //container.appendChild( info );
    container.nodes.add( info );

    scene = new Scene();

    camera = new PerspectiveCamera( 70, window.innerWidth / window.innerHeight, 1, 10000 );
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
    

    // Plane

    plane = new Mesh( new PlaneGeometry( 200, 200 ), new MeshBasicMaterial( color: 0xe0e0e0, overdraw: true ) );
    plane.rotation.x = - 90 * ( Math.PI / 180 );
    //plane.overdraw = true; //TODO where is this prop?
    //scene.add( plane );

    renderer = new CanvasRenderer();
    renderer.setSize( window.innerWidth, window.innerHeight );


    //container.appendChild( renderer.domElement );
    container.nodes.add( renderer.domElement );

    document.onMouseDown.listen(onDocumentMouseDown);
    document.onTouchStart.listen(onDocumentTouchStart);
    document.onTouchMove.listen(onDocumentTouchMove);
  
    //new Timer.periodic(new Duration(milliseconds:10), (Timer timer) => animate());
    
  }

  void onDocumentMouseDown( event )
  {
    event.preventDefault();

    document.onMouseMove.listen(onDocumentMouseMove);
    document.onMouseUp.listen(onDocumentMouseUp);
    document.onMouseOut.listen(onDocumentMouseOut);

    mouseXOnMouseDown = event.clientX - windowHalfX;
    targetRotationOnMouseDown = targetRotation;
  }

  void onDocumentMouseMove( event )
  {
    mouseX = event.clientX - windowHalfX;

    targetRotation = targetRotationOnMouseDown + ( mouseX - mouseXOnMouseDown ) * 0.02;
  }

  void onDocumentMouseUp( event )
  {
    //document.onMouseMove.remove(onDocumentMouseMove);
    //document.onMouseUp.remove(onDocumentMouseUp);
    //document.onMouseOut.remove(onDocumentMouseOut);
  }

  void onDocumentMouseOut( event )
  {
    //document.onMouseMove.remove(onDocumentMouseMove);
    //document.onMouseUp.remove(onDocumentMouseUp);
    //document.onMouseOut.remove(onDocumentMouseOut);
  }

  void onDocumentTouchStart( event )
  {
    if ( event.touches.length == 1 )
    {
      event.preventDefault();

      mouseXOnMouseDown = event.touches[ 0 ].pageX - windowHalfX;
      targetRotationOnMouseDown = targetRotation;
    }
  }

  void onDocumentTouchMove( event )
  {
    if ( event.touches.length == 1 )
    {
      event.preventDefault();

      mouseX = event.touches[ 0 ].pageX - windowHalfX;
      targetRotation = targetRotationOnMouseDown + ( mouseX - mouseXOnMouseDown ) * 0.05;
    }
  }


  void animate(num highResTime)
  {
//    window.webkitRequestAnimationFrame(animate);
//    print('win dynamic ${window.dynamic['requestAnimationFrame']}');
//    if ( window.dynamic['requestAnimationFrame'] != null )
//      window.dynamic['requestAnimationFrame']( animate );

    render(highResTime);
    window.requestAnimationFrame(animate);
  }
  
  num lastTime = 0;
  void render(t)
  {
    cube.position = cc.getNextPoint(t-lastTime);
    cube.position.y += 50;

    renderer.render( scene, camera );
    lastTime = t;
  }
}

void main() {
  new Canvas_Geometry_Cube().run();
}