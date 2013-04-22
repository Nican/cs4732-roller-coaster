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
  num lastVelocity;
  
  CartController(this.curve, [this.Energy = 20, this.g = 0.1, this.drag =0.0001]){
    totalDist = curve.getLengths().last;
    traveledDist = 0;
    curHeight = curve.getPoint(0).y;
    forward = true;
    lastVelocity = 0;
  }
  
  Vector3 getPoint(num distance){
    return curve.getPointAt((distance/totalDist)%1);
  }
  
  Vector3 getNextPoint(num t_delta){
    num velocity = Math.sqrt(Math.max(2*g*(maxHeight-curHeight),0));
    print(velocity);
    if(velocity == 0){
      forward = !forward;
      if(getPoint(traveledDist - lastVelocity).y != curHeight){
        velocity = lastVelocity;
      }
    }
    print("\t"+velocity.toString());
    num distance = velocity * (t_delta);
    
    
    if(forward){
      traveledDist += distance;
    }
    else{
      traveledDist -= distance;
    }
    
    Vector3 next = getPoint(traveledDist);
    curHeight = next.y;
    lastVelocity = velocity;
    
    Energy = Energy - drag*velocity*distance;
    
    return next;
  }
  
  num get maxHeight => Energy/g;
}

