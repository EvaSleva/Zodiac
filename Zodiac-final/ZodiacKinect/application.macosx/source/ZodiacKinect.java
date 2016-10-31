import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import oscP5.*; 
import netP5.*; 
import java.util.HashMap; 
import java.util.Iterator; 
import java.util.Map; 
import java.util.Map.Entry; 
import SimpleOpenNI.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class ZodiacKinect extends PApplet {









// Variables
OscP5 oscP5;
NetAddress myRemoteLocation;
NetAddress myRemoteLocationBackground;
PImage bgImage;

// Constants
int STAR_COUNT = 50;
int TOUCH_MARGIN = 50;
int TOUCH_MARGIN_Z = 300;
float MAX_STAR_SIZE = 9;
float MIN_STAR_SIZE = 6;
int CONSTELLATION_STAR_SIZE_MIN = 10;
int CONSTELLATION_STAR_SIZE_MAX = 15;
float SCREEN_MARGIN_X = width*0.1f;
float SCREEN_MARGIN_Y = height*0.1f;
int RANDOM_STAR_NOTE = -2;
boolean USE_CSV_POSITIONS = true;
float STAR_TOUCHED_SIZE = 0.3f;
int USER_SHIFT_X = -1500;
int USER_SHIFT_Y = -1500;
int CONSTELLATION_Z_AXIS_DEPTH = 800;
int USER_SCALE_FACTOR = 5;


Star previousStar;
float rotation = 0;
int constellationsShown = 0;
int noOfConstellationsOnScreen = 1;
final int WAIT_TIME = (int) (10 * 1000); // 10 seconds
int startTime;
boolean constellationsDone = false;

Star[] stars = new Star[STAR_COUNT];
HashMap<String, Constellation> constellations = new HashMap<String, Constellation>();
ArrayList<Line> lines = new ArrayList<Line>();
String constellationStarsCSV = "constellations-zodiac.csv";
String constellationCodesCSV = "constellation-codes-zodiac.csv";

SimpleOpenNI  context;
boolean       autoCalib=true;

// ----- Setup function -----

public void setup() {
  
  noStroke();
  background(0);
  bgImage = loadImage("green-bg.jpg");

  // intialize network variables
  oscP5 = new OscP5(this, 12345); // incoming on 12345
  myRemoteLocation = new NetAddress("127.0.0.1", 12346); // outgoing on 12346
  myRemoteLocationBackground = new NetAddress("127.0.0.1", 12347); // outgoing on 12346

  // Generate stars and play background sound
  GenerateStars();
  GenerateConstellations();
  PlayBackgroundMusic();

  // Kinect SimpleOpenNI
  context = new SimpleOpenNI(this);
  
  if (context.isInit() == false)
  {
    println("Can't init SimpleOpenNI, maybe the camera is not connected!"); 
    exit();
    return;
  }
  context.setMirror(true);

  // enable depthMap generation 
  context.enableDepth();

//  size(context.depthWidth(), context.depthHeight(), P3D);
  size(1920, 1080, P3D);

  // enable skeleton generation for all joints
  context.enableUser();
}



// -----  draw function -----

public void draw() {
  background(bgImage);
  lights();

  // camera rotation
  float orbitRadius= width;
  float xPos = cos(radians(rotation))*orbitRadius;
  float zPos = sin(radians(rotation))*orbitRadius;

  camera(xPos, height/2, zPos, 0, 0, 0, 0, 1, 0);
  
  // draw stars
  for (int i = 0; i < STAR_COUNT; i++) {
    ProcessStar(stars[i], false);
  } 

  // draw lines
  for (int i = 0; i < lines.size (); i++) {
    DrawLine(lines.get(i));
  }

  Iterator<Entry<String, Constellation>> iter = constellations.entrySet().iterator();
  for (int i = 0; i < constellationsShown; i++) {
    iter.next();
  }

  int conCounter = 0;

  // draw constellations
  while (iter.hasNext ())
  {
    if (conCounter < noOfConstellationsOnScreen) {
      Entry<String, Constellation> entry = iter.next();
      Constellation c = entry.getValue();

      // draw constellation
      for (int z = 0; z < entry.getValue ().stars.length; z++) {
        ProcessStar(c.stars[z], true);
      }

      if (c.showImage) {
        drawImage(c);
      }

      // check if constellation is complete
      if (c.complete && !c.melodyPlayed) {

        // play melody on separate thread
        PlayFinalMelody obj = new PlayFinalMelody(c);
        obj.start();
        c.melodyPlayed = true;
        drawImage(c);
        c.showImage = true;
        
        // Start timer
        constellationsDone = true;
        startTime = millis();
        
      }
      conCounter++;
    } else {
      iter.next();
    }
  }

  rotation += 0.1f;

  // Kinect SimpleOpenNI
  // update the cam
  context.update();
  // draw the skeleton if it's available
  if (context.isTrackingSkeleton(1)) {
    drawCurveFigure();
  }
  
  // Check if time is up, switch constellations
  if (constellationsDone) {
    if(hasFinished()) {
      nextConstellations();
      constellationsDone = false;
    }
  }
}

public boolean hasFinished() {
  return millis() - startTime > WAIT_TIME;
}

// Enter for changing constellation, 's' for completing constellation
public void keyPressed() {

  if (key == ENTER) {
    nextConstellations();
  }

  if (key == 's') {
    solveConstellations();
  }
}
  
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
  float imgPosZ;
  
  // model image positions
  float mImgPosX;
  float mImgPosY;
  float mImgPosZ;
  
}
public void drawCurveFigure() {

  pushMatrix();
  pushStyle();
  stroke(254, 201, 200);
  strokeWeight(3);
  fill(255, 20, 20);
  drawCircle(getJointPosition(SimpleOpenNI.SKEL_LEFT_HAND));
  drawCircle(getJointPosition(SimpleOpenNI.SKEL_RIGHT_HAND));
  noFill();

  beginShape();
  plotCurveVertexAtJointPosition(SimpleOpenNI.SKEL_HEAD);
  plotCurveVertexAtJointPosition(SimpleOpenNI.SKEL_HEAD);
  plotCurveVertexAtJointPosition(SimpleOpenNI.SKEL_NECK);
  plotCurveVertexAtJointPosition(SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  plotCurveVertexAtJointPosition(SimpleOpenNI.SKEL_RIGHT_ELBOW);
  plotCurveVertexAtJointPosition(SimpleOpenNI.SKEL_RIGHT_HAND);
  plotCurveVertexAtJointPosition(SimpleOpenNI.SKEL_RIGHT_HAND);
  endShape();

  beginShape();
  plotCurveVertexAtJointPosition(SimpleOpenNI.SKEL_HEAD);
  plotCurveVertexAtJointPosition(SimpleOpenNI.SKEL_HEAD);
  plotCurveVertexAtJointPosition(SimpleOpenNI.SKEL_NECK);
  plotCurveVertexAtJointPosition(SimpleOpenNI.SKEL_LEFT_SHOULDER);
  plotCurveVertexAtJointPosition(SimpleOpenNI.SKEL_LEFT_ELBOW);
  plotCurveVertexAtJointPosition(SimpleOpenNI.SKEL_LEFT_HAND);
  plotCurveVertexAtJointPosition(SimpleOpenNI.SKEL_LEFT_HAND);
  endShape();

  beginShape();
  plotCurveVertexAtJointPosition(SimpleOpenNI.SKEL_NECK);
  plotCurveVertexAtJointPosition(SimpleOpenNI.SKEL_NECK);
  plotCurveVertexAtJointPosition(SimpleOpenNI.SKEL_TORSO);
  plotCurveVertexAtJointPosition(SimpleOpenNI.SKEL_LEFT_HIP);
  plotCurveVertexAtJointPosition(SimpleOpenNI.SKEL_LEFT_KNEE);
  plotCurveVertexAtJointPosition(SimpleOpenNI.SKEL_LEFT_FOOT);
  plotCurveVertexAtJointPosition(SimpleOpenNI.SKEL_LEFT_FOOT);
  endShape();

  beginShape();
  plotCurveVertexAtJointPosition(SimpleOpenNI.SKEL_NECK);
  plotCurveVertexAtJointPosition(SimpleOpenNI.SKEL_NECK);
  plotCurveVertexAtJointPosition(SimpleOpenNI.SKEL_TORSO);
  plotCurveVertexAtJointPosition(SimpleOpenNI.SKEL_RIGHT_HIP);
  plotCurveVertexAtJointPosition(SimpleOpenNI.SKEL_RIGHT_KNEE);
  plotCurveVertexAtJointPosition(SimpleOpenNI.SKEL_RIGHT_FOOT);
  plotCurveVertexAtJointPosition(SimpleOpenNI.SKEL_RIGHT_FOOT);
  endShape();

  noStroke();
  popMatrix();
  popStyle();
}

public void plotCurveVertexAtJointPosition(int joint) {
  PVector jointPositionRealWorld = new PVector();
  PVector jointPositionProjective = new PVector();
  context.getJointPositionSkeleton(1, joint, jointPositionRealWorld);
  context.convertRealWorldToProjective(jointPositionRealWorld, jointPositionProjective);

  curveVertex(jointPositionProjective.x*USER_SCALE_FACTOR+USER_SHIFT_X, jointPositionProjective.y*USER_SCALE_FACTOR+USER_SHIFT_Y);
}

public PVector getJointPosition(int joint) {
  PVector jointPositionRealWorld = new PVector();
  PVector jointPositionProjective = new PVector();
  context.getJointPositionSkeleton(1, joint, jointPositionRealWorld);
  context.convertRealWorldToProjective(jointPositionRealWorld, jointPositionProjective);

  return jointPositionProjective;
}

public void drawCircle(PVector position) {
  pushMatrix();
  translate(position.x*USER_SCALE_FACTOR+USER_SHIFT_X, position.y*USER_SCALE_FACTOR+USER_SHIFT_Y);
  ellipse(0, 0, 40, 40);
  popMatrix();
}

// -----------------------------------------------------------------
// SimpleOpenNI events

public void onNewUser(SimpleOpenNI curContext, int userId)
{
  println("onNewUser - userId: " + userId);
  println("\tstart tracking skeleton");

  curContext.startTrackingSkeleton(userId);
}

public void onLostUser(SimpleOpenNI curContext, int userId)
{
  println("onLostUser - userId: " + userId);
}

public void onVisibleUser(SimpleOpenNI curContext, int userId)
{
  //println("onVisibleUser - userId: " + userId);
}
class Line {
  
  public Line(float x1, float y1, float z1, float x2, float y2, float z2) {
    this.x1 = x1;
    this.y1 = y1;
    this.x2 = x2;
    this.y2 = y2;
    this.z1 = z1;
    this.z2 = z2;
  }
 
  float x1;
  float x2;
  float y1;
  float y2;
  float z1;
  float z2;
}
/* -------------- Other functions ----------------- */

// check if two stars are supposed to be connected
public boolean CheckStarMapping(Star star1, Star star2, Constellation constellation) {
  return constellation.map.get(star1.id).contains(star2.id);
}


// check if two star already are connected
public boolean CheckStarConnection(Star star1, Star star2) {
  return star1.connections.contains(star2.id);
}

public boolean CheckConstellationComplete(Constellation c) {

  for(int i = 0; i < c.stars.length; i++) {
    for(int z = 0; z < c.map.get(c.stars[i].id).size(); z++) {
      if(!c.stars[i].connections.contains(c.map.get(c.stars[i].id).get(z))) {
        return false;
      }
    }
  }  
  return true;
}


// add a line to the lines array, if they should
public void AddLine(Star star1, Star star2, Constellation constellation) {
  
  if(!CheckStarConnection(star1, star2)) {
    // add stars to connection order arrays
    if (constellation.connectionOrder.size() != 0 && constellation.connectionOrder.get(constellation.connectionOrder.size() - 1).id == star1.id) {
      constellation.connectionOrder.add(star2);
    }
    else {
      constellation.connectionOrder.add(star1);
      constellation.connectionOrder.add(star2);
    }
    
    // add line to lines array
    lines.add(new Line(star1.pX, star1.pY, star1.pZ, star2.pX, star2.pY, star2.pZ));
    
    // add stars to each other's connections
    star1.connections.add(star2.id);
    star2.connections.add(star1.id);   
    
    if(CheckConstellationComplete(constellation)) {
      constellation.complete = true;
    }
  }
}

// add all lines to solve a constellation
public void AddAllLines(Constellation c) {
  println(c.name);
  
  Iterator<Entry<String, ArrayList<String>>> iter = c.map.entrySet().iterator();     
  while(iter.hasNext()) {
    Entry<String, ArrayList<String>> entry = iter.next();
      for(int i = 0; i < entry.getValue().size(); i++) {
        Star star1 = null;
        Star star2 = null;
        
        for(int z = 0; z < c.stars.length; z++) {
          if(c.stars[z].id.equals(entry.getKey())) {
            star1 = c.stars[z];
          }          
          if(c.stars[z].id.equals(entry.getValue().get(i))) {
            star2 = c.stars[z];
          }       
        }        
        AddLine(star1, star2, c);        
      }
    }
}

public void DrawLine(Line line) {
  stroke(255);
  line(line.x1, line.y1, line.z1, line.x2, line.y2, line.z2);
  noStroke();
}


// play the melody on a separate thread
class PlayFinalMelody implements Runnable {
  private Thread t;
  private Constellation c;
  
  public PlayFinalMelody (Constellation c) {
    this.c = c;
  }
  
  public void run() {
    for(int i = 0; i < c.connectionOrder.size(); i++) {
      PlaySound(c.connectionOrder.get(i).sound);
      delay(200);
    }
  }
  
  public void start () {
      if (t == null) {
         t = new Thread (this);
         t.start ();
      }
   }
}

// draw the image on the constellation
public void drawImage(Constellation c) {
  fill(200, 200, 200, 50);
  pushMatrix();
  translate(c.imgPosX, c.imgPosY, c.imgPosZ);
  shape(c.image, 0, 0, c.cWidth, c.cHeight);  
  popMatrix();
}


// find the right position for the image on the constellation
public void findImagePosition(Constellation c) {
  float minX = Float.MAX_VALUE, minY = Float.MAX_VALUE, minZ = Float.MAX_VALUE;
  float maxX = 0, maxY = 0, maxZ = 0;
  
  for(int i = 0; i < c.stars.length; i++) {
    if(c.stars[i].x < minX) { minX = c.stars[i].x;}
    if(c.stars[i].x > maxX) { maxX = c.stars[i].x;} 
    if(c.stars[i].y < minY) { minY = c.stars[i].y;}
    if(c.stars[i].y > maxY) { maxY = c.stars[i].y;}
    if(c.stars[i].z < minZ) { minZ = c.stars[i].z;}
    if(c.stars[i].z > maxZ) { maxZ = c.stars[i].z;}
  }
  
  c.cWidth = maxX-minX;  
  c.cHeight = maxY-minY;
  c.imgPosX = minX;
  c.imgPosY = minY;
  c.imgPosZ = minZ;
}


// Play one sound
public void PlaySound(int sound) {
  OscMessage myMessage = new OscMessage("/puredata");
  myMessage.add(sound);
  oscP5.send(myMessage, myRemoteLocation); 
}


// start the background sound
public void PlayBackgroundMusic() {
  OscMessage myMessage = new OscMessage("/puredata");
  myMessage.add(1);
  oscP5.send(myMessage, myRemoteLocationBackground); 
}

// skip to next constellations
public void nextConstellations() {
  if (constellationsShown + noOfConstellationsOnScreen < constellations.size()) {
      constellationsShown += noOfConstellationsOnScreen;
    } else {
      constellationsShown = 0;
    }     

    // reset all values
    lines = new ArrayList<Line>();

    Iterator<Entry<String, Constellation>> iter = constellations.entrySet().iterator();     
    while (iter.hasNext ()) {
      Entry<String, Constellation> entry = iter.next();
      entry.getValue().melodyPlayed = false;
      entry.getValue().complete = false;
      entry.getValue().showImage = false;
      entry.getValue().connectionOrder = new ArrayList<Star>();
      for (int i = 0; i < entry.getValue ().stars.length; i++) {
        entry.getValue().stars[i].connections = new ArrayList<String>();
      }
    }
}

// Draw all lines for the constellations of screen
public void solveConstellations() {
  Iterator<Entry<String, Constellation>> iter = constellations.entrySet().iterator();
    for (int i = 0; i < constellationsShown; i++) {
      iter.next();
    }

    int conCounter = 0;

    while (iter.hasNext ())
    {
      if (conCounter < noOfConstellationsOnScreen) {
        Entry<String, Constellation> entry = iter.next();
        AddAllLines(entry.getValue());
        conCounter++;
      } else {
        iter.next();
      }
    }
}
public void ProcessStar(Star star, boolean constellationStar) {
  
  // use different color if star is chosen
    if(star.chosen && star.sizeChanged == false) {
      star.clr = color(255, 255,153);
      star.size = star.size*(100/(100-STAR_TOUCHED_SIZE*100));    
      star.sizeChanged = true;  
    } 
    else {
      star.clr = color(255);
     star.size = star.originalSize;
     star.sizeChanged = false;

    }    
  
    pushMatrix();
    translate(star.x, star.y, star.z);
    
    // draw star
    fill(star.clr);
    sphere(star.size);    
    fill(255);
    
    // find actual screen coordinates 
    float x = screenX(0, 0, 0);
    float y = screenY(0, 0, 0);
    
    // save the model coordinates on the star
    star.pX = modelX(0, 0, 0);
    star.pY = modelY(0, 0, 0);
    star.pZ = modelZ(0, 0, 0);
    
    popMatrix();    
    
    PVector leftHand = getJointPosition(SimpleOpenNI.SKEL_LEFT_HAND);
    PVector rightHand = getJointPosition(SimpleOpenNI.SKEL_RIGHT_HAND);
    
    // Get screen coordinates for hands
    float lX = screenX(leftHand.x*USER_SCALE_FACTOR+USER_SHIFT_X, leftHand.y*USER_SCALE_FACTOR+USER_SHIFT_Y, 0);
    float lY = screenY(leftHand.x*USER_SCALE_FACTOR+USER_SHIFT_X, leftHand.y*USER_SCALE_FACTOR+USER_SHIFT_Y, 0);
    float rX = screenX(rightHand.x*USER_SCALE_FACTOR+USER_SHIFT_X, rightHand.y*USER_SCALE_FACTOR+USER_SHIFT_Y, 0);
    float rY = screenY(rightHand.x*USER_SCALE_FACTOR+USER_SHIFT_X, rightHand.y*USER_SCALE_FACTOR+USER_SHIFT_Y, 0);
    
    if(((lX >= (x - TOUCH_MARGIN) && lX <= (x + TOUCH_MARGIN)) 
    && (lY >= (y - TOUCH_MARGIN) && lY <= (y + TOUCH_MARGIN)))
    || ((rX >= (x - TOUCH_MARGIN) && rX <= (x + TOUCH_MARGIN)) 
    && (rY >= (y - TOUCH_MARGIN) && rY <= (y + TOUCH_MARGIN)))) {       
      
      // set to chosen star
      if(previousStar != null) {
        previousStar.chosen = false;
      }
      star.chosen = true;
        
      // add a line if there should be one
      if(constellationStar) {       
        if(previousStar != null 
        && previousStar.constellationName == star.constellationName 
        && CheckStarMapping(star, previousStar, constellations.get(star.constellationName))) {
          AddLine(previousStar, star, constellations.get(star.constellationName));          
        }    
        // otherwise just draw a line and don't save it
        else if (previousStar != null) {
          DrawLine(new Line(previousStar.pX, previousStar.pY, previousStar.pZ, star.pX, star.pY, star.pZ));
        }
      }
      else {        
        if(previousStar != null) {
          DrawLine(new Line(previousStar.pX, previousStar.pY, previousStar.pZ, star.pX, star.pY, star.pZ));
        }
      }
      
      previousStar = star;
      
      // play star sound only once
      if(!star.soundPlayed) {
        PlaySound(star.sound);
        star.soundPlayed = true;
      }
  }
  else {
    star.soundPlayed = false;
  }     
  
  // check if constellation is done and mouse is clicked on the constellation, then play the melody (position not working properly in 3D)
  if(constellationStar && mousePressed && constellations.get(star.constellationName).complete) {
     Constellation c = constellations.get(star.constellationName); 
     
     pushMatrix();
     translate(c.imgPosX, c.imgPosY, c.imgPosZ);
     c.mImgPosX = screenX(0, 0, 0);
     c.mImgPosY = screenY(0, 0, 0);       
     popMatrix();
     
     if((mouseX >= c.mImgPosX && mouseX <= c.mImgPosX+c.cWidth/2 
     && (mouseY >= c.mImgPosY && mouseY <= c.mImgPosY+c.cHeight/2))) {
       PlayFinalMelody obj = new PlayFinalMelody(constellations.get(star.constellationName));
       obj.start();
     }
  }
}
class Star {
  
  Star(float x, float y, float z, float size, int sound, String id, String constellationName) {
    this.x = x;
    this.y = y;
    this.z = z;
    this.size = size;
    this.sound = sound;
    this.id = id;  
    this.constellationName = constellationName;
    this.originalSize = size;
  }
  
 float x;
 float y;
 float z;
 
 // previous model coordinates
 float pX;
 float pY;
 float pZ;
 
 
 float size;
 float originalSize;;
 int sound;
 String id;
 String constellationName;
 boolean chosen = false;
 boolean soundPlayed = false;
 boolean sizeChanged = false;
 int clr = color(255);
 ArrayList<String> connections = new ArrayList<String>();
 
}
/* ---------- star generation ---------- */

public void GenerateStars() {
  // generate random stars
  for(int i = 0; i < STAR_COUNT; i++) {
     stars[i] = 
     new Star(PApplet.parseInt(random(-width, width)), PApplet.parseInt(random(-height, height)), PApplet.parseInt(random(-height, height)), PApplet.parseInt(random(MIN_STAR_SIZE, MAX_STAR_SIZE)), RANDOM_STAR_NOTE, "", "");
  }
}

public void GenerateConstellations() {
       
  Table constellationCodeTable;
  constellationCodeTable = loadTable(constellationCodesCSV, "header"); //"header" captures the name of columns
  
  for (TableRow row : constellationCodeTable.rows()) {
        
    // Get data about constellation
    String conCode = row.getString("CON");
    String conName = row.getString("CONNAME");
    float sizeX = row.getFloat("sizeX");
    float sizeY = row.getFloat("sizeY");
    float posX = row.getFloat("posX");
    float posY = row.getFloat("posY");
    float posZ = random(-CONSTELLATION_Z_AXIS_DEPTH, CONSTELLATION_Z_AXIS_DEPTH);
    
    String svgImageFile = conName.toLowerCase() + ".svg";     
    PShape image = loadShape(svgImageFile);
    image.disableStyle();
        
    // Get data about stars
    Table constellationTable;
    ArrayList<PVector> coordList = new ArrayList<PVector>();
    ArrayList<String> starNames = new ArrayList<String>();
    ArrayList<Integer> notes = new ArrayList<Integer>();
    HashMap<String, ArrayList<String>> starLinks = new HashMap<String, ArrayList<String>>();
      
    constellationTable = loadTable(constellationStarsCSV, "header"); //"header" captures the name of columns
  
    for (TableRow tr : constellationTable.findRows(conCode, "CON")) { // Foreach enhanced loop to populate ArrayList w coordinates
      
      coordList.add(new PVector(tr.getFloat("RA"),tr.getFloat("DEC"),tr.getFloat("MAG")));
      String starName = tr.getString("NAME");
      starNames.add(starName);      
      
      Integer note = tr.getInt("noteNUM");
      notes.add(note);
      
      String linkString = tr.getString("LINKS");
      String[] linkArray = linkString.split("-");      
      ArrayList<String> linkedStars =  new ArrayList<String>();

      for(int indx = 0; indx < linkArray.length; indx++) {
        linkedStars.add(linkArray[indx]);
      }      
      
      starLinks.put(starName, linkedStars);    
      
    }
        
    // To work out min/max coordinates and magnitude for this constellation
    float[] xPos = new float[coordList.size()];
    float[] yPos = new float[coordList.size()];
    float[] zPos = new float[coordList.size()];
    for(int idx = 0; idx < coordList.size(); idx++) { 
      xPos[idx] = coordList.get(idx).x;
      yPos[idx] = coordList.get(idx).y;
      zPos[idx] = coordList.get(idx).z;
    }
    
    float[] minMax = new float[6]; 
    minMax[0] = min(xPos); minMax[1] = max(xPos);
    minMax[2] = min(yPos); minMax[3] = max(yPos);
    minMax[4] = min(zPos); minMax[5] = max(zPos);
    
    if (USE_CSV_POSITIONS) {
      // map the constellations according to values from csv
      for(int index = 0; index < coordList.size(); index++) {
        float x = map(coordList.get(index).x, minMax[0], minMax[1], width*posX+width*sizeX, width*posX);
        float y = map(coordList.get(index).y, minMax[2], minMax[3], height*posY+height*sizeY, height*posY);
        float z = map(coordList.get(index).z, minMax[4], minMax[5], CONSTELLATION_STAR_SIZE_MIN, CONSTELLATION_STAR_SIZE_MAX);
        // let's centre the map
        x = x-width;
        y = y-height;
        PVector p = new PVector(x,y,z);
        coordList.set(index, p);
      }
    }
    else {      
      // map(); the constellation to screen size
      for(int index = 0; index < coordList.size(); index++) {
        float x = map(coordList.get(index).x, minMax[0], minMax[1], width-SCREEN_MARGIN_X, SCREEN_MARGIN_X);
        float y = map(coordList.get(index).y, minMax[2], minMax[3], height-SCREEN_MARGIN_Y, SCREEN_MARGIN_Y);
        float z = map(coordList.get(index).z, minMax[4], minMax[5], CONSTELLATION_STAR_SIZE_MIN, CONSTELLATION_STAR_SIZE_MAX);
        // let's centre the map
        x = x-width/2;
        y = y-height/2;
        PVector p = new PVector(x,y,z);
        coordList.set(index, p);
      }
    }
    
    Star[] conStars = new Star[coordList.size()];    
    
    for(int starIndex = 0; starIndex < coordList.size(); starIndex++) {
      conStars[starIndex] = 
      new Star(coordList.get(starIndex).x, coordList.get(starIndex).y, posZ, coordList.get(starIndex).z, notes.get(starIndex), starNames.get(starIndex), conName);
    }
    
    Constellation t = new Constellation(conName, conStars, starLinks, image);
    constellations.put(conName, t);  
    findImagePosition(t);
  }
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "ZodiacKinect" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
