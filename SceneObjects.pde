//---------------Instance---------------

class Instance extends Scene {
  int hitAmount =  0;
  public Transform transform = new Transform();
  public Transform tempTransform = new Transform();
  public Transform tempTransform2 = new Transform();
  public int scenePosition;
  Instance(Transform transform, int scenePosition) {
    super("instance"); 
    this.transform.matrix=transform.matrix; 
    this.scenePosition = scenePosition;
    makeInverse(); 
    box = namedObjects.get(scenePosition).scene.getBox(); 
    center = namedObjects.get(scenePosition).scene.getCenter();
  }
  void makeInverse() {
    tempTransform.matrix = inverse(transform.matrix);
    tempTransform2.matrix = adjoint(transform.matrix);
    //scene.origin = transform.transform(scene.origin);
  }
  void intersectionMethod(Ray ray) {
    Ray tempRay = new Ray(tempTransform.transform(ray.origin), tempTransform2.transform(ray.direction));
    //tempRay.origin = tempTransform.transform(tempRay.origin);
    //tempRay.direction = tempTransform.transform(tempRay.direction).normalize();
    //tempRay.direction = scaleV(freeTransform(adjoint(transform.matrix), (tempRay.direction)),1).normalize();
    //if(hitAmount <=100)println(tempRay.toString());
    //hitAmount++;
    namedObjects.get(scenePosition).scene.intersectionMethod(tempRay);
    if (tempRay.minDistance < ray.minDistance) {
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
  private Box makeBox() {
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
    center = origin;
  }
  Sphere(float radius, Vec origin) {
    super(origin, "sphere"); 
    this.radius = radius;
    box = makeBox();
    center = origin;
  }
  Sphere(float radius, Vec origin, Vec diffuseColor, Vec diffuseAmbient) { 
    super(origin, "sphere"); 
    this.radius = radius;
    this.diffuseColor = diffuseColor; 
    this.diffuseAmbient = diffuseAmbient;
    box = makeBox();
    center = origin;
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
        if (sceneObjects.get(j) != this) {
          sceneObjects.get(j).intersectionMethod(reverse);
        }
        //if(reverse.sceneIndex > -1) println("satisfy");
      }
      if (reverse.sceneIndex < 0) {
        Vec hit = scaleV(ray.hit,noiseScale);
        float diffCoeff = dotV(lightDirection, ray.normal);
        if(noise)surfaceColor = addV(surfaceColor, scaleV(lights.get(i).light_color, noise_3d(hit.x, hit.y, hit.z)) );
        else surfaceColor = addV(surfaceColor, multV(scaleV(diffuseColor, min(max(0, diffCoeff),1.0)), lights.get(i).light_color) );
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
    center = origin;
  }
  MovingSphere(float radius, Vec origin) {
    super(origin, "sphere"); 
    this.radius = radius;
    center = origin;
  }
  MovingSphere(float radius, Vec origin, Vec origin1, Vec diffuseColor, Vec diffuseAmbient) { 
    super(origin, "sphere"); 
    this.radius = radius;
    this.origin1 = origin1;
    this.diffuseColor = diffuseColor; 
    this.diffuseAmbient = diffuseAmbient;
    center = scaleV(addV(origin, origin1), .5);
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
    Vec c = V();
    for (int i = 0; i < vertices.size(); i++)
      c = addV(c, vertices.get(i));
    center = scaleV(c, 1.0/(vertices.size()));
  }
  Polygon(ArrayList<Vec> vertices, Vec diffuseColor, Vec diffuseAmbient) {
    super("polygon");
    this.vertices = vertices;
    this.diffuseColor = diffuseColor; 
    this.diffuseAmbient = diffuseAmbient;
    box = makeBox();
    Vec c = V();
    for (int i = 0; i < vertices.size(); i++)
      c = addV(c, vertices.get(i));
    center = scaleV(c, 1.0/(vertices.size()));
  }
  void addVertex(Vec vert) {
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
    for (int i =0; i< lights.size(); i++) {
      Vec lightDirection = lights.get(i).getDirection(ray.hit);
      if (dotV(ray.normal, lightDirection) > 0.0)ray.normal = scaleV(ray.normal, -1.0);
      Ray reverse = new Ray(ray.hit, lightDirection);

    outerloop:
      for (int j =0; j<sceneObjects.size(); j++) {
        if (sceneObjects.get(j) != this)sceneObjects.get(j).intersectionMethod(reverse);
        if (reverse.sceneIndex >-1) {
          break outerloop;
        }
      }

      if (reverse.sceneIndex <0) {
        float diffCoeff = abs(dotV(lightDirection, ray.normal));
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
  Box makeBox() {
    float maxX = -10000, maxY = -10000, maxZ = 10000;
    float minX = 10000, minY = 10000, minZ = -10000;
    for (int i = 0; i< vertices.size(); i++) {
      maxX = max(maxX, vertices.get(i).x);
      minX = min(minX, vertices.get(i).x);

      maxY = max(maxY, vertices.get(i).y);
      minY = min(minY, vertices.get(i).y);

      minZ = max(minZ, vertices.get(i).z);
      maxZ = min(maxZ, vertices.get(i).z);
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
      Vec pvec = crossV(ray.direction, P0P2);
      float det = dotV(P0P1, pvec);

      if (det>.000005) return;

      float invDet = 1.0/det;

      Vec tvec = subV(ray.origin, P0);
      float u = dotV(tvec, pvec) *invDet;
      if (u<0||u>1) return;

      Vec qvec = crossV(tvec, P0P1);
      float v= dotV(ray.direction, qvec) *invDet;
      if (v < 0||u+v >1) return;

      float t= dotV(P0P2, qvec) * invDet;

      if (t<ray.minDistance) {
        ray.minDistance = t;
        ray.sceneIndex = sceneObjects.indexOf(this);
        ray.hit = travelV(ray.origin, ray.direction, ray.minDistance); 
        ray.normal = getNormal();
      }
    }
  }
}

//---------------End Polygon---------------

//---------------List---------------
class List extends Scene {
  ArrayList<Scene> sceneList = new ArrayList<Scene>();
  int hitIndex = -1;
  List() {
    super("list");
  }
  List(ArrayList<Scene> sceneList) {
    super("list"); 
    this.sceneList = sceneList;
    box = makeBox();
  }
  void addObject(Scene object) {
    sceneList.add(object);
    box = makeBox();
    Vec c = V();
    for (int i = 0; i < sceneList.size(); i++)
      c = addV(c, sceneList.get(i).getCenter());
    center = scaleV(c, 1.0/(sceneList.size()));
  }
  ArrayList<Scene> getList() {
    return sceneList;
  }
  private Box makeBox() {
    Box bo = new Box();
    for (int i =0; i<sceneList.size(); i++) {
      bo = bo.expandBox(sceneList.get(i).getBox());
    }
    return bo;
  }
  void intersectionMethod(Ray ray) { 

    Ray tempRay = new Ray(ray.origin, ray.direction);
    box.intersectionMethod(tempRay);
    if (tempRay.minDistance < ray.minDistance) {
      for (int i = 0; i<sceneList.size(); i++) {
        tempRay = new Ray(ray.origin, ray.direction);
        sceneList.get(i).getBox().intersectionMethod(tempRay);
        if (tempRay.minDistance < ray.minDistance) {
          tempRay = new Ray(ray.origin, ray.direction);
          sceneList.get(i).intersectionMethod(tempRay);
          if (tempRay.minDistance < ray.minDistance) {
            ray.sceneIndex = sceneObjects.indexOf(this);
            ray.minDistance = tempRay.minDistance;        
            ray.hit = travelV(ray.origin, ray.direction, ray.minDistance);
            ray.normal = tempRay.normal;
            hitIndex = i;
          }
        }
      }
    }
  }
  Vec lightObject(Ray ray) {
    return sceneList.get(hitIndex).lightObject(ray);
  }
}
//---------------End List---------------


//NODE
class Node {


  int parentNode = -1;
  int nodeNum;
  Boolean leaf = false;
  ArrayList<Integer> objectLocations = new ArrayList<Integer>();
  ArrayList<Integer> children = new ArrayList<Integer>();
  Box box;




  Node() {
  }
  Node(int parentNode) {
    this.parentNode = parentNode;
  }
  void addChild(Node child) {
    children.add(child.nodeNum);
  }
  Box getBox() {
    return box;
  }
}






//End Node


//Accel Structure
class BVHList extends Scene {
  int maxObjects = 10;
  int hitIndex = -1;
  ArrayList<Scene> sceneList = new ArrayList<Scene>();
  ArrayList<Integer> nodeSet = new ArrayList<Integer>();
  ArrayList<Node> nodeList = new ArrayList<Node>();
  BVHList() {
    super("bvhlist");
  }
  BVHList(ArrayList<Scene> sceneList) {
    super("list"); 
    this.sceneList = sceneList;
    //maxObjects =  min((int)(sceneList.size()*.01), max(10, (int)(sceneList.size()*.001)));//10;
    buildTree();
    //println("There are "+ nodeList.size()+" nodes");
  }

  private Box makeBox(ArrayList<Integer> listOfScenes) {
    Box bo = new Box();
    for (int i =0; i<listOfScenes.size(); i++) {
      bo = bo.expandBox(sceneList.get(listOfScenes.get(i)).getBox());
    }
    return bo;
  }

  private void buildTree() {

    Node root = new Node(); // parent node
    ArrayList<Integer> objects = new ArrayList<Integer>();
    for (int i =0; i<sceneList.size(); i++) {
      objects.add(i);
    }
    root.objectLocations = objects;
    //println("\n//////////////Node size beforeRoot " + nodeList.size());
    root.nodeNum = nodeList.size();    
    box = makeBox(objects);
    root.box = box;
    nodeList.add(root);
    //println(nodeList.size()+" Node size after Root//////////////\n");
    buildNode(root);
    /*
    while(sceneList.size()>1){
     -get box
     split
     fill in objects
     note the parent
     repeat if not leaf
     }
     */
  }

  private void buildNode(Node parent) {
    //println("Currently, there are "+ nodeList.size()+" nodes");

    ArrayList<Integer> dadObjects = parent.objectLocations;
    float[] splitAxis = returnSplit(parent.box); 
    //println("My dad is " + parent.nodeNum + " and the split is at " + splitAxis[0]);
    boolean x = false, y = false;//, z = false;
    if ((int)splitAxis[1] == 0) x = true;
    else if ((int)splitAxis[1] == 1) y = true;
    //else z = true;

    Node leftNode = new Node(parent.nodeNum); // set parent
    ArrayList<Integer> leftObjects = new ArrayList<Integer>();    

    Node rightNode = new Node(parent.nodeNum); // set parent   
    ArrayList<Integer> rightObjects = new ArrayList<Integer>();

    for (int i = 0; i< dadObjects.size(); i++) {
      if (x) {
        if (sceneList.get(dadObjects.get(i)).getCenter().x < splitAxis[0]) leftObjects.add(dadObjects.get(i));
        else rightObjects.add(dadObjects.get(i));
      } else if (y) {
        if (sceneList.get(dadObjects.get(i)).getCenter().y < splitAxis[0]) leftObjects.add(dadObjects.get(i));
        else rightObjects.add(dadObjects.get(i));
      } else {
        if (sceneList.get(dadObjects.get(i)).getCenter().z < splitAxis[0]) leftObjects.add(dadObjects.get(i));
        else rightObjects.add(dadObjects.get(i));
      }
    }
    //println("Left: " +leftObjects.size() + " Right: " + rightObjects.size());
    if (leftObjects.size() > 0) {
      leftNode.objectLocations = leftObjects;
      leftNode.nodeNum = nodeList.size();
      leftNode.box= makeBox(leftObjects);
      //leftNode.leaf = true;
      if (leftObjects.size() <= maxObjects) {
        leftNode.leaf = true;
      }
      nodeList.add(leftNode);
      parent.addChild(leftNode);
      //println("left node "+ leftNode.nodeNum);
      if (!leftNode.leaf)buildNode(leftNode);
    }
    //else println("Nothing to the left");
    //println("Finished left node "+ leftNode.nodeNum);
    if (rightObjects.size() > 0) {
      rightNode.objectLocations = rightObjects;
      rightNode.nodeNum = nodeList.size();
      rightNode.box= makeBox(rightObjects);
      //rightNode.leaf = true;
      if (rightObjects.size() <= maxObjects) {
        rightNode.leaf = true;
      }
      nodeList.add(rightNode);
      parent.addChild(rightNode);
      //println("right node "+ rightNode.nodeNum);
      if (!rightNode.leaf)buildNode(rightNode);
    }
    //else println("Nothing to the right");
    //println("Finished right node "+ rightNode.nodeNum);
  }
  void traverseIntersection(Ray ray, Node parent) {
    Ray tempRay=new Ray(ray.origin, ray.direction);
    for (int i = 0; i< parent.children.size(); i++) {
      Node child = nodeList.get(parent.children.get(i));
      child.getBox().intersectionMethod(tempRay);
      if (tempRay.minDistance < ray.minDistance) {
        if (child.leaf) {
          //println("down to node " + child.nodeNum);
          tempRay=new Ray(ray.origin, ray.direction);
          for (int k = 0; k< child.objectLocations.size(); k++) {
            sceneList.get(child.objectLocations.get(k)).intersectionMethod(tempRay);
            if (tempRay.minDistance < ray.minDistance) {
              ray.minDistance = tempRay.minDistance;
              ray.hit = travelV(ray.origin, ray.direction, ray.minDistance);
              ray.normal = tempRay.normal;
              hitIndex = child.objectLocations.get(k);
            }
          }
        } else {
          tempRay=new Ray(ray.origin, ray.direction);
          traverseIntersection(tempRay, child);
          if (tempRay.minDistance < ray.minDistance) {
            ray.minDistance = tempRay.minDistance;
            ray.hit = travelV(ray.origin, ray.direction, ray.minDistance);
            ray.normal = tempRay.normal;
          }
        }
      }
    }
  }


  void intersectionMethod(Ray ray) { 
    nodeSet = new ArrayList<Integer>();
    Ray tempRay = new Ray(ray.origin, ray.direction);
    Node root = nodeList.get(0);
    root.getBox().intersectionMethod(tempRay);
    if (tempRay.minDistance < ray.minDistance) {
      tempRay = new Ray(ray.origin, ray.direction);
      traverseIntersection(tempRay, root);
      if (tempRay.minDistance < ray.minDistance) {
        //println("HitALeaf");
        ray.sceneIndex = sceneObjects.indexOf(this);
        ray.minDistance = tempRay.minDistance;        
        ray.hit = travelV(ray.origin, ray.direction, ray.minDistance);
        ray.normal = tempRay.normal;
      }
    }
  }

  Vec lightObject(Ray ray) {
    return sceneList.get(hitIndex).lightObject(ray);  
    //return sceneList.get(hitIndex).getBox().lightObject(ray);
    //return V();
  }
}