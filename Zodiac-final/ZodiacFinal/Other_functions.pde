/* -------------- Other functions ----------------- */

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


// add a line to the lines array, if they should
void AddLine(Star star1, Star star2, Constellation constellation) {
  
  if(!CheckStarConnection(star1, star2)) { //<>//
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

void AddAllLines(Constellation c) {
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
