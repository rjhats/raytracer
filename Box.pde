class Box extends Scene {
  Vec minCoords;
  Vec maxCoords;
  //public Vec diffuseColor = V(random(1.0),random(1.0),random(1.0));
  public Vec diffuseColor = V(.8, .4, .2);
  public Vec diffuseAmbient = V(diffuseColor.x/4.0, diffuseColor.y/4.0, diffuseColor.z/4.0);
  Box(){super(V(), "box");
    minCoords = V(100000, 100000, 100000);
    maxCoords = V(-100000, -100000, -100000); 
  }
  Box(Vec minCoords, Vec maxCoords) {
    super(V(), "box");    
    //this.minCoords = minCoords; 
    //this.maxCoords = maxCoords;
    Vec[] c = rearrange(minCoords, maxCoords);
    this.minCoords = c[0]; 
    this.maxCoords = c[1];
    center = scaleV(addV(minCoords, maxCoords), .5);    
  }
  private Vec[] rearrange(Vec mins, Vec maxs){
    Vec tempV = V(mins);
    mins = min(tempV, maxs);
    maxs = max(tempV, maxs);  
    
    Vec[] newVecs = new Vec[2];
    newVecs[0] = mins;
    newVecs[1] = maxs;
    return newVecs;  
  }
  Box(Vec minCoords, Vec maxCoords, Vec diffuseColor, Vec diffuseAmbient) {
    super(V(), "box"); 
    this.minCoords = minCoords; 
    this.maxCoords = maxCoords;
    this.diffuseColor = diffuseColor;
    this.diffuseAmbient = diffuseAmbient;
    center = scaleV(addV(minCoords, maxCoords), .5);
  }
  public Box getBox() {
    return this;
  }
  public Box expandBox(Box boxxy){
    Vec mins = min(minCoords, boxxy.minCoords);
    Vec maxs = max(maxCoords, boxxy.maxCoords); 
    
    return new Box(mins, maxs);
  }
  void intersectionMethod(Ray ray) {
    float txMin = (minCoords.x - ray.origin.x)/ray.direction.x;
    float txMax = (maxCoords.x - ray.origin.x)/ray.direction.x;    
    if (txMin > txMax) {
      float temp = txMax;
      txMax = txMin;
      txMin = temp;
    }
    float tyMin = (minCoords.y - ray.origin.y)/ray.direction.y;
    float tyMax = (maxCoords.y - ray.origin.y)/ray.direction.y;

    if (tyMin > tyMax) {
      float temp = tyMax;
      tyMax = tyMin;
      tyMin = temp;
    }
    float tzMin = (minCoords.z - ray.origin.z)/ray.direction.z;
    float tzMax = (maxCoords.z - ray.origin.z)/ray.direction.z;

    if (tzMin > tzMax) {
      float temp = tzMax;
      tzMax = tzMin;
      tzMin = temp;
    }

    if (txMin > tyMax || tyMin > txMax) return;
    if (tyMin > txMin) txMin = tyMin;
    if (tyMax < txMax) txMax = tyMax;

    if (txMin > tzMax || tzMin > txMax) return;
    if (tzMin > txMin) txMin = tzMin;
    if (tzMax < txMax) txMax = tzMax; 

    if (txMin < ray.minDistance || txMin < ray.minDistance) {
      if (txMin>0 && txMax > 0) {
        ray.minDistance = min(txMin, txMax);
      } else if (txMin>0 && txMax < 0) {
        ray.minDistance = txMin;
      } else if (txMin<0 && txMax > 0) {
        ray.minDistance = txMax;
      }
      ray.sceneIndex = sceneObjects.indexOf(this);
      ray.hit = travelV(ray.origin, ray.direction, ray.minDistance);
      ray.normal = getNormal(ray.hit);
    }
  }

  Vec lightObject(Ray ray) {
    Vec surfaceColor = V();
    for (int i =0; i< lights.size(); i++) {
      Vec lightDirection = lights.get(i).getDirection(ray.hit);
      if (dotV(ray.normal, lightDirection) > 0.0)ray.normal = scaleV(ray.normal, -1.0);
      Ray reverse = new Ray(ray.hit, scaleV(lightDirection, 1));      
      for (int j =0; j<sceneObjects.size(); j++) {
        if (sceneObjects.get(j) != this)sceneObjects.get(j).intersectionMethod(reverse);
      }      
      if (reverse.sceneIndex <0) {
        float diffCoeff = abs(dotV(lightDirection, ray.normal));
        surfaceColor = addV(surfaceColor, multV(scaleV(diffuseColor, max(0, diffCoeff)), lights.get(i).light_color) );
      }
    }
    return addV(diffuseAmbient, surfaceColor);
  }
  Vec getNormal() {
    Vec c1 = subV(V(minCoords.x, maxCoords.y, minCoords.z), minCoords);
    Vec c2 = subV(V(maxCoords.x, minCoords.y, minCoords.z), minCoords);
    return crossV(c2, c1).normalize();
  }
  Vec getNormal(Vec hit) {
    float[] nums = new float[6];  
    nums[0] = abs(minCoords.x - hit.x);
    nums[1] = abs(maxCoords.x - hit.x);
    nums[2] = abs(minCoords.y - hit.y);
    nums[3] = abs(maxCoords.y - hit.y);
    nums[4] = abs(minCoords.z - hit.z);
    nums[5] = abs(maxCoords.z - hit.z);
    float lowest = min(nums[0], min(nums[1], min(nums[2], min(nums[3], min(nums[4], nums[5])))));
    int location = -1;
    for (int i = 0; i<nums.length; i++) {
      if (abs(nums[i] - lowest) < .000005) location = i;
    }
    if (location == 0) {
      Vec c1 = subV(V(minCoords.x, maxCoords.y, minCoords.z), minCoords);
      Vec c2 = subV(V(minCoords.x, minCoords.y, maxCoords.z), minCoords);
      return crossV(c2, c1).normalize();
    } else if (location == 1) {
      Vec c1 = subV(V(maxCoords.x, maxCoords.y, minCoords.z), maxCoords);
      Vec c2 = subV(V(maxCoords.x, minCoords.y, maxCoords.z), maxCoords);
      return crossV(c2, c1).normalize();
    } else if (location == 2) {
      Vec c1 = subV(V(maxCoords.x, minCoords.y, minCoords.z), minCoords);
      Vec c2 = subV(V(minCoords.x, minCoords.y, maxCoords.z), minCoords);
      return crossV(c2, c1).normalize();
    } else if (location == 3) {
      Vec c1 = subV(V(maxCoords.x, maxCoords.y, minCoords.z), maxCoords);
      Vec c2 = subV(V(minCoords.x, maxCoords.y, maxCoords.z), maxCoords);
      return crossV(c2, c1).normalize();
    } else if (location == 4) {
      Vec c1 = subV(V(minCoords.x, maxCoords.y, minCoords.z), minCoords);
      Vec c2 = subV(V(maxCoords.x, minCoords.y, minCoords.z), minCoords);
      return crossV(c2, c1).normalize();
    } else {
      Vec c1 = subV(V(minCoords.x, maxCoords.y, maxCoords.z), maxCoords);
      Vec c2 = subV(V(maxCoords.x, minCoords.y, maxCoords.z), maxCoords);
      return crossV(c2, c1).normalize();
    }
  }
  String toString() {
    return "Min: " + minCoords.toString() +" Max: " + maxCoords.toString();
  }
  
}

float[] returnSplit(Box box){
  float[] axisSplit = new float[2];
  float xDist, yDist, zDist;
  xDist = abs(box.maxCoords.x - box.minCoords.x);
  yDist = abs(box.maxCoords.y - box.minCoords.y);
  zDist = abs(box.maxCoords.z - box.minCoords.z);
  //Box tres, bien;
  if(xDist>yDist && xDist>zDist){
    axisSplit[0] = (box.maxCoords.x + box.minCoords.x)/2.0;
    axisSplit[1] = 0;
    //println("x");
  }
  else if(yDist>xDist && yDist>zDist){
    axisSplit[0] = (box.maxCoords.y + box.minCoords.y)/2.0;
    axisSplit[1] = 1;
    //println("y");
  }
  else{
    axisSplit[0] = (box.maxCoords.z + box.minCoords.z)/2.0;
    axisSplit[1] = 2;
    //println("z");
  }
  return axisSplit;
}