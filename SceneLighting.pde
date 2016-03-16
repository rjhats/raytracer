class PLight extends Light {
  PLight(Vec origin) {
    super(origin, "point_light");
  }
  PLight(Vec origin, Vec light_color) {
    super(origin, "point_light"); 
    this.light_color = light_color;
  }
  Vec getDirection(Vec hit){return normalizeV(subV(origin, hit));}
  
}

class diskLight extends Light{
  public Vec normal;
  public float radius;
  diskLight(Vec origin) { super(origin, "disk_light");}
  diskLight(Vec origin, float radius, Vec normal, Vec light_color) { super(origin, "disk_light");this.radius = radius; this.normal = normal; this.light_color = light_color;}
  Vec getDirection(Vec hit){
    Vec V = crossV(normal, V(1,0,0)).normalize();
    if(abs(dotV(V)) < .00005 ){V = crossV(normal, V(0,1,0)).normalize();}
    if(abs(dotV(V)) < .00005 ){V = crossV(normal, V(0,0,1)).normalize();}
    Vec R = crossV( normal,V).normalize();
    float theta = random(2*PI);
    float randRad = random(radius);
    Vec pt = addV(origin,addV(scaleV(V,sin(theta)*randRad), scaleV(R, cos(theta)*randRad)));
    return normalizeV(subV(pt, hit));
  }
}

class Light{
  public Vec origin = V(0, 0, 0);
  public String type = "";
  public Vec light_color;
  Light(Vec origin, String type) { 
    this.origin = origin; 
    this.type = type;
  }
  Vec getDirection(Vec hit){return V();}

}