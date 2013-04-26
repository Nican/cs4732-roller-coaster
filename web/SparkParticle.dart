part of RollerCoaster;

class SparkParticle extends ParticleSystem{
  Vector3 velocity = new Vector3(0,0,0);
  num _ttl;
  num origTTL;
  num g;
  
  SparkParticle(Geometry geom, Material m, [this.velocity, this._ttl=0, this.g = .02]) : super(geom,m){
    origTTL = ttl;
  }
  
  void update(){
    if(_ttl == 0){
      visible = false;
      return;
    }
    position.addSelf(velocity);
    velocity.addSelf(new Vector3(0,-g,0));
    _ttl -= 1;
    this.material = new ParticleBasicMaterial(color:new Color().setRGB(1,ttl/origTTL*.125+.875, ttl/origTTL).getHex());
  }
  
  
  set ttl(num value){
    origTTL=value;
    _ttl=value;
  }
  num get ttl => _ttl;
}