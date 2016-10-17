class Star {
  
  Star(float x, float y, float z, float size, int sound, String id, String constellationName) {
    this.x = x;
    this.y = y;
    this.z = z;
    this.size = size;
    this.sound = sound;
    this.id = id;  
    this.constellationName = constellationName;
  }
  
 float x;
 float y;
 float z;
 
 // previous model coordinates
 float pX;
 float pY;
 float pZ;
 
 
 float size;
 int sound;
 String id;
 String constellationName;
 boolean chosen = false;
 boolean soundPlayed = false;
 color clr = color(255);
 ArrayList<String> connections = new ArrayList<String>();
 
}