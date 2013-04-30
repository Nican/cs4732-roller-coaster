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
  Vector3 position = new Vector3(0,0,0);
  Vector3 forward = new Vector3(1,0,0);
  Vector3 velocity = new Vector3(0,0,0);
  SparkParticleHandler(this.size, this.scene, [this.particlesToGenerate = 25, this.defaultTTL = 20, this.active = true,this.random ]){
    if(random == null){
      random = new Math.Random();
    }
    Geometry point = new Geometry();
    point.vertices.add(new Vector3(0,0,0));
    IParticleMaterial material = new ParticleBasicMaterial(color:new Color().setRGB(1, 0, 0).getHex(), visible:true);
    particles = new List.generate(size, (index) => new SparkParticle(point, material, new Vector3(0,0,0)));
    add();
    curIndex = 0;
  }
  void update(){
    if(active){
      for(num i=0;i<particlesToGenerate;i++){
        addParticle(position, forward);
      }
    }
    particles.forEach((element)=>element.update());
  }
  void addParticle(Vector3 position, Vector3 forward, [speed = 2]){
    curIndex++;
    curIndex %= size;
    particles[curIndex].position = position.clone();
    particles[curIndex].velocity.x = (forward.x + random.nextDouble()/4-.125) * (random.nextDouble()/4+.875)*speed + velocity.x;
    particles[curIndex].velocity.y = (forward.y + random.nextDouble()/4-.125) * (random.nextDouble()/4+.875)*speed + velocity.y;
    particles[curIndex].velocity.z = (forward.z + random.nextDouble()/4-.125) * (random.nextDouble()/4+.875)*speed + velocity.z;
    particles[curIndex].visible = true;
    particles[curIndex].ttl = (defaultTTL*(((random.nextDouble()-.5)/4+1))).ceil();
  }
  void remove(){
    particles.forEach((SparkParticle element) => scene.remove(element));
  }
  void add(){
    particles.forEach((SparkParticle element) => scene.add(element));
  }
}