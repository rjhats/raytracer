class Scene {
  public Vec origin = V(0, 0, 0);
  public String type = "";
  public Vec diffuseColor = V();
  public Vec diffuseAmbient = V();
  void intersectionMethod(Ray ray) {
  }
  Scene(Vec origin, String type) { 
    this.origin = origin; 
    this.type = type;
  }
  Vec lightObject(Ray ray) {
    return diffuseAmbient;
  }
  void setColor(Vec Color, Vec ambient) {
    this.diffuseColor = Color; 
    this.diffuseAmbient = ambient;
  }
}

class Ray extends Scene {
  public Vec direction = V();
  public float minDistance = 1.0e16;
  public int objectIndex = -1;
  public Scene scene = null;
  Ray(Vec origin) {
    super(origin, "ray");
  }
  Ray(Vec origin, Vec direction) {
    super(origin, "ray"); 
    this.direction = direction;
  }
  Vec flipDirection() {
    return direction.scale(-1.0);
  }
  String toString(){
    return "origin: " + origin.toString() + " Direction: "+ direction.toString();
  }
}

class namedScene{
  String name;
  Scene scene;
  namedScene(String name, Scene scene){this.name = name; this.scene = scene;}
  public boolean equals(namedScene o){
    return this.name.equals(o.name);
  }
  @Override public boolean equals(Object o){
    return (o instanceof namedScene) && (this.equals((namedScene) o));
  }

}