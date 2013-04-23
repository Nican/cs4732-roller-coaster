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
  
  CartController(this.curve, [this.Energy = 20, this.g = 0.1, this.drag =0.0001]){
    totalDist = curve.getLengths().last;
    traveledDist = 0;
    curHeight = curve.getPoint(0).y;
    forward = true;
    lastSpeed = calcSpeed();
    lastDirection = getPoint(.001).clone().subSelf(getPoint(0)).normalize();
  }
  
  Vector3 getPoint(num distance){
    return curve.getPointAt((distance/totalDist)%1);
  }
  
  num calcSpeed(){
    return Math.sqrt(Math.max(2*g*(maxHeight-curHeight),0));
  }
  
  Vector3 getNextPoint(num t_delta){
    num speed = calcSpeed();
    if(speed == 0){
      forward = !forward;
      if(getPoint(traveledDist - lastSpeed).y != curHeight){
        speed = lastSpeed;
      }
    }
    num distance = speed * (t_delta);
    
    Vector3 lastPoint = getPoint(traveledDist);
    
    if(forward){
      traveledDist += distance;
    }
    else{
      traveledDist -= distance;
    }
    
    Vector3 next = getPoint(traveledDist);
    
    //Force Calculations
    Vector3 direction = (next.clone().subSelf(lastPoint)).normalize();
    Vector3 acceleration = direction.clone().multiplyScalar(speed).subSelf(lastDirection.clone().multiplyScalar(lastSpeed)).divideScalar(t_delta);    
    acceleration.y += g;
    
    if(acceleration.length()/g>8){
      print("${(traveledDist%totalDist)/totalDist} \n\t${acceleration.clone().divideScalar(g)}");
    }
    
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
    
    return next;
  }
  
  Vector3 getNormal(num distance){
    //for now, assume up
    //TODO make this return the actual normal
    return new Vector3(0,1,0);
  }
  
  num get maxHeight => Energy/g;
      set maxHeight(num value) => Energy = value*g;
}

