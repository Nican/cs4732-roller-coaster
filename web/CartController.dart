part of RollerCoaster;

class CartController{
  Curve3D curve;
  num totalDist;
  num traveledDist;
  num Energy;
  num curHeight;
  num g;
  num drag;
  bool forward;
  num lastSpeed;
  Vector3 lastDirection;
  num cur_t;
  
  CartController(this.curve, [this.Energy = 20, this.g = 0.1, this.drag =0.0001]){
    totalDist = curve.getLengths().last;
    traveledDist = 0;
    curHeight = curve.getPoint(0).y;
    forward = true;
    lastSpeed = calcSpeed();
    lastDirection = getPoint(.001).clone().subSelf(getPoint(0)).normalize();
    cur_t = 0;
  }
  
  Vector3 getPoint(num distance){
    return curve.getPointAt((distance/totalDist)%1);
  }
  
  num calcSpeed(){
    return Math.sqrt(Math.max(2*g*(maxHeight-curHeight),0));
  }
  
  void update(num t_delta){
    //handle switching direction on hills
    num speed = calcSpeed();
    if(speed == 0 && getPoint(traveledDist - lastSpeed).y != curHeight){ //we've stopped and are on a hill
        forward = !forward;
        speed = lastSpeed;
    }
    
    //Save the current point
    Vector3 lastPoint = curve.getPoint(cur_t);
    
    //get the next location
    num distance = speed * (t_delta);  
    if(forward){
      traveledDist += distance;
    }
    else{
      traveledDist -= distance;
    }  
    cur_t = curve.getUtoTmapping((traveledDist/totalDist)%1);
    Vector3 next = curve.getPoint(cur_t);
    
    //Force Calculations
    Vector3 direction = (next.clone().subSelf(lastPoint)).normalize();
    Vector3 acceleration = direction.clone().multiplyScalar(speed).subSelf(lastDirection.clone().multiplyScalar(lastSpeed)).divideScalar(t_delta);    
    acceleration.y += g;
    
    Vector3 normal = getNormal(traveledDist);
    num gForce = acceleration.dot(normal)/g;
    
    Vector3 lateral = new Vector3().cross(normal, direction);
    num lateralForce = lateral.dot(acceleration)/g;
    
    num fowardForce = direction.dot(acceleration)/g;
      
    //set state
    curHeight = next.y;    
    lastDirection = direction;
    lastSpeed = speed;    
    Energy = Energy - drag*speed*distance;//Drag
  }
  
  Vector3 getCurPoint(){
    return curve.getPoint(cur_t);
  }
  
  Vector3 getNormal(num distance){
    //for now, assume up
    //TODO make this return the actual normal
    return new Vector3(0,1,0);
  }
  
  num get maxHeight => Energy/g;
      set maxHeight(num value) => Energy = value*g;
}

