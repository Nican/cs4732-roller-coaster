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
part 'CoasterRider.dart';
part 'CoasterEditor.dart';
part 'SparkParticle.dart';
part 'SparkParticleHandler.dart';

abstract class GameState {
  void update(num delta);
  void begin();
  void end();
}

class SpiderCoaster
{
  PerspectiveCamera camera = new PerspectiveCamera( 90, window.innerWidth / window.innerHeight, 0.01, 100000 );
  MeshNormalMaterial normalMaterial = new MeshNormalMaterial( shading: SmoothShading );
  Material phongMaterial = new MeshLambertMaterial( color: 0xff0000, emissive: 0x441111  );
  WebGLRenderer renderer = new WebGLRenderer( clearColorHex: 0xffffff );
  CoasterSpline spline = new CoasterSpline();
  Scene scene = new Scene();
  Light light = new PointLight( 0xffffff );

  
  CoasterEditor editor;
  CoasterRider rider; 
  RollerCoaster coasterGeometry;
  
  GameState activeState;
  
  InputElement button;

  SpiderCoaster()
  {
    button = new InputElement(type: 'submit');
    editor = new CoasterEditor(this);
    rider = new CoasterRider(this);
    
    button.onClick.listen(buttonClicked);
    button.style.position = "absolute";
    button.value = "Editor";
    document.body.append(button);
    light.position = new Vector3( 0, 1000000, 0 );
    scene.add( light );
  }

  void run()
  {
    spline.addPoint(new Vector3(0,0,0), rotation: Math.PI);
    spline.addPoint(new Vector3(0,0,300));
    spline.addPoint(new Vector3(150,50,300));
    spline.addPoint(new Vector3(300,100,300));
    spline.addPoint(new Vector3(300,100,0));
    
    coasterGeometry = new RollerCoaster( spline );
    
    init();
    window.requestAnimationFrame(animate);
    
    activeState = rider;
    activeState.begin();
  }

  void init()
  {
    Element container = new Element.tag('div');
    document.body.nodes.add( container );

    camera.position.y = 150;
    camera.position.z = 500;
    scene.add( camera );

    var coaster = new Mesh( coasterGeometry, phongMaterial  );
    scene.add(coaster);
    
    //Geometry geometry = new Geometry();
    //geometry.vertices = spline.getPoints(500);
    //var line = new Line(geometry, new LineBasicMaterial(color: 0xff0000));
    //scene.add(line);
    
    Mesh floor = new Mesh( new PlaneGeometry(5000, 5000, 5, 5), new MeshLambertMaterial( color: 0x00dd00, ambient: 0x00dd00 ) );
    floor.position.y = -50;
    floor.rotation.x = -Math.PI / 2;
    scene.add(floor);

    renderer.setSize( window.innerWidth, window.innerHeight );

    container.nodes.add( renderer.domElement );
  }
  
  void buttonClicked(MouseEvent event){
    if( activeState == editor ){
      editor.end();
      activeState = rider;
      rider.begin();
    } else {
      rider.end();
      activeState = editor;
      editor.begin();
    }
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
    
    activeState.update(delta);    
    
    renderer.render( scene, camera );
    lastTime = t;
  }
}

void main() {
  new SpiderCoaster().run();
}