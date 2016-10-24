import oscP5.*;
import netP5.*;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Map.Entry;

//12334

// Variables
OscP5 oscP5;
NetAddress myRemoteLocation;
NetAddress myRemoteLocationBackground;

float rotation = 0;
int STAR_COUNT = 50;
int TOUCH_MARGIN = 5;
float MAX_STAR_SIZE = 7;
float MIN_STAR_SIZE = 4;
int CONSTELLATION_STAR_SIZE_MIN = 6;
int CONSTELLATION_STAR_SIZE_MAX = 8;
float MAX_STAR_SOUND = 1500;
float MIN_STAR_SOUND = 1000;
float SCREEN_MARGIN_X = width*0.2;
float SCREEN_MARGIN_Y = height*0.2;
int RANDOM_STAR_NOTE = 55;
Star previousStar;

Star[] stars = new Star[STAR_COUNT];
HashMap<String, Constellation> constellations = new HashMap<String, Constellation>();
ArrayList<Line> lines = new ArrayList<Line>();
String constellationStarsCSV = "constellations-zodiac.csv";
String constellationCodesCSV = "constellation-codes-zodiac.csv";

// Setup function
void setup() {
  size(1200, 750, P3D);
  noStroke();
  
  // intialize network variables
  oscP5 = new OscP5(this,12345); // incoming on 12345
  myRemoteLocation = new NetAddress("127.0.0.1", 12346); // outgoing on 12346
  myRemoteLocationBackground = new NetAddress("127.0.0.1", 12347); // outgoing on 12346
    
  
  
  // Generate stars and play background sound
  GenerateStars();
  GenerateConstellations();
  PlayBackgroundMusic();
}


// draw function
void draw() {
  background(0);
  lights();
  
  // camera rotation
  float orbitRadius= width;
  float xPos = cos(radians(rotation))*orbitRadius;
  float zPos = sin(radians(rotation))*orbitRadius;
  
  camera(xPos, height/2, zPos, 0, 0, 0, 0, 1, 0);

  // draw stars
  for(int i = 0; i < STAR_COUNT; i++) {
    ProcessStar(stars[i], false);    
  } 
  
  // draw lines
  for(int i = 0; i < lines.size(); i++) {
    DrawLine(lines.get(i));
  }
 
  // draw constellations
  for (Iterator<Entry<String, Constellation>> iter = constellations.entrySet().iterator(); iter.hasNext(); )
  {
    Entry<String, Constellation> entry = iter.next();
    Constellation c = entry.getValue();
    
    // draw constellation
    for(int z = 0; z < entry.getValue().stars.length; z++) {
      ProcessStar(c.stars[z], true);
    }
    
    if(c.showImage) {
      drawImage(c);
    }
    
    // check if constellation is complete
    if(c.complete && !c.melodyPlayed) {
      
      // play melody on separate thread
      PlayFinalMelody obj = new PlayFinalMelody(c);
      obj.start();
      c.melodyPlayed = true;
      drawImage(c);
      c.showImage = true;
    }
  }
    
  rotation += 0.1;
  
}


/* -------------- Other functions ----------------- */

void ProcessStar(Star star, boolean constellationStar) {
  
  // use different color if star is chosen
    if(star.chosen) {
      star.clr = color(255, 255, 102); 
    } 
    else {
      star.clr = color(255); 
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
    
    // check if mouse touches star
    if((mouseX >= (x - TOUCH_MARGIN) && mouseX <= (x + TOUCH_MARGIN)) && (mouseY >= (y - TOUCH_MARGIN) && mouseY <= (y + TOUCH_MARGIN))) {
      
      // set to chosen star
      if(previousStar != null) {
        previousStar.chosen = false;
      }
      star.chosen = true;
        
      // add a line if there should be one
      if(constellationStar) {       
        if(previousStar != null && previousStar.constellationName == star.constellationName && CheckStarMapping(star, previousStar, constellations.get(star.constellationName))) { //<>//
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
      
      // play star sound once
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
     translate(c.imgPosX, c.imgPosY, 0);
     c.mImgPosX = screenX(0, 0, 0);
     c.mImgPosY = screenY(0, 0, 0);       
     popMatrix();
     
     if((mouseX >= c.mImgPosX && mouseX <= c.mImgPosX+c.cWidth/2 && (mouseY >= c.mImgPosY && mouseY <= c.mImgPosY+c.cHeight/2))) {
       PlayFinalMelody obj = new PlayFinalMelody(constellations.get(star.constellationName));
       obj.start();
     }
  }
}

// check if two stars are supposed to be connected
boolean CheckStarMapping(Star star1, Star star2, Constellation constellation) { //<>//
  return constellation.map.get(star1.id).contains(star2.id); //<>//
}

// check if two star already are connected
boolean CheckStarConnection(Star star1, Star star2) {
  return star1.connections.contains(star2.id);
}

boolean CheckConstellationComplete(Constellation c) {
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
void AddLine(Star star1, Star star2, Constellation constellation) {
  
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

void DrawLine(Line line) {
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

void drawImage(Constellation c) {
  fill(255,0);
  shape(c.image, c.imgPosX, c.imgPosY, c.cWidth, c.cHeight);  
}

// find the right position for the image on the constellation
void findImagePosition(Constellation c) {
  float minX = Float.MAX_VALUE, minY = Float.MAX_VALUE;
  float maxX = 0, maxY = 0;
  
  for(int i = 0; i < c.stars.length; i++) {
    if(c.stars[i].x < minX) { minX = c.stars[i].x;}
    if(c.stars[i].x > maxX) { maxX = c.stars[i].x;} 
    if(c.stars[i].y < minY) { minY = c.stars[i].y;}
    if(c.stars[i].y > maxY) { maxY = c.stars[i].y;}
  }
  
  c.cWidth = maxX-minX;  
  c.cHeight = maxY-minY;
  c.imgPosX = minX;
  c.imgPosY = minY;
}

void PlaySound(int sound) {
  OscMessage myMessage = new OscMessage("/puredata");
  myMessage.add(sound);
  oscP5.send(myMessage, myRemoteLocation); 
}

void PlayBackgroundMusic() {
  OscMessage myMessage = new OscMessage("/puredata");
  myMessage.add(1);
  oscP5.send(myMessage, myRemoteLocationBackground); 
}


/* ---------- star generation ---------- */

void GenerateStars() {
  // generate random stars
  for(int i = 0; i < STAR_COUNT; i++) {
     stars[i] = new Star(int(random(-width, width)), int(random(-height, height)), int(random(-height, height)), int(random(MIN_STAR_SIZE, MAX_STAR_SIZE)), RANDOM_STAR_NOTE, "", "");
  }
}

void GenerateConstellations() {
       
  Table constellationCodeTable;
  constellationCodeTable = loadTable(constellationCodesCSV, "header"); //"header" captures the name of columns
  
  for (TableRow row : constellationCodeTable.rows()) {
        
    // Get data about constellation
    String conCode = row.getString("CON");
    String conName = row.getString("CONNAME");
    String conColourHex = row.getString("COLOUR");
    color conColour =  unhex(conColourHex);  
   
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
    
    // map(); the constellation to screen size
    for(int index = 0; index < coordList.size(); index++) {
      float x = map(coordList.get(index).x, minMax[0], minMax[1], width-SCREEN_MARGIN_X, SCREEN_MARGIN_X);
      float y = map(coordList.get(index).y, minMax[2], minMax[3], height-SCREEN_MARGIN_Y, SCREEN_MARGIN_Y);
      float z = map(coordList.get(index).z, minMax[4], minMax[5], CONSTELLATION_STAR_SIZE_MIN, CONSTELLATION_STAR_SIZE_MAX);
      PVector p = new PVector(x,y,z);
      coordList.set(index, p);
    }
    
    Star[] conStars = new Star[coordList.size()];
    
    
    for(int starIndex = 0; starIndex < coordList.size(); starIndex++) {
      conStars[starIndex] = new Star(coordList.get(starIndex).x, coordList.get(starIndex).y, 0, coordList.get(starIndex).z, notes.get(starIndex), starNames.get(starIndex), conName);
    }
    
    Constellation t = new Constellation(conName, conStars, starLinks, image);
    constellations.put(conName, t);  
    findImagePosition(t);
  }

}