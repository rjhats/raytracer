//---------------Instance---------------

class Instance extends Scene{
  int hitAmount =  0;
  public Transform transform = new Transform();
  public Transform tempTransform = new Transform();
  public Transform tempTransform2 = new Transform();
  public int scenePosition;
  Instance(Transform transform, int scenePosition){
    super("instance"); this.transform.matrix=transform.matrix; this.scenePosition = scenePosition;makeInverse(); box = namedObjects.get(scenePosition).scene.getBox();}
  void makeInverse(){
    tempTransform.matrix = inverse(transform.matrix);
    tempTransform2.matrix = adjoint(transform.matrix);
    //scene.origin = transform.transform(scene.origin);
    
  }
  void intersectionMethod(Ray ray){
    Ray tempRay = new Ray(tempTransform.transform(ray.origin), tempTransform2.transform(ray.direction));
    //tempRay.origin = tempTransform.transform(tempRay.origin);
    //tempRay.direction = tempTransform.transform(tempRay.direction).normalize();
    //tempRay.direction = scaleV(freeTransform(adjoint(transform.matrix), (tempRay.direction)),1).normalize();
    //if(hitAmount <=100)println(tempRay.toString());
    //hitAmount++;
    namedObjects.get(scenePosition).scene.intersectionMethod(tempRay);
    if(tempRay.minDistance < ray.minDistance) {
      //println("hit");
      ray.sceneIndex = sceneObjects.indexOf(this);
      ray.minDistance = tempRay.minDistance;
      //ray.hit = tempRay.hit;
      ray.hit = travelV(ray.origin, ray.direction, ray.minDistance);//
      //ray.normal = tempTransform.transform(tempRay.direction);//freeTransform(transform.adjoint(transform.matrix), (tempRay.normal));
      //ray.normal = tempRay.normal;
      //ray.normal = tempTransform2.transform(tempRay.normal);
      //ray.normal = normalizeV(subV(ray.hit, transform.transform(namedObjects.get(scenePosition).scene.origin)));
      ray.normal = tempTransform2.transform(tempRay.normal).normalize();
    
    
    } 
  }
  
  Vec lightObject(Ray ray) {
    //hitAmount++;
    //println(ray.hit.toString() + " _ _ _ _ "+ hitAmount);
    //return V(1,1,1);
    //ray.origin = tempTransform.transform(ray.origin);
    //ray.origin = tempTransform.transform(ray.origin);
    //ray.normal = tempTransform2.transform(scaleV(ray.normal, -1));
    //ray.direction x  = tempTransform.transform(ray.direction);
    return namedObjects.get(scenePosition).scene.lightObject(ray);    
  }
}

//---------------End Instance---------------

//---------------Sphere---------------


class Sphere extends Scene {
  public float radius;
  private Box makeBox(){
    Vec mins = V();
    Vec maxs = V();
    mins.x = origin.x - radius;
    maxs.x = origin.x + radius;
    mins.y = origin.y - radius;
    maxs.y = origin.y + radius;
    mins.z = origin.z + radius;
    maxs.z = origin.z - radius;
    
    return new Box(mins, maxs);
  }
  Sphere() {
    super("sphere");
    box = makeBox();
  }
  Sphere(float radius, Vec origin) {
    super(origin, "sphere"); 
    this.radius = radius;
    box = makeBox();
  }
  Sphere(float radius, Vec origin, Vec diffuseColor, Vec diffuseAmbient) { 
    super(origin, "sphere"); 
    this.radius = radius;
    this.diffuseColor = diffuseColor; 
    this.diffuseAmbient = diffuseAmbient;
    box = makeBox();
  } 

  void intersectionMethod(Ray ray) {
    Vec SO = subV(origin, ray.origin);
    float a = dotV(ray.direction);
    float b = 2 * dotV(SO, ray.direction);
    float c = dotV(SO) - sq(radius);
    float bac = sq(b) - (4*a*c);
    if (bac>0.0) {
      float d1 = (-b - sqrt(sq(b) - (4*a*c)))/ (2*a);
      float d2 = (-b + sqrt(sq(b) - (4*a*c)))/ (2*a);
      if (-d1 > 0.0 && d1>d2 && abs(d1) < abs(ray.minDistance)) {
        ray.minDistance = abs(d1);
        ray.sceneIndex = sceneObjects.indexOf(this);
        ray.hit = travelV(ray.origin, ray.direction, ray.minDistance); 
        ray.normal = normalizeV(subV(ray.hit, origin));
      } else if (-d2 > 0.0 && d2>d1 && abs(d2) < abs(ray.minDistance)) {
        ray.minDistance = abs(d2);
        ray.sceneIndex = sceneObjects.indexOf(this);
        ray.hit = travelV(ray.origin, ray.direction, ray.minDistance); 
        ray.normal = normalizeV(subV(ray.hit, origin));      
      }
    }
  }

  Vec lightObject(Ray ray) {
    Vec surfaceColor = V();
    //if(dotV(norHit, direction) > 0.0)norHit = scaleV(norHit, -1.0);
    for (int i =0; i< lights.size(); i++) {
      Vec lightDirection = lights.get(i).getDirection(ray.hit);
      Ray reverse = new Ray(ray.hit, scaleV(lightDirection, 1));
      for (int j =0; j<sceneObjects.size(); j++) {
        if (sceneObjects.get(j) != this){sceneObjects.get(j).intersectionMethod(reverse);}
        //if(reverse.sceneIndex > -1) println("satisfy");
      }
      if (reverse.sceneIndex < 0) {
        float diffCoeff = dotV(lightDirection, ray.normal);
        surfaceColor = addV(surfaceColor, multV(scaleV(diffuseColor, max(0, diffCoeff)), lights.get(i).light_color) );
      }
      //else return V(1,1,1);
    }
    return addV(diffuseAmbient, surfaceColor);
    //return ray.hit;
  }
  String toString() {    
    return "Origin: " + origin.toString() + " radius: " + radius;
  }
}

//---------------End Sphere---------------

//---------------Moving Sphere---------------
class MovingSphere extends Scene {
  public float radius;
  public Vec origin1;
  Vec nuOrigin;
  MovingSphere(Vec origin) {
    super(origin, "sphere");
  }
  MovingSphere(float radius, Vec origin) {
    super(origin, "sphere"); 
    this.radius = radius;
  }
  MovingSphere(float radius, Vec origin, Vec origin1, Vec diffuseColor, Vec diffuseAmbient) { 
    super(origin, "sphere"); 
    this.radius = radius;
    this.origin1 = origin1;
    this.diffuseColor = diffuseColor; 
    this.diffuseAmbient = diffuseAmbient;
  } 

  void intersectionMethod(Ray ray) {
    float T = random(1.0);
    nuOrigin = travelV(origin, subV(origin1, origin), T);
    Vec SO = subV(nuOrigin, ray.origin);
    float a = dotV(ray.direction);
    float b = 2 * dotV(SO, ray.direction);
    float c = dotV(SO) - sq(radius);
    float bac = sq(b) - (4*a*c);
    if (bac>0.0) {
      float d1 = (-b - sqrt(bac))/ (2*a);
      float d2 = (-b + sqrt(bac))/ (2*a);
      if (-d1 > 0.0 && d1>d2 && abs(d1) < abs(ray.minDistance)) {
        ray.minDistance = abs(d1);
        ray.sceneIndex = sceneObjects.indexOf(this);
        ray.hit = travelV(ray.origin, ray.direction, ray.minDistance); 
        ray.normal = normalizeV(subV(ray.hit, origin));
      } else if (-d2 > 0.0 && d2>d1 && abs(d2) < abs(ray.minDistance)) {
        ray.minDistance = abs(d2);
        ray.sceneIndex = sceneObjects.indexOf(this);
        ray.hit = travelV(ray.origin, ray.direction, ray.minDistance); 
        ray.normal = normalizeV(subV(ray.hit, origin));      
      }
    }
  }

  Vec lightObject(Ray ray) {
    Vec surfaceColor = V();
    //if(dotV(norHit, direction) > 0.0)norHit = scaleV(norHit, -1.0);
    for (int i =0; i< lights.size(); i++) {
      Vec lightDirection = lights.get(i).getDirection(ray.hit);
      Ray reverse = new Ray(ray.hit, scaleV(lightDirection, 1));
      for (int j =0; j<sceneObjects.size(); j++) {
        if (sceneObjects.get(j) != this)sceneObjects.get(j).intersectionMethod(reverse);
      }
      if (reverse.sceneIndex < 0) {
        float diffCoeff = dotV(lightDirection, ray.normal);
        surfaceColor = addV(surfaceColor, multV(scaleV(diffuseColor, max(0, diffCoeff)), lights.get(i).light_color) );
      }
    }
    return addV(diffuseAmbient, surfaceColor);
  }
  
}

//---------------End Moving Sphere---------------

//---------------Polygon---------------
class Polygon extends Scene {
  ArrayList<Vec> vertices =new  ArrayList<Vec>();
  Polygon() {
    super("polygon");
    box = makeBox();
  }
  Polygon(ArrayList<Vec> vertices) {
    super("polygon");
    this.vertices = vertices;
    box = makeBox();
  }
  Polygon(ArrayList<Vec> vertices, Vec diffuseColor, Vec diffuseAmbient) {
    super("polygon");
    this.vertices = vertices;
    this.diffuseColor = diffuseColor; 
    this.diffuseAmbient = diffuseAmbient;
    box = makeBox();
  }
  void addVertex(Vec vert){
    vertices.add(vert);
    box = makeBox();
  }
  Vec getNormal() {
    if (vertices.size() >=3) {
      Vec n = crossV(subV(vertices.get(1), vertices.get(0)), subV(vertices.get(2), vertices.get(0))).normalize();
      return n;
    }  
    return V();
  }

  Vec lightObject(Ray ray) {
    Vec surfaceColor = V();
    Vec hit = travelV(ray.origin, ray.direction, ray.minDistance);
    Vec n = crossV(subV(vertices.get(1), vertices.get(0)), subV(vertices.get(2), vertices.get(0))).normalize();
    for (int i =0; i< lights.size(); i++) {
      Vec lightDirection = lights.get(i).getDirection(hit);
      if (dotV(n, lightDirection) > 0.0)n = scaleV(n, -1.0);
      Ray reverse = new Ray(hit, scaleV(lightDirection, 1));
      
      outerloop:
      for (int j =0; j<sceneObjects.size(); j++) {
        if (sceneObjects.get(j) != this)sceneObjects.get(j).intersectionMethod(reverse);
        if(reverse.sceneIndex >-1){
            break outerloop;
        }
      }

      if (reverse.sceneIndex <0) {
        float diffCoeff = abs(dotV(lightDirection, n));
        surfaceColor = addV(surfaceColor, multV(scaleV(diffuseColor, max(0, diffCoeff)), lights.get(i).light_color) );
      }
    }
    return addV(diffuseAmbient, surfaceColor);
  }    

  String toString() { 
    String str = "";
    for (int i = 0; i< vertices.size(); i++) {
      str += vertices.get(i).toString() + "\n";
    } 
    return str;
  }
  Box makeBox(){
    float maxX = -10000, maxY = -10000, maxZ = -10000;
    float minX = 10000, minY = 10000, minZ = 10000;
    for(int i = 0; i< vertices.size(); i++){
      maxX = max(maxX, vertices.get(i).x);
      minX = min(minX, vertices.get(i).x);
      
      maxY = max(maxY, vertices.get(i).y);
      minY = min(minY, vertices.get(i).y);
      
      minZ = max(maxZ, vertices.get(i).z);
      maxZ = min(minZ, vertices.get(i).z);    
    }
    return new Box(V(minX, minY, minZ), V(maxX, maxY, maxZ));  
  }
  void intersectionMethod(Ray ray) {
    if (vertices.size() >=3) {

      Vec P0 = vertices.get(0);
      Vec P1 = vertices.get(1);
      Vec P2 = vertices.get(2);

      Vec P0P1 = subV(P1, P0);
      Vec P0P2 = subV(P2, P0);
      Vec N = crossV(P0P1, P0P2);

      float N_dot_Dir = dotV(ray.direction, N);

      float d = dotV(N, P0);
      float t = (dotV(ray.origin, N) + d)/N_dot_Dir;
      if (t<0) return;
      Vec hit = addV(ray.origin, scaleV(ray.direction, t));
      
      for(int j = 0; j<vertices.size(); j++){      
        Vec E0 = V(); Vec E1 = V();
        if(j==vertices.size() -1){
          E0 = vertices.get(j);
          E1 = vertices.get(0);        
        }
        else{
          E0 = vertices.get(j);
          E1 = vertices.get(j+1);    
        }
        Vec hitE0 = subV(hit, E0);
        Vec E0E1 = subV(E1, E0);
        Vec CrossE = crossV(E0E1, hitE0);
        if(dotV(N,CrossE) <0) return;      
      }
      if (abs(ray.minDistance) > abs(t)) {
        ray.minDistance = abs(t);
        ray.sceneIndex = sceneObjects.indexOf(this);
      }
    }
  }
}

//---------------End Polygon---------------

//---------------List---------------
class List extends Scene {
  ArrayList<Scene> sceneList = new ArrayList<Scene>();
  int hitIndex = -1;
  List(){super("list");}
  List(ArrayList<Scene> sceneList){super("list"); this.sceneList = sceneList;}
  void addObject(Scene object){
    sceneList.add(object);
  }
  ArrayList<Scene> getList(){
    return sceneList;
  }
  void intersectionMethod(Ray ray) {
    for(int i = 0; i<sceneList.size(); i++){
      Ray tempRay = new Ray(ray.origin, ray.direction);
      sceneList.get(i).getBox().intersectionMethod(tempRay);
      if(tempRay.minDistance < ray.minDistance){
        tempRay = new Ray(ray.origin, ray.direction);
        sceneList.get(i).intersectionMethod(tempRay);
        if(tempRay.minDistance < ray.minDistance){
          ray.sceneIndex = sceneObjects.indexOf(this);
          ray.minDistance = tempRay.minDistance;        
          ray.hit = travelV(ray.origin, ray.direction, ray.minDistance);
          ray.normal = tempRay.normal;
          hitIndex = i;
        }
      }
    }
  }
  Vec lightObject(Ray ray){
    return sceneList.get(hitIndex).lightObject(ray);  
  }


}
//---------------End List---------------