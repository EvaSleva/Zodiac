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

int STAR_COUNT = 100;
float MAX_STAR_SIZE = 5;
float MIN_STAR_SIZE = 2;
int CONSTELLATION_STAR_SIZE_MIN = 6;
int CONSTELLATION_STAR_SIZE_MAX = 8;
float MAX_STAR_SOUND = 1500;
float MIN_STAR_SOUND = 1000;
int TOUCH_MARGIN = 5; 
Star previousStar;

Star[] stars = new Star[STAR_COUNT];
HashMap<String, Constellation> constellations = new HashMap<String, Constellation>();
ArrayList<Line> lines = new ArrayList<Line>();

// Setup function
void setup() {
  
  size(1200, 750);
  noStroke();
  fill(255);
  
  // intialize network variables
  oscP5 = new OscP5(this,12345); // incoming on 12345
  myRemoteLocation = new NetAddress("127.0.0.1", 12346); // outgoing on 12346
  myRemoteLocationBackground = new NetAddress("127.0.0.1", 12347); // outgoing on 12346
  
  // Generate stars and play background sound
  GenerateStars();
  GenerateConstellations();  
  PlayBackgroundMusic();
}

// Draw function
void draw() {
  background(0);
  
  for(int i = 0; i < STAR_COUNT; i++) {
    ProcessStar(stars[i], false);    
  }  
  
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
}


/* -------------- Other functions ----------------- */

void ProcessStar(Star star, boolean constellationStar) {
  
  // check if mouse touches star
  if((mouseX >= (star.x - TOUCH_MARGIN) && mouseX <= (star.x + TOUCH_MARGIN)) && (mouseY >= (star.y - TOUCH_MARGIN) && mouseY <= (star.y + TOUCH_MARGIN))) {
    
    // set to chosen star
    if(previousStar != null) {
      previousStar.chosen = false;
    }
    star.chosen = true;
    
    if(constellationStar) {       
      if(previousStar != null && CheckStarMapping(star, previousStar, constellations.get(star.constellationName))) {
        AddLine(previousStar, star, constellations.get(star.constellationName));          
      }    
      else if (previousStar != null) {
        DrawLine(new Line(previousStar.x, previousStar.y, star.x, star.y));
      }
    }
    else {        
      if(previousStar != null) {
        DrawLine(new Line(previousStar.x, previousStar.y, star.x, star.y));
      }
    }
    previousStar = star; 
    
    if(!star.soundPlayed) {
      PlaySound(star.sound);
      star.soundPlayed = true;
    }
  }
  else {
    star.soundPlayed = false;
  }
    
  // check if constellation is done and mouse is clicked on the constellation
  if(constellationStar && mousePressed && constellations.get(star.constellationName).complete) {
     Constellation c = constellations.get(star.constellationName); 
     
     if((mouseX >= c.imgPosX && mouseX <= c.imgPosX+c.cWidth && (mouseY >= c.imgPosY && mouseY <= c.imgPosY+c.cHeight))) {
       PlayFinalMelody obj = new PlayFinalMelody(constellations.get(star.constellationName));
       obj.start();
     }
  }    
    
  // draw a star if the star is chosen, otherwise just a circle
  if(star.chosen) { 
    fill(star.clr);
    star(star.x, star.y, (star.size+3)/2, star.size+3, 5);
    fill(255);
  }
  else {
    fill(star.clr);
    ellipse(star.x, star.y, star.size, star.size);
    fill(255); 
  }
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

// check if two stars are supposed to be connected
boolean CheckStarMapping(Star star1, Star star2, Constellation constellation) {
  return constellation.map.get(star1.id).contains(star2.id);
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
    lines.add(new Line(star1.x, star1.y, star2.x, star2.y));
    
    // add stars to each other's connections
    star1.connections.add(star2.id);
    star2.connections.add(star1.id);   
    
    if(CheckConstellationComplete(constellation)) {
      constellation.complete = true;
    }
  }
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

void DrawLine(Line line) {
  stroke(255);
  line(line.x1, line.y1, line.x2, line.y2);
  noStroke();
}

// draw star
void star(float x, float y, float radius1, float radius2, int npoints) {
  float angle = TWO_PI / npoints;
  float halfAngle = angle/2.0;
  beginShape();
  for (float a = 0; a < TWO_PI; a += angle) {
    float sx = x + cos(a) * radius2;
    float sy = y + sin(a) * radius2;
    vertex(sx, sy);
    sx = x + cos(a+halfAngle) * radius1;
    sy = y + sin(a+halfAngle) * radius1;
    vertex(sx, sy);
  }
  endShape(CLOSE);
}

void drawImage(Constellation c) {  
  image(c.image, c.imgPosX, c.imgPosY, c.cWidth, c.cHeight);  
}

// find the right position for the image on the constellation
void findImagePosition(Constellation c) {
  int minX = Integer.MAX_VALUE, minY = Integer.MAX_VALUE;
  int maxX = 0, maxY = 0;
  
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

/* ---------- Star Generation ----------- */

void GenerateStars() {
  // generate random stars
  for(int i = 0; i < STAR_COUNT; i++) {
     stars[i] = new Star(int(random(0, width)), int(random(0, height)), int(random(MIN_STAR_SIZE, MAX_STAR_SIZE)), int(random(MIN_STAR_SOUND, MAX_STAR_SOUND)), "", "");
  }
}

void GenerateConstellations() {
    
  // Taurus
  Star[] taurusStars = new Star[] {
    new Star(200, 108, int(random(CONSTELLATION_STAR_SIZE_MIN, CONSTELLATION_STAR_SIZE_MAX)), Notes.CSharp_6, "t1", "Taurus"),
    new Star(260, 155, int(random(CONSTELLATION_STAR_SIZE_MIN, CONSTELLATION_STAR_SIZE_MAX)), Notes.F_6, "t2", "Taurus"),
    new Star(287, 197, int(random(CONSTELLATION_STAR_SIZE_MIN, CONSTELLATION_STAR_SIZE_MAX)), Notes.GSharp_6, "t3", "Taurus"),
    new Star(265, 219, int(random(CONSTELLATION_STAR_SIZE_MIN, CONSTELLATION_STAR_SIZE_MAX)), Notes.Bb_6, "t4", "Taurus"),
    new Star(172, 180, int(random(CONSTELLATION_STAR_SIZE_MIN, CONSTELLATION_STAR_SIZE_MAX)), Notes.Eb_7, "t5", "Taurus"),
    new Star(297, 217, int(random(CONSTELLATION_STAR_SIZE_MIN, CONSTELLATION_STAR_SIZE_MAX)), Notes.FSharp_6, "t6", "Taurus"),
    new Star(304, 224, int(random(CONSTELLATION_STAR_SIZE_MIN, CONSTELLATION_STAR_SIZE_MAX)), Notes.CSharp_6, "t7", "Taurus"),
    new Star(389, 195, int(random(CONSTELLATION_STAR_SIZE_MIN, CONSTELLATION_STAR_SIZE_MAX)), Notes.F_6, "t8", "Taurus"),
    new Star(308, 246, int(random(CONSTELLATION_STAR_SIZE_MIN, CONSTELLATION_STAR_SIZE_MAX)), Notes.GSharp_6, "t9", "Taurus"),
    new Star(283, 236, int(random(CONSTELLATION_STAR_SIZE_MIN, CONSTELLATION_STAR_SIZE_MAX)), Notes.Bb_6, "t10", "Taurus"),
    new Star(340, 283, int(random(CONSTELLATION_STAR_SIZE_MIN, CONSTELLATION_STAR_SIZE_MAX)), Notes.Eb_7, "t11", "Taurus"),
    new Star(390, 320, int(random(CONSTELLATION_STAR_SIZE_MIN, CONSTELLATION_STAR_SIZE_MAX)), Notes.FSharp_6, "t12", "Taurus"),
    new Star(381, 303, int(random(CONSTELLATION_STAR_SIZE_MIN, CONSTELLATION_STAR_SIZE_MAX)), Notes.CSharp_6, "t13", "Taurus")
  };
  
  // Specify which stars should connect
  HashMap<String, ArrayList<String>> tMap = new HashMap<String, ArrayList<String>>();
  tMap.put("t1", new ArrayList<String>() {{ add("t2"); }});
  tMap.put("t2", new ArrayList<String>() {{ add("t1"); add("t3"); }});
  tMap.put("t3", new ArrayList<String>() {{ add("t2"); add("t4"); add("t6"); }});
  tMap.put("t4", new ArrayList<String>() {{ add("t3"); add("t5"); add("t10"); }});
  tMap.put("t5", new ArrayList<String>() {{ add("t4"); }});
  tMap.put("t6", new ArrayList<String>() {{ add("t3"); add("t7"); }});
  tMap.put("t7", new ArrayList<String>() {{ add("t6"); add("t8"); add("t9"); }});
  tMap.put("t8", new ArrayList<String>() {{ add("t7"); }});
  tMap.put("t9", new ArrayList<String>() {{ add("t7"); add("t10"); add("t11"); }});
  tMap.put("t10", new ArrayList<String>() {{ add("t9"); add("t4"); }});
  tMap.put("t11", new ArrayList<String>() {{ add("t9"); add("t12"); }});
  tMap.put("t12", new ArrayList<String>() {{ add("t11"); add("t13"); }});
  tMap.put("t13", new ArrayList<String>() {{ add("t12"); }});
  
  Constellation t = new Constellation("Taurus", taurusStars, tMap, loadImage("taurus.png"));
  constellations.put("Taurus", t);  
  findImagePosition(t);
  
  
  // Cassiopeia
  Star[] CassiopeiaStars = new Star[] {
    new Star(718, 502, int(random(CONSTELLATION_STAR_SIZE_MIN, CONSTELLATION_STAR_SIZE_MAX)), 1567, "c1", "Cassiopeia"),
    new Star(768, 562, int(random(CONSTELLATION_STAR_SIZE_MIN, CONSTELLATION_STAR_SIZE_MAX)), 1975, "c2", "Cassiopeia"),
    new Star(846, 561, int(random(CONSTELLATION_STAR_SIZE_MIN, CONSTELLATION_STAR_SIZE_MAX)), 2349, "c3", "Cassiopeia"),
    new Star(883, 620, int(random(CONSTELLATION_STAR_SIZE_MIN, CONSTELLATION_STAR_SIZE_MAX)), 3135, "c4", "Cassiopeia"),
    new Star(936, 572, int(random(CONSTELLATION_STAR_SIZE_MIN, CONSTELLATION_STAR_SIZE_MAX)), 3951, "c5", "Cassiopeia")
  };
  
  HashMap<String, ArrayList<String>> cMap = new HashMap<String, ArrayList<String>>();
  cMap.put("c1", new ArrayList<String>() {{ add("c2"); }});
  cMap.put("c2", new ArrayList<String>() {{ add("c1"); add("c3"); }});
  cMap.put("c3", new ArrayList<String>() {{ add("c2"); add("c4"); }});
  cMap.put("c4", new ArrayList<String>() {{ add("c3"); add("c5"); }});
  cMap.put("c5", new ArrayList<String>() {{ add("c4"); }});
  
  Constellation c = new Constellation("Cassiopeia", CassiopeiaStars, cMap, loadImage("Cassiopeia.png"));
  constellations.put("Cassiopeia", c);
  findImagePosition(c);
}