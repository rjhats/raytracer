class Box extends Scene{
  Vec minCoords;
  Vec maxCoords;
  Box(Vec minCoords, Vec maxCoords){super(V(), "box"); this.minCoords = minCoords; this.maxCoords = maxCoords;}
  Box(Vec minCoords, Vec maxCoords, Vec diffuseColor, Vec diffuseAmbient){
    super(V(), "box"); 
    this.minCoords = minCoords; 
    this.maxCoords = maxCoords;
    this.diffuseColor = diffuseColor;
    this.diffuseAmbient = diffuseAmbient;
    println(minCoords.toString() + "\n" + maxCoords.toString());
  }
  void intersectionMethod(Ray ray){
    float txMin = (minCoords.x - ray.origin.x)/ray.direction.x;
    float txMax = (maxCoords.x - ray.origin.x)/ray.direction.x;    
    if(txMin > txMax){
      float temp = txMax;
      txMax = txMin;
      txMin = temp;
    }
    float tyMin = (minCoords.y - ray.origin.y)/ray.direction.y;
    float tyMax = (maxCoords.y - ray.origin.y)/ray.direction.y;
    
    if(tyMin > tyMax){
      float temp = tyMax;
      tyMax = tyMin;
      tyMin = temp;
    }
    float tzMin = (minCoords.z - ray.origin.z)/ray.direction.z;
    float tzMax = (maxCoords.z - ray.origin.z)/ray.direction.z;
    
    if(tzMin > tzMax){
      float temp = tzMax;
      tzMax = tzMin;
      tzMin = temp;
    }
    
    if(txMin > tyMax || tyMin > txMax) return;
    if(tyMin > txMin) txMin = tyMin;
    if(tyMax < txMax) txMax = tyMax;
    
    if(txMin > tzMax || tzMin > txMax) return;
    if(tzMin > txMin) txMin = tzMin;
    if(tzMax < txMax) txMax = tzMax; 
    
    if(txMin < ray.minDistance || txMin < ray.minDistance){
      if(txMin>0 && txMax > 0){ray.minDistance = min(txMin, txMax);}
      else if(txMin>0 && txMax < 0){ray.minDistance = txMin;}
      else if(txMin<0 && txMax > 0){ray.minDistance = txMax;}
      ray.sceneIndex = sceneObjects.indexOf(this);
      ray.hit = travelV(ray.origin, ray.direction, ray.minDistance);
    }
  }
  
  Vec lightObject(Ray ray) {
    Vec surfaceColor = V();
    Vec n = getNormal();
      for (int i =0; i< lights.size(); i++) {
      Vec lightDirection = lights.get(i).getDirection(ray.hit);
      if (dotV(n, lightDirection) > 0.0)n = scaleV(n, -1.0);
      Ray reverse = new Ray(ray.hit, scaleV(lightDirection, 1));

      for (int j =0; j<sceneObjects.size(); j++) {
        if (sceneObjects.get(j) != this)sceneObjects.get(j).intersectionMethod(reverse);
      }

      if (reverse.sceneIndex <0) {
        float diffCoeff = abs(dotV(lightDirection, n));
        surfaceColor = addV(surfaceColor, multV(scaleV(diffuseColor, max(0, diffCoeff)), lights.get(i).light_color) );
      }
    }
    return addV(diffuseAmbient, surfaceColor);    
  }
  Vec getNormal(){
    Vec c1 = subV(V(minCoords.x,maxCoords.y,minCoords.z),minCoords);
    Vec c2 = subV(V(maxCoords.x,minCoords.y,minCoords.z),minCoords);
    return crossV(c2,c1).normalize();    
  }
}