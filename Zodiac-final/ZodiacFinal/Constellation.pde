  
class Constellation {
 
  public Constellation(String name, Star[] stars, HashMap<String, ArrayList<String>> map, PShape image) {
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
  
  PShape image;
  boolean showImage = false;
  float cWidth;
  float cHeight;
  
  float imgPosX;
  float imgPosY;
  
  // model image positions
  float mImgPosX;
  float mImgPosY;
  
  
}