class Vec
{
  public float x, y, z;
  public Vec() { 
    this.x = 0; 
    this.y = 0; 
    this.z = 0;
  }
  public Vec(float x, float y, float z) { 
    this.x = x; 
    this.y = y; 
    this.z = z;
  }
  public Vec scale(float s) { 
    x*=s; 
    y*=s; 
    z*=s; 
    return this;
  }
  public Vec rotateX(float rad) { 
    float sy=y; 
    y=y*cos(rad)-z*sin(rad); 
    z=sy*sin(rad)+z*cos(rad); 
    return this;
  }  // Rotate around axis using right hand rule.
  public Vec rotateY(float rad) { 
    float sz=z; 
    z=z*cos(rad)-x*sin(rad); 
    x=sz*sin(rad)+x*cos(rad); 
    return this;
  }
  public Vec rotateZ(float rad) { 
    float sx=x; 
    x=x*cos(rad)-y*sin(rad); 
    y=sx*sin(rad)+y*cos(rad); 
    return this;
  }
  public Vec normalize() { 
    float mag = magnitude(); 
    if (mag!=0) { 
      x/=mag; 
      y/=mag; 
      z/=mag;
    } 
    return this;
  }
  public float magnitude() { 
    return sqrt(x*x + y*y + z*z);
  }
  public String toString() { 
    return x + ", "+y + ", "+z;
  }
}
Vec V() { 
  return new Vec(0, 0, 0);
};
Vec V(float x, float y, float z) { 
  return new Vec(x, y, z);
}
Vec normalV(Vec v) { 
  float mag = v.magnitude(); 
  if (mag!=0) { 
    return V(v.x/mag, v.y/mag, v.z/mag);
  } 
  return V();
}
Vec V(float x, float y) {
  return new Vec(x, y, 0);
}
Vec addV(Vec v1, Vec v2) { 
  return V(v1.x + v2.x, v1.y + v2.y, v1.z + v2.z);
}
Vec subV(Vec v1, Vec v2) { 
  return V(v1.x - v2.x, v1.y - v2.y, v1.z - v2.z);
}
Vec scaleV(Vec v, float s) {
  return V(v.x *s, v.y*s, v.z*s);
}
Vec travelV(Vec v0, Vec v1, float t) {
  return addV(v0, scaleV(v1, t));
}
Vec crossV(Vec v1, Vec v2) { 
  return V(v1.y*v2.z - v1.z*v2.y, v1.z*v2.x - v1.x*v2.z, v1.x*v2.y - v1.y*v2.x);
}
Vec multV(Vec v1, Vec v2) { 
  return V(v1.x*v2.x, v1.y*v2.y, v1.z*v2.z);
}
float dotV(Vec v1, Vec v2) { 
  return v1.x*v2.x + v1.y*v2.y + v1.z*v2.z;
}
float dotV(Vec v1) { 
  return v1.x*v1.x + v1.y*v1.y + v1.z*v1.z;
}
color colorV(Vec v1) {
  return color(v1.x, v1.y, v1.z);
}


class Transform {
  float[][] matrix = new float[4][4];
  Transform() { 
    identity(matrix);
  }
  Transform(float[][] matrix) {
    this.matrix = matrix;
  }
  void identity(float[][] mat4x4) {
    mat4x4[0][0] = 1.0;
    mat4x4[1][1] = 1.0;
    mat4x4[2][2] = 1.0;
    mat4x4[3][3] = 1.0;
  }
  String toString() {
    String out = "";
    for (int i=0; i<matrix.length; i++) {
      for (int j=0; j<matrix[i].length; j++) {
        out+= matrix[i][j] + " ";
      }
      out+="\n";
    }
    return out;
  }
  void translate(Vec v) {
    float[][] tempTranslate = new float[4][4];
    identity(tempTranslate);
    tempTranslate[0][3] = v.x;
    tempTranslate[1][3] = v.y;
    tempTranslate[2][3] = v.z;
    matrix = TMM(matrix, tempTranslate);
  }
  void scale(Vec v) {

    float[][] tempScale = new float[4][4];
    identity(tempScale);
    tempScale[0][0] *= v.x;
    tempScale[1][1] *= v.y;
    tempScale[2][2] *= v.z;    
    matrix = TMM(matrix, tempScale);
  }
  void rotate(float A, Vec v) {
    float[][] tempRotation = new float[4][4];
    identity(tempRotation);
    v.normalize();
    float a = (PI * A)/180.0;
    tempRotation[0][0] = (v.x*v.x)*(1-cos(a)) + cos(a);
    tempRotation[0][1]  = (v.x*v.y)*(1-cos(a)) - (v.z * sin(a));
    tempRotation[0][2] = (v.x*v.z)*(1-cos(a)) + (v.y * sin(a));

    tempRotation[1][0]  = (v.y*v.x)*(1-cos(a)) + (v.z * sin(a));
    tempRotation[1][1]  = (v.y*v.y)*(1-cos(a)) + cos(a);
    tempRotation[1][2]  = (v.y*v.z)*(1-cos(a)) - (v.x * sin(a));

    tempRotation[2][0] = (v.z*v.x)*(1-cos(a)) - (v.y * sin(a));
    tempRotation[2][1] = (v.z*v.y)*(1-cos(a)) + (v.x * sin(a));
    tempRotation[2][2] = (v.z*v.z)*(1-cos(a)) + cos(a);
    tempRotation[3][3] = 1;
    matrix = TMM(matrix, tempRotation);
  }
  Vec transform(Vec v) {

    float x = (matrix[0][0] * v.x) + (matrix[0][1] * v.y) + (matrix[0][2] * v.z) + (matrix[0][3] * 1);
    float y = (matrix[1][0] * v.x) + (matrix[1][1] * v.y) + (matrix[1][2] * v.z) + (matrix[1][3] * 1);
    float z = (matrix[2][0] * v.x) + (matrix[2][1] * v.y) + (matrix[2][2] * v.z) + (matrix[2][3] * 1);
    return V(x, y, z);
  }
  int sign(int num){
    if(num%2==0)return 1;
    return -1;
  }
  float[][] transpose(){
    if (matrix.length <=0)return null;
    int rows = matrix.length;
    int columns = matrix[0].length;
    float[][] tempMatrix = new float[rows][columns];
    for(int i =0; i<rows; i++){
      for(int j =0; j<columns; j++){
        tempMatrix[i][j] = matrix[j][i];      
      }   
    }
    return tempMatrix;
  }
  float determinant(float[][] matrix){
    float sum = 0;
    
    return sum;    
  }
  
  Transform copy() {
    return new Transform(matrix);
  }
}
Transform translate(Transform t, Vec v) {
  t.translate(v);
  return t;
}


float[][] TMM(float[][] matrixA, float[][] matrixB) {

  float[][] output = new float[4][4];
  if (matrixA.length != matrixB.length) {
    return null;
  }
  for (int i=0; i< matrixA.length; i++) {
    for (int j=0; j<matrixB.length; j++) {

      output[i][j] = matrixA[i][0]*matrixB[0][j] + matrixA[i][1]*matrixB[1][j] + matrixA[i][2]*matrixB[2][j] + matrixA[i][3]*matrixB[3][j];
    }
  }

  return output;
}
Transform copy(Transform t) {
  return new Transform();
}