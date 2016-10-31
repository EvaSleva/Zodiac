import oscP5.*;
import netP5.*;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Map.Entry;
import SimpleOpenNI.*;

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
float SCREEN_MARGIN_X = width*0.1;
float SCREEN_MARGIN_Y = height*0.1;
int RANDOM_STAR_NOTE = -39;
boolean USE_CSV_POSITIONS = true;
float STAR_TOUCHED_SIZE = 0.3;
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
//boolean       autoCalib=true;

// ----- Setup function -----

void setup() {
  
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

void draw() {
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

  rotation += 0.1;

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

boolean hasFinished() {
  return millis() - startTime > WAIT_TIME;
}

// Enter for changing constellation, 's' for completing constellation
void keyPressed() {

  if (key == ENTER) {
    nextConstellations();
  }

  if (key == 's') {
    solveConstellations();
  }
}