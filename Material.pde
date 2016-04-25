class Material {
  public Vec ambient = V();
  Material(Vec ambient) {
    this.ambient = ambient;
  }
  Vec getMaterial(Vec hit) {
    return ambient;
  }
}

class DiffuseMaterial extends Material {
  public Vec diffuseColor = V();
  DiffuseMaterial(Vec diffuse, Vec ambient) {  
    super(ambient); 
    this.diffuseColor = diffuse;
  }
  Vec getMaterial(Vec hit) {
    return diffuseColor;
  }
}

class NoiseMaterial extends Material {
  public float scale;

  NoiseMaterial(float scale) {  
    super(V()); 
    this.scale = scale;
  }
  Vec getMaterial(Vec hit) {
    float coeff = noise_3d(hit.x * scale, hit.y * scale, hit.z * scale);
    return V(1.0*coeff, 1.0*coeff, 1.0*coeff);
  }
}

class MarbleMaterial extends Material {
  public Vec period = V(-2, 1, 3.5);
  public Vec colour = V(1, 1, 1);
  MarbleMaterial() {  
    super(V());
  }
  Vec getMaterial(Vec hit) {
    return marble(hit);
  }      
  Vec marble(Vec hit) {  
    Vec scale = multV(hit, period);    
    float nos = scale.x + scale.y + scale.z + turbulence(scale, 20)* 24.5;
    nos = abs(sin(nos * PI));
    return scaleV(colour, nos);
  }

  Vec marble2(Vec hit, Vec lightIntense, float diffCoeff) {//tiedye effect; Marble Ball Marble

    Vec soapColor = V(.5, .7, .2);
    Vec waterColor = V(.2, 0, .9);
    float noise = 0;
    float x = 0.05 * hit.x;
    float y = 0.05 * hit.y;
    float z = 0.05 * hit.z;
    for (int i =1; i<5; i++) {
      noise +=  (1.0 / i)* abs(noise_3d((float)i* x, (float)i*y, (float)i*z));
    }
    waterColor = scaleV(waterColor, noise);
    soapColor = scaleV(soapColor, 1.0 - noise);
    return multV(scaleV(addV(waterColor, soapColor), diffCoeff), lightIntense);
  }
}

class WoodMaterial extends Material {
  public Vec woodColor = V(.8, .69, .5);
  public Vec ringColor = V(.55, .4, .3);
  public Vec period = V( -.5, 3, 2);
  WoodMaterial() {
    super(V());
  }
  Vec getMaterial(Vec hit) {       
    Vec scale = multV(hit, period);    
    float nos = scale.x + scale.y + scale.z + 1*turbulence(scale, 5);
    nos = abs(sin(nos * PI));
    nos = nos - int(nos);
    if (nos>1.0 -nos)return scaleV(woodColor, nos);
    return ringColor;
  }
}


float turbulence(Vec hit, int size) {
  float noise = 0;
  if (size<1) size = 1;
  for (int i =1; i<size; i++) {
    noise +=  (1.0 / i)* abs(noise_3d((float)i* hit.x, (float)i*hit.y, (float)i*hit.z));
  } 
  return noise/size;
}


class StoneMaterial extends Material {
  public int seed = 0;
  public Vec stoneColor = V(.7, .4, .4);
  float[] distances = new float[2];
  StoneMaterial(int seed) {
    super(V()); 
    this.seed = seed;
    randomSeed(seed);
  }
  Vec getMaterial(Vec hit) {
    return WorleyNoise(hit);
  }

  Vec WorleyNoise(Vec hit) {
    long previous, numberFeaturePoints;
    Vec tempDiff= V();
    Vec feature;
    for (int i = 0; i < distances.length; i++)distances[i] = 10000;
    int cubex = floor(hit.x);
    int cubey = floor(hit.y);
    int cubez = floor(hit.z);

    for (int i = -1; i < 2; ++i) {
      for (int j = -1; j < 2; ++j) {
        for (int k = -1; k < 2; ++k)
        {
          int tempCubex = cubex + i;
          int tempCubey = cubey + j;
          int tempCubez = cubez + k;
          previous = lcgRandom(FNVHash((tempCubex + seed), (tempCubey), (tempCubez)));
          randomSeed(previous);
          numberFeaturePoints = (int)random(9);
          for (int l = 0; l < (int)numberFeaturePoints; ++l)
          {
            previous = lcgRandom(previous);
            tempDiff.x = (float)previous / pow(2, 32);
            previous = lcgRandom(previous);
            tempDiff.y = (float)previous / pow(2, 32);
            previous = lcgRandom(previous);
            tempDiff.z = (float)previous / pow(2, 32);
            feature =  V(tempDiff.x + (float)tempCubex, tempDiff.y + (float)tempCubey, tempDiff.z + (float)tempCubez);
            sortDistance(distances, distV(hit, feature));
          }
        }
      }
    }
    float d = distances[1] - distances[0];
    if (d < .1) return V(1, 1, 1);
    return stoneColor;
  }
  //FNV hash algorithm from isthe.com
  long OFFSET_BASIS = 2166136261l;
  long FNV_PRIME = 16777619;
  long FNVHash(int i, int j, int k)
  { 
    long hash = OFFSET_BASIS;
    hash = hash ^ (int)i;
    hash *= FNV_PRIME;
    hash = hash ^ (int)j;
    hash *= FNV_PRIME;
    hash = hash ^ (int)k;
    hash *= FNV_PRIME;
    return hash;
  }

  void sortDistance(float[] distances, float x)
  {
    float temp;
    for (int i = distances.length - 1; i >= 0; i--)
    {
      if (x > distances[i]) break;
      temp = distances[i];
      distances[i] = x;
      if (i + 1 < distances.length) distances[i + 1] = temp;
    }
  }
  long lcgRandom(long lastValue)
  {
    return ((22695477 * lastValue + 1) % (long)pow(2, 32));
  }
}