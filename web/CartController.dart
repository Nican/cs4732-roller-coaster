part of RollerCoaster;

class CartController{
  Curve3D curve;
  num totalDist;
  num traveledDist;
  num maxHeight;
  num curHeight;
  num g;
  CartController(this.curve, [this.maxHeight = 200, this.g = 0.1]){
    totalDist = curve.getLengths().last;
    traveledDist = 0;
    curHeight = curve.getPoint(0).y;
  }
  
  Vector3 getPoint(num distance){
    return curve.getPointAt((distance/totalDist)%1);
  }
  
  Vector3 getNextPoint(num t_delta){
    num velocity = Math.sqrt(Math.max(2*g*(maxHeight-curHeight),0));
    num distance = velocity * (t_delta);
    traveledDist += distance;
    Vector3 next = getPoint(traveledDist);
    curHeight = next.y;
    return next;
  }
}

