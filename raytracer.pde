///////////////////////////////////////////////////////////////////////
//
//  Ray Tracing Shell
//
///////////////////////////////////////////////////////////////////////

float fov = 0.0;
boolean usingLens = false;
float numRays = 1.0;
float lensRadius;
float focalDistance;
float aspectratio = float(width) / float(height);
ArrayList<Scene> sceneObjects = new ArrayList<Scene>();
ArrayList<namedScene> namedObjects = new ArrayList<namedScene>();
ArrayList<Light> lights = new ArrayList<Light>();
ArrayList<Transform> matrices = new ArrayList<Transform>();
int currentTransform = 0;
Vec eye = V(0, 0, 0);
Vec diffuseColor = V(0, 0, 0), diffuseAmbient = V(0, 0, 0), background = V(0, 0, 0);
// global matrix values
PMatrix3D global_mat;
float[] gmat = new float[16];  // global matrix values
ArrayList<ArrayList<Scene>> shuu = new ArrayList<ArrayList<Scene>>();
int timer = 0;
// Some initializations for the scene.

void setup() {
  size (300, 300, P3D);  // use P3D environment so that matrix commands work properly
  noStroke();
  colorMode (RGB, 1.0);
  background (0, 0, 0);
  // grab the global matrix values (to use later when drawing pixels)
  PMatrix3D global_mat = (PMatrix3D) getMatrix();
  global_mat.get(gmat);  
  //printMatrix();
  //resetMatrix();    // you may want to reset the matrix here
  //interpreter("rect_test.cli");
  restartTracing();
  interpreter("t01.cli");
}

// Press key 1 to 9 and 0 to run different test cases.

void keyPressed() {
  switch(key) {
  case '1':  
    println("starting 1");
    restartTracing();
    interpreter("t01.cli");
    println("finished 1\n");
    break;
  case '2':  
    println("starting 2");
    restartTracing();
    interpreter("t02.cli"); 
    println("finished 2\n");
    break;
  case '3':  
    println("starting 3");
    restartTracing();
    interpreter("t03.cli"); 
    println("finished 3\n");
    break;
  case '4':  
    println("starting 4");
    restartTracing();
    interpreter("t04.cli"); 
    println("finished 4\n");
    break;
  case '5':  
    println("starting 5");
    restartTracing();
    interpreter("t05.cli");
    println("finished 5\n");
    break;
  case '6': 
    println("starting 6");
    restartTracing();
    interpreter("t06.cli");
    println("finished 6\n");
    break;
  case '7':  
    println("starting 7");
    restartTracing();
    interpreter("t07.cli");
    println("finished 7\n");
    break;
  case '8':  
    println("starting 8");
    restartTracing();
    interpreter("t08.cli"); 
    println("finished 8\n");
    break;
  case '9':  
    println("starting 9");
    restartTracing();
    interpreter("t09.cli"); 
    println("finished 9\n");
    break;
  case '0':
    println("starting 10");
    restartTracing();
    interpreter("t10.cli"); 
    println("finished 10\n");
    break;
  case 'q':  
    exit(); 
    break;
  }
}

//  Parser core. It parses the CLI file and processes it based on each 
//  token. Only "color", "rect", and "write" tokens are implemented. 
//  You should start from here and add more functionalities for your
//  ray tracer.
//
//  Note: Function "splitToken()" is only available in processing 1.25 or higher.

void interpreter(String filename) {
  //showGrid();ansform
  String str[] = loadStrings(filename);
  if (str == null) println("Error! Failed to read the file.");
  for (int i=0; i<str.length; i++) {

    String[] token = splitTokens(str[i], " "); // Get a line and parse tokens.
    if (token.length == 0) continue; // Skip blank line.

    if (token[0].equals("fov")) {
      fov = float(token[1]);
    } else if (token[0].equals("rays_per_pixel")) {
      numRays=  float(token[1]);
    } else if (token[0].equals("lens")) {
      usingLens=true;
      lensRadius = float(token[1]);
      focalDistance = float(token[2]);
    } else if (token[0].equals("background")) {
      background=  V(float(token[1]), float(token[2]), float(token[3]));
    } else if (token[0].equals("named_object")) {
      namedScene named = new namedScene(token[1], shuu.get(shuu.size()-1).get(shuu.get(shuu.size()-1).size() -1));
      shuu.get(shuu.size()-1).remove(shuu.get(shuu.size()-1).size() -1);
      namedObjects.add(named);
    } else if (token[0].equals("point_light")) {
      Vec origin = V(float(token[1]), float(token[2]), float(token[3]));
      Vec light_color = V(float(token[4]), float(token[5]), float(token[6]));  
      lights.add(new PLight(origin, light_color));
    } else if (token[0].equals("disk_light")) {
      Vec origin = V(float(token[1]), float(token[2]), float(token[3]));
      float radius = float(token[4]);
      Vec normal = V(float(token[5]), float(token[6]), float(token[7]));
      Vec light_color = V(float(token[8]), float(token[9]), float(token[10]));  
      lights.add(new diskLight(origin, radius, normal, light_color));
    } else if (token[0].equals("diffuse")) {
      // TODO
      diffuseColor=  V(float(token[1]), float(token[2]), float(token[3]));
      diffuseAmbient=  V(float(token[4]), float(token[5]), float(token[6]));
    } else if (token[0].equals("instance") || 
      token[0].equals("box") ||
      token[0].equals("moving_sphere") ||
      token[0].equals("sphere") ||
      token[0].equals("begin")) {
      i = loadObject( str, i);
    } else if (token[0].equals("begin_list")) {      

      shuu.add(new ArrayList<Scene>());
    } else if (token[0].equals("end_list")) {
      List list = new List(shuu.get(shuu.size()-1));      
      shuu.remove(shuu.size()-1);
      shuu.get(shuu.size()-1).add(list);
      println("added list" + sceneObjects.size());
    } else if (token[0].equals("end_accel")) {
      BVHList list = new BVHList(shuu.get(shuu.size()-1));      
      shuu.remove(shuu.size()-1);
      shuu.get(shuu.size()-1).add(list);
      //println("added BVHList" + sceneObjects.size());
    } else if (token[0].equals("read")) {  // reads input from another file
      interpreter (token[1]);
    } else if (token[0].equals("color")) {  // example command -- not part of ray tracer
      float r = float(token[1]);
      float g = float(token[2]);
      float b = float(token[3]);
      fill(r, g, b);
    } else if (token[0].equals("rect")) {  // example command -- not part of ray tracer
      float x0 = float(token[1]);
      float y0 = float(token[2]);
      float x1 = float(token[3]);
      float y1 = float(token[4]);
      rect(x0, height-y1, x1-x0, y1-y0);
    } else if (token[0].equals("translate")) {
      matrices.get(currentTransform).translate(V(float(token[1]), float(token[2]), float(token[3])));
    } else if (token[0].equals("scale")) {
      matrices.get(currentTransform).scale(V(float(token[1]), float(token[2]), float(token[3])));
    } else if (token[0].equals("rotate")) {
      matrices.get(currentTransform).rotate(float(token[1]), V(float(token[2]), float(token[3]), float(token[4])));
    } else if (token[0].equals("push")) {
      matrices.add(matrices.get(currentTransform).copy());
      currentTransform++;
    } else if (token[0].equals("pop")) {
      // save the current image to a .png file
      matrices.remove(currentTransform);
      currentTransform-=1;
    } else if (token[0].equals("reset_timer")) {
      timer = millis();
    } else if (token[0].equals("print_timer")) {
      int new_timer = millis();
      int diff = new_timer - timer;
      float seconds = diff / 1000.0;
      println ("timer = " + seconds);
    } else if (token[0].equals("write")) {
      // save the current image to a .png file
      //println(sceneObjects.size());
      colorImage(background);
      save(token[1]);
    }
  }
}

//  Draw frames.  Should be left empty.
void draw() {
}

// when mouse is pressed, print the cursor location
void mousePressed() {
  println ("mouse: " + mouseX + " " + mouseY);
}

float rayIntersection(Ray ray) {
  for (int i =0; i<sceneObjects.size(); i++) {
    sceneObjects.get(i).intersectionMethod(ray);
  }
  return ray.minDistance;
}

Vec computePixel(Vec background, Ray ray) {
  rayIntersection(ray);
  if (ray.sceneIndex >-1) {
    return ray.getScene().lightObject(ray);
  }
  return background;
}
void colorImage(Vec background) {
  loadPixels();
  ///debug
  float tor = millis();
  float curo = .1;
  float telo = (width*height* curo);
  //debug
  float angle = tan(PI * 0.5 * fov / 180.0);
  if (numRays < 1) numRays = 1;
  for (int i = 0; i < width*height; i++) {
    int x = i%width;
    int y = i/width;
    Vec coloration = V();
    for (int s = 0; s <numRays; s++) {                
      float shiftTerm = (s)/((float)numRays);
      float xPrime = (2 * ((x +shiftTerm)/width) - 1) * angle * aspectratio;
      float yPrime = (1 - 2 * ((y +shiftTerm)/height)) * angle; 
      Vec direction = V(xPrime, yPrime, -1.0).normalize();
      Ray ray = new Ray(eye, direction);
      if (usingLens) {
        float t = (-focalDistance - eye.z)/direction.z;
        Vec focalPoint = travelV(eye, direction, t);          
        float AppUy = random(lensRadius);
        float theta = random(2* PI);
        Vec nuEye = addV(eye, V(AppUy * cos(theta), AppUy * sin(theta), 0));
        Vec nu_dir = subV(focalPoint, nuEye).normalize();
        ray = new Ray(scaleV(nuEye, 1), nu_dir);
        /*
          if(x==50){
         float t1 = (-focalDistance - nuEye.z)/nu_dir.z;
         Vec QPrime = travelV(nuEye, nu_dir, -t1);
         float hit2 = rayIntersection(new Ray(eye, direction));
         float hit1 = rayIntersection(ray);
         println("focalPoint1 = " + t+" " + focalPoint.toString() + " || 2 = "+ t1+" " + QPrime.toString());
         println(hit1 + " || " + hit2);
         }
         */
      }

      coloration = addV(coloration, computePixel(background, ray));
    }
    pixels[i] = colorV(scaleV(coloration, 1.0/(numRays)));
    //debug
    /*
    if(i >= telo){
     float tema = millis();
     println("Currently at " + i/(1.0* width*height)*100.0 + "% Time passed "+ (tema-tor)/1000.0 + " seconds");
     curo +=.1;      
     telo = (width*height* curo);
     }
     //debug*/
  }
  updatePixels();
}

void restartTracing() {
  clear();
  matrices.clear();
  namedObjects.clear();
  sceneObjects.clear();
  shuu.clear();
  shuu.add(sceneObjects);
  lights.clear();
  matrices.add(new Transform());
  currentTransform =0;
  diffuseColor = V(0, 0, 0); 
  diffuseAmbient = V(0, 0, 0); 
  background = V(0, 0, 0);
  timer = 0;
  usingLens = false;
}

int loadObject(String[] str, int i ) {
  String[] token = splitTokens(str[i], " "); // Get a line and parse tokens.
  if (token[0].equals("instance")) {
    namedScene named = new namedScene(token[1], new Sphere());
    int scenePosition = namedObjects.indexOf(named);
    if (scenePosition >= 0) {
      Instance instance = new Instance(matrices.get(currentTransform), scenePosition);
      shuu.get(shuu.size()-1).add(instance);
    } else println("Object not found");
  } else if (token[0].equals("sphere")) {
    // TODO
    Sphere object = new Sphere(float(token[1]), matrices.get(currentTransform).transform(V(float(token[2]), float(token[3]), float(token[4]))), diffuseColor, diffuseAmbient);
    shuu.get(shuu.size()-1).add(object);
  } else if (token[0].equals("moving_sphere")) {
    // TODO
    Vec O1 = matrices.get(currentTransform).transform(V(float(token[2]), float(token[3]), float(token[4])));
    Vec O2 = matrices.get(currentTransform).transform(V(float(token[5]), float(token[6]), float(token[7])));
    MovingSphere object = new MovingSphere(float(token[1]), O1, O2, diffuseColor, diffuseAmbient);
    shuu.get(shuu.size()-1).add(object);
  } else if (token[0].equals("box")) {
    // TODO
    Vec min = matrices.get(currentTransform).transform(V(float(token[1]), float(token[2]), float(token[3])));
    Vec max = matrices.get(currentTransform).transform(V(float(token[4]), float(token[5]), float(token[6])));
    Box object = new Box(min, max, diffuseColor, diffuseAmbient);
    shuu.get(shuu.size()-1).add(object);
  } else if (token[0].equals("begin")) {      
    ArrayList<Vec> vertices =new  ArrayList<Vec>();
    i++; 
    token = splitTokens(str[i], " "); // Get a line and parse tokens.
    while (token[0].equals("vertex")) {
      //println("adding " + (V(float(token[1]), float(token[2]), float(token[3]))).toString());
      vertices.add(matrices.get(currentTransform).transform(V(float(token[1]), float(token[2]), float(token[3]))));
      i++; 
      token = splitTokens(str[i], " ");
    }
    if (token[0].equals("end")) {
      Polygon polygon = new Polygon(vertices, diffuseColor, diffuseAmbient);
      shuu.get(shuu.size()-1).add(polygon);
      //println("ending "+ i + " " +sceneObjects.size() +"\n");
    }
  }    
  return i;
}