
class Constellation {
 
  public Constellation(String name, Star[] stars, HashMap<String, ArrayList<String>> map, PImage image) {
    this.name = name;
    this.stars = stars;
    this.map = map;
    this.image = image;
  }
  
  String name;  
  Star[] stars;  
  HashMap<String, ArrayList<String>> map;
  boolean complete = false;
  boolean melodyPlayed = false;    
  ArrayList<Star> connectionOrder = new ArrayList<Star>();
  
  PImage image;
  boolean showImage = false;
  int cWidth;
  int cHeight;
  
  int imgPosX;
  int imgPosY;
  
  // model image positions
  float mImgPosX;
  float mImgPosY;
  
  
}