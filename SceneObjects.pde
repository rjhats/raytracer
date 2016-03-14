//---------------Instance---------------

class Instance extends Scene{
  int hitAmount =  0;
  public Transform transform = new Transform();
  public Transform tempTransform = new Transform();
  public Transform tempTransform2 = new Transform();
  public int scenePosition;
  Instance(Transform transform, int scenePosition){
    super(V(), "instance"); this.transform.matrix=transform.matrix; this.scenePosition = scenePosition;makeInverse();}
  void makeInverse(){
    tempTransform.matrix = transform.inverse(transform.matrix);
    tempTransform2.matrix = transform.adjoint(transform.matrix);
    //scene.origin = transform.transform(scene.origin);
    
  }
  void intersectionMethod(Ray ray){
    Ray tempRay = new Ray(ray.origin, ray.direction);
    tempRay.origin = tempTransform.transform(tempRay.origin);
    //tempRay.direction = tempTransform.transform(tempRay.direction);
    //tempRay.direction = freeTransform(transform.adjoint(transform.matrix), (tempRay.direction));
    //if(hitAmount <=100)println(tempRay.toString());
    //hitAmount++;
    namedObjects.get(scenePosition).scene.intersectionMethod(tempRay);
    if(tempRay.scene !=null && tempRay.minDistance < ray.minDistance) {      
      ray.scene = this;
      ray.minDistance = tempRay.minDistance;
      ray.hit = tempRay.hit;
      //ray.normal = tempTransform.transform(tempRay.direction);//freeTransform(transform.adjoint(transform.matrix), (tempRay.normal));
      //ray.normal = tempTransform2.transform(tempRay.normal);
      ray.normal = tempRay.normal;
    
    
    } 
  }
  
  Vec lightObject(Ray ray) {
    //hitAmount++;
    //println(ray.hit.toString() + " _ _ _ _ "+ hitAmount);
    //return V(1,1,1);
    //ray.origin = tempTransform.transform(ray.origin);
    //ray.origin = tempTransform.transform(ray.origin);
    //ray.normal = tempTransform2.transform(scaleV(ray.normal, -1));
    //ray.direction = tempTransform.transform(ray.direction);
    return namedObjects.get(scenePosition).scene.lightObject(ray);    
  }
}

//---------------End Instance---------------

//---------------Sphere---------------


class Sphere extends Scene {
  public float radius;

  Sphere(Vec origin) {
    super(origin, "sphere");
  }
  Sphere(float radius, Vec origin) {
    super(origin, "sphere"); 
    this.radius = radius;
  }
  Sphere(float radius, Vec origin, Vec diffuseColor, Vec diffuseAmbient) { 
    super(origin, "sphere"); 
    this.radius = radius;
    this.diffuseColor = diffuseColor; 
    this.diffuseAmbient = diffuseAmbient;
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
        ray.scene = this;
        ray.hit = travelV(ray.origin, ray.direction, ray.minDistance); 
        ray.normal = normalV(subV(ray.hit, origin));
      } else if (-d2 > 0.0 && d2>d1 && abs(d2) < abs(ray.minDistance)) {
        ray.minDistance = abs(d2);
        ray.scene = this;
        ray.hit = travelV(ray.origin, ray.direction, ray.minDistance); 
        ray.normal = normalV(subV(ray.hit, origin));      
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
        if (reverse.scene !=null) {        
          /*
          if (reverse.scene.type.equals("polygon")) {
            Vec v0 = ((Polygon)reverse.scene).vertices.get(0);
            reverse.hit = travelV(reverse.origin, reverse.direction, -reverse.minDistance);
            Vec rN = ((Polygon)reverse.scene).getNormal();
            float Q = dotV(rN, subV(v0, reverse.hit));
            if (Q !=0) reverse.scene = null;
          }
          */
        }
      }
      if (reverse.scene ==null) {
        float diffCoeff = dotV(lightDirection, ray.normal);
        surfaceColor = addV(surfaceColor, multV(scaleV(diffuseColor, max(0, diffCoeff)), lights.get(i).light_color) );
      }
    }
    return addV(diffuseAmbient, surfaceColor);
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
  public float tempTime;
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
        ray.scene = this;
        ray.hit = travelV(ray.origin, ray.direction, ray.minDistance); 
        ray.normal = normalV(subV(ray.hit, origin));
      } else if (-d2 > 0.0 && d2>d1 && abs(d2) < abs(ray.minDistance)) {
        ray.minDistance = abs(d2);
        ray.scene = this;
        ray.hit = travelV(ray.origin, ray.direction, ray.minDistance); 
        ray.normal = normalV(subV(ray.hit, origin));      
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
        if (reverse.scene !=null) {   
          /*
          if (reverse.scene.type.equals("polygon")) {
            Vec v0 = ((Polygon)reverse.scene).vertices.get(0);
            hit = travelV(reverse.origin, reverse.direction, -reverse.minDistance);
            Vec rN = ((Polygon)reverse.scene).getNormal();
            float Q = dotV(rN, subV(v0, hit));
            if (Q !=0) reverse.scene = null;
          }
          */
        }
      }
      if (reverse.scene ==null) {
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
    super(V(), "polygon");
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

      for (int j =0; j<sceneObjects.size(); j++) {
        if (sceneObjects.get(j) != this)sceneObjects.get(j).intersectionMethod(reverse);
        if (reverse.scene !=null) {        
          if (reverse.scene.type.equals("polygon")) {
            Vec v0 = ((Polygon)reverse.scene).vertices.get(0);
            hit = travelV(reverse.origin, reverse.direction, -reverse.minDistance);
            Vec rN = ((Polygon)reverse.scene).getNormal();
            float Q = dotV(rN, subV(v0, hit));
            if (Q !=0) reverse.scene = null;
          }
        }
      }

      if (reverse.scene ==null) {
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
        ray.scene = this;
      }
    }
  }
}

//---------------End Polygon---------------