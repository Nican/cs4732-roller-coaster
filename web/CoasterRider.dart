part of RollerCoaster;

class RiderCameraType {
  static const FIRST = 0;
  static const CHASE = 1;
  static const FREE = 2;
}

class CoasterRider implements GameState  {
  
  SpiderCoaster coaster;
  CartController cc;
  Mesh cube;
  SparkParticleHandler psystem;
  //bool thirdPerson = false;
  int camera = RiderCameraType.FIRST;
  
  StreamSubscription<KeyboardEvent> keyDownEvent;
  FirstPersonControls controls;
  
  CoasterRider(SpiderCoaster this.coaster){
    // Cube
    cube = new Mesh( new CubeGeometry( 20, 20, 20, 1, 1, 1 ), coaster.normalMaterial );
    cube.useQuaternion = true;
    psystem = new SparkParticleHandler(250, coaster.scene, 20, 10, false);
    keyDownEvent = document.body.onKeyDown.listen(keyHandler);
    keyDownEvent.pause();
    controls = new FirstPersonControls (coaster.camera, document.body);
  }
  
  void begin()
  {
    cc = new CartController(coaster.spline, .16, .001);
    coaster.scene.add( cube );
    coaster.camera.useQuaternion = true;
    psystem.add();
    psystem.active = true;
    keyDownEvent.resume();
  }
  
  void end()
  {
    coaster.scene.remove( cube );
    coaster.camera.useQuaternion = false;
    psystem.remove();
    psystem.active = false;
    keyDownEvent.pause();
  }
  
  void update(num delta)
  {
    cc.update(delta);
    cube.position = cc.getCurPoint();
    
    Vector3 forward = coaster.spline.getForward(cc.cur_t);        
    Quaternion quaternion = coaster.spline.getQuaternion2(cc.cur_t);  
    
    cube.quaternion = quaternion;
    cube.position.addSelf( quaternion.multiplyVector3(new Vector3(0,1,0)).multiplyScalar(18) );
  
    /*
    if(!thirdPerson){
      coaster.camera.position = cube.position;
      coaster.camera.quaternion = cube.quaternion;
    }
    else{
      controls.update(delta);
    }
    */
    if( camera == RiderCameraType.FREE ){
      controls.update(delta);
    } else {
      coaster.camera.quaternion = cube.quaternion;
      coaster.camera.position = cube.position.clone();
      
      if( camera == RiderCameraType.CHASE ){
        coaster.camera.position.subSelf( cube.quaternion.multiplyVector3( new Vector3(0, -60, -100) ) );        
      }
    }
    

    psystem.active = cc.forces.x.abs()>2;
    psystem.position = cube.position.clone().addSelf(quaternion.multiplyVector3(new Vector3(cc.forces.x.isNegative?20:-10,-10,cc.forward?-10:10)));
    psystem.forward = quaternion.multiplyVector3(new Vector3(cc.forces.x.isNegative?1:-1,0,0));
    psystem.velocity = forward.clone().multiplyScalar(cc.calcSpeed()*.5*(cc.forward?1:-1));
    psystem.update();
  }
  void keyHandler(KeyboardEvent e){
    if(e.keyCode == KeyCode.T){
      //thirdPerson = !thirdPerson;
      //coaster.camera.useQuaternion = !coaster.camera.useQuaternion;
      camera = (camera + 1) % 3;
      
      coaster.camera.useQuaternion = camera != RiderCameraType.FREE;
    }
  }
}