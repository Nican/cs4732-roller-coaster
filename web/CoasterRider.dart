part of RollerCoaster;

class CoasterRider implements GameState  {
  
  SpiderCoaster coaster;
  CartController cc;
  Mesh cube;
  
  CoasterRider(SpiderCoaster this.coaster){
    // Cube
    cube = new Mesh( new CubeGeometry( 20, 20, 20, 1, 1, 1 ), coaster.normalMaterial );
    cube.useQuaternion = true;
  }
  
  void begin()
  {
    cc = new CartController(coaster.spline, .16, .001);
    coaster.scene.add( cube );
    coaster.camera.useQuaternion = true;
  }
  
  void end()
  {
    coaster.scene.remove( cube );
    coaster.camera.useQuaternion = false;
  }
  
  void update(num delta)
  {
    cc.update(delta);
    cube.position = cc.getCurPoint();
    
    Vector3 forward = coaster.spline.getForward(cc.cur_t);        
    Quaternion quaternion = coaster.spline.getQuaternion2(cc.cur_t);  
    
    cube.quaternion = quaternion;
    cube.position.addSelf( quaternion.multiplyVector3(new Vector3(0,1,0)).multiplyScalar(18) );
    
    coaster.camera.position = cube.position;
    coaster.camera.quaternion = cube.quaternion;
    
  }
  
}