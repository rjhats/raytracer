class Scene {
  public Material material = new Material(V());
  public boolean noise = false;
  public float noiseScale = 0;
  public boolean wood, marble, stone;
  public Box box;
  public Vec origin = V(0, 0, 0);
  public String type = "";
  public Vec diffuseColor = V();
  public Vec diffuseAmbient = V();
  public Vec center = V();
  void intersectionMethod(Ray ray) {
  }
  Vec getCenter() {
    return center;
  }
  Scene(String type) {
    this.type = type;
    origin = V();
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
  Box getBox() {
    return box;
  }
}

class Ray extends Scene {
  public Vec direction = V();
  public float minDistance = 1.0e16;
  public int sceneIndex = -1;
  public Vec normal;
  public Vec hit;
  Ray(Vec origin) {
    super(origin, "ray");
  }
  Ray(Vec origin, Vec direction) {
    super(origin, "ray"); 
    this.direction = direction;
  }
  Scene getScene() {
    return sceneObjects.get(sceneIndex);
  }
  Vec flipDirection() {
    //return V(direction.x * -1,direction.y * -1,direction.z * -1);
    //return direction.scale(-1.0);
    return scaleV(direction, -1.0);
  }
  String toString() {
    return "origin: " + origin.toString() + " Direction: "+ direction.toString();
  }
}

class namedScene {
  String name;
  Scene scene;
  namedScene(String name, Scene scene) {
    this.name = name; 
    this.scene = scene;
  }
  public boolean equals(namedScene o) {
    return this.name.equals(o.name);
  }
  @Override public boolean equals(Object o) {
    return (o instanceof namedScene) && (this.equals((namedScene) o));
  }
}