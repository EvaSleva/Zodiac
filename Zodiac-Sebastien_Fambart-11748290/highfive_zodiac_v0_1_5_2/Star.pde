class Star {
// VARIABLES
  float x,y,w,x1,y1,x2,y2,x3,y3; // xy location and width of a perfect circle
  final float larger = 7*MAG_SIZE;
  int idx; // to identify index location
  int group;
  String name;
  boolean isOver = false; // is mouse over a star or not
 
// CONSTRUCTOR
  Star(float ra, float deg, float mag, int id, int grp, String na) {
    x = ra;
    y = deg;
    w = mag;
    idx = id;
    group = grp;
    name = na;
    x1 = x;
    y1 = y;
    x2 = x;
    y2 = y;
    x3 = x;
    y3 = y;
  }

// FUNCTIONS
  // Draw circles
  public void display() {
    
    // Boolean variable determines Star color.
   if (isOver(mouseX,mouseY) && mousePressed) {
      //println("isOver - x: "+x +" y: "+y +" index: "+idx+" larger size: "+larger);
      fill(255,0,0);
      w = larger;
    } 
    else if (isOver(mouseX,mouseY)) {
        //println("in Draw Circles: isOver-- Star:" +name);
        textSize(13);
        fill(255,160);
         // Show Constellation Name if done

        textAlign(LEFT);
        text(name,(x+10),(y-10));        
    }
    else
    {
      fill(255,160);
    }
 
    ellipse(x,y,w,w);
    //triangle(x1-5, y1+3, x2, y2-6, x3+5, y3+3);
    //triangle(x1-5, y1-3, x2, y2+6, x3+5, y3-3);
  }
  
  public int displayIndex() {
    return idx;
  }
  
  public String displayStarName() {
    return name;
  }
  
  public PVector displayCoords() {
    PVector coords = new PVector(x,y,group);
    return coords;
  }
  // Check to see if mouse pointer is over a Star
  public boolean isOver(int mx, int my) { 
    // Left/Right edge is x-w/x+w, Top/Bott edge is y-w/y+w, and larger clickable area with MAG_SIZE
    if (mx > x-w+MAG_SIZE && mx < x+w+MAG_SIZE && my > y-w-MAG_SIZE && my < y+w+MAG_SIZE) {
      //println("isOver-"+x);
      return true;
    } else {
      return false;
    }
  }
  
}