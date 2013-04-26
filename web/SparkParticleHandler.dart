part of RollerCoaster;

class SparkParticleHandler {
  List<SparkParticle> particles;
  num size;
  num curIndex;
  Math.Random random;
  Scene scene;
  num particlesToGenerate;
  bool active;
  num defaultTTL;
  Vector3 location = new Vector3(0,0,0);
  Vector3 forward = new Vector3(1,0,0);
  SparkParticleHandler(this.size, this.scene, [this.particlesToGenerate = 25, this.defaultTTL = 20, this.active = true,this.random ]){
    if(random == null){
      random = new Math.Random();
    }
    Geometry point = new Geometry();
    point.vertices.add(new Vector3(0,0,0));
    IParticleMaterial material = new ParticleBasicMaterial(color:new Color().setRGB(1, 0, 0).getHex(), visible:true);
    particles = new List.generate(size, (index) => new SparkParticle(point, material, new Vector3(0,0,0)));
    particles.forEach((SparkParticle element) => scene.add(element));
    curIndex = 0;
  }
  void update(){
    if(active){
      for(num i=0;i<particlesToGenerate;i++){
        addParticle(location, forward);
      }
    }
    particles.forEach((element)=>element.update());
  }
  void addParticle(Vector3 location, Vector3 forward, [speed = .75]){
    curIndex++;
    curIndex %= size;
    particles[curIndex].position = location.clone();
    particles[curIndex].velocity.x = (forward.x + random.nextDouble()/4-.125) * (random.nextDouble()/4+.875)*speed;
    particles[curIndex].velocity.y = (forward.y + random.nextDouble()/3+.5) * (random.nextDouble()/4+.875)*speed;
    particles[curIndex].velocity.z = (forward.z + random.nextDouble()/4-.125) * (random.nextDouble()/4+.875)*speed;
    particles[curIndex].visible = true;
    particles[curIndex].ttl = (defaultTTL*(((random.nextDouble()-.5)/4+1))).ceil();
  }
}