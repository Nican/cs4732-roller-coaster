part of RollerCoaster;

class CoasterRider implements GameState  {
  
  SpiderCoaster coaster;
  CartController cc;
  Mesh cube;
  SparkParticleHandler psystem;
  
  CoasterRider(SpiderCoaster this.coaster){
    // Cube
    cube = new Mesh( new CubeGeometry( 20, 20, 20, 1, 1, 1 ), coaster.normalMaterial );
    psystem = new SparkParticleHandler(250, coaster.scene, 20, 10, false);
  }
  
  void begin()
  {
    cc = new CartController(coaster.spline, .16, .001);
    coaster.scene.add( cube );
    psystem.add();
    psystem.active = true;
  }
  
  void end()
  {
    coaster.scene.remove( cube );
    psystem.remove();
    psystem.active = false;
  }
  
  void update(num delta)
  {
    cc.update(delta);
    cube.position = cc.getCurPoint();
    
    Vector3 forward = coaster.spline.getForward(cc.cur_t);        
    Quaternion quaternion = coaster.spline.getQuaternion(cc.cur_t);    
    Quaternion quaternion2 = new Quaternion().rotationBetween(new Vector3(0,0,-1), forward );
    quaternion.multiplySelf( quaternion2 );
    
    cube.rotation.setEulerFromQuaternion(quaternion);
    cube.position.addSelf( quaternion.multiplyVector3(new Vector3(0,1,0)).multiplyScalar(18) );
    
    psystem.active = cc.forces.x.abs()>2;
    psystem.position = cube.position.clone().addSelf(quaternion.multiplyVector3(new Vector3(cc.forces.x.isNegative?20:-10,-10,cc.forward?-10:10)));
    psystem.forward = quaternion.multiplyVector3(new Vector3(cc.forces.x.isNegative?1:-1,0,0));
    psystem.velocity = forward.clone().multiplyScalar(cc.calcSpeed());
    psystem.update();
    
    coaster.camera.position = cube.position;
    coaster.camera.rotation = cube.rotation;   
  }
  
}