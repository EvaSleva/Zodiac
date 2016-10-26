import oscP5.*;
import netP5.*;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Map.Entry;

// Variables
OscP5 oscP5;
NetAddress myRemoteLocation;
NetAddress myRemoteLocationBackground;
PImage bgImage;

int STAR_COUNT = 50;
int TOUCH_MARGIN = 5;
float MAX_STAR_SIZE = 7;
float MIN_STAR_SIZE = 4;
int CONSTELLATION_STAR_SIZE_MIN = 6;
int CONSTELLATION_STAR_SIZE_MAX = 8;
float SCREEN_MARGIN_X = width*0.1;
float SCREEN_MARGIN_Y = height*0.1;
int RANDOM_STAR_NOTE = 55;
boolean USE_CSV_POSITIONS = true;
float STAR_TOUCHED_SIZE = 0.25;

Star previousStar;
float rotation = 0;
int constellationsShown = 0;
int noOfConstellationsOnScreen = 10;

Star[] stars = new Star[STAR_COUNT];
  HashMap<String, Constellation> constellations = new HashMap<String, Constellation>();
ArrayList<Line> lines = new ArrayList<Line>();
String constellationStarsCSV = "constellations-zodiac.csv";
String constellationCodesCSV = "constellation-codes-zodiac.csv";


// ----- Setup function -----

void setup() {
  size(1920, 1080, P3D);
  noStroke();
  bgImage = loadImage("green-bg.jpg");
  
  // intialize network variables
  oscP5 = new OscP5(this,12345); // incoming on 12345
  myRemoteLocation = new NetAddress("127.0.0.1", 12346); // outgoing on 12346
  myRemoteLocationBackground = new NetAddress("127.0.0.1", 12347); // outgoing on 12346
  
  // Generate stars and play background sound
  GenerateStars();
  GenerateConstellations();
  PlayBackgroundMusic();
}



// -----  draw function -----

void draw() {
  background(bgImage);
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
 
   Iterator<Entry<String, Constellation>> iter = constellations.entrySet().iterator();
   for(int i = 0; i < constellationsShown; i++) {
      iter.next();
    }
   
   int conCounter = 0;
   
  // draw constellations
  while(iter.hasNext())
  {
    if(conCounter < noOfConstellationsOnScreen) {
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
      conCounter++;
    }
    else {
      iter.next();
    }
  }
    
  rotation += 0.1;
  
}

// Enter for changing constellation, 's' for completing constellation
void keyPressed() {
  
   if(key == ENTER) {
     if(constellationsShown + noOfConstellationsOnScreen <= constellations.size()) {
       constellationsShown += noOfConstellationsOnScreen;
     }
     else {
       constellationsShown = 0;
     }     
     
     // reset all values
     lines = new ArrayList<Line>();
     
     Iterator<Entry<String, Constellation>> iter = constellations.entrySet().iterator();     
     while(iter.hasNext()) {
       Entry<String, Constellation> entry = iter.next();
       entry.getValue().melodyPlayed = false;
       entry.getValue().complete = false;
       entry.getValue().connectionOrder = new ArrayList<Star>();
       for(int i = 0; i < entry.getValue().stars.length; i++) {
         entry.getValue().stars[i].connections = new ArrayList<String>();
       }
     }
   }
   
   
   if(key == 's') {
     Iterator<Entry<String, Constellation>> iter = constellations.entrySet().iterator();
     for(int i = 0; i < constellationsShown; i++) {
        iter.next();
      }
   
     int conCounter = 0;
     
      while(iter.hasNext())
      {
        if(conCounter < noOfConstellationsOnScreen) {
          Entry<String, Constellation> entry = iter.next();
          AddAllLines(entry.getValue());
          conCounter++;
        }
        else {
          iter.next();
        }
      }          
   }
}
