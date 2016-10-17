/*------------------------------------------/ 
     App: ZODIAC
     Author: Sebastien Fambart (11748290)
     Group: High Five
     UTS Class: 32027 Interactive Media
     Date: 3 Oct 2016
     Version: 0.1.5.2
/-------------------------------------------*/
import java.awt.Rectangle;
import oscP5.*; // pd-osc
import netP5.*; // pd-osc

OscP5 oscP5; // pd-osc
NetAddress myRemoteLocation; // pd-osc

// Array used to hold Constelation Codes, Name and colour for lines
int CONST_CODE_NAME_ROWS = 12;
int CONST_CODE_NAME_WIDTH = 3; 
String[][] constellationCodeNameList = new String[CONST_CODE_NAME_ROWS][CONST_CODE_NAME_WIDTH];

int currentConstellationCodeIndex = 0;  // Keep track of current index into the constellationCodeNameList
int constellationStarCounter = 0;    // Keep track of how many stars are found
int starCountdown = 1;  // Keep track of how many stars left to find

int constellationStarTotal = 0;      // Number of stars in the Constellation index

// Images for constelations are lowercase Constellation name + ".svg" and are stored in array
PImage bgImage;
PShape svgImage[] = new PShape[CONST_CODE_NAME_ROWS];
String svgImageFile;

Rectangle prevBtn, nextBtn, resetBtn;
String constellationCodeCSV = "constellation-codes-zodiac.csv";
String constellationStarsCSV = "constellations-zodiac.csv";

String constellationCode; 
String constellationName; 

// Array used to hold Constelation Codes, Name and colour for lines

int STAR_NAME_ROWS = 100;
int STAR_NAME_WIDTH = 2; 
String[][] starNameList = new String[STAR_NAME_ROWS][STAR_NAME_WIDTH];

Table table;
float X1, Y1, X2, Y2;
float MAG_SIZE = 2;
float[] minMax = new float[6];
ArrayList<PVector> coordList = new ArrayList<PVector>();
ArrayList<PVector> seqList = new ArrayList<PVector>();

// Arbitrary lists for tracking and drawing constellation segments
ArrayList<PVector> seq1 = new ArrayList<PVector>();
ArrayList<PVector> seq2 = new ArrayList<PVector>();
ArrayList<PVector> seq3 = new ArrayList<PVector>();
ArrayList<PVector> seq4 = new ArrayList<PVector>();
ArrayList<PVector> seq5 = new ArrayList<PVector>();

Star[] stars;
int rectSize = 90; // Button size
boolean mouseOver;

PFont font; 

int[] starGroup; // index to keep track of star clicked on

PVector prevMouse; // variables to store the last click

color[] colours = new color [CONST_CODE_NAME_ROWS];

void setup() {
  size(1280, 800);
  font = createFont("Georgia",18); 
  
  smooth();
  X1 = width*.2;  Y1 = height*.16;  X2 = width - X1;  Y2 = height - Y1; // Display margins for constellation
  
  bgImage = loadImage("green-bg.jpg");
  
  // println("Loading CSV: "+constellationCodeCSV); 
  
  table = loadTable(constellationCodeCSV, "header"); //"header" captures the name of columns  
  createConstCodes(table, "header"); //"header" captures the name of columns
 
  // println("First code in list is: "+constellationCodeNameList[0][0]+" Name: "+constellationCodeNameList[0][1]);
  
  constellationCode = constellationCodeNameList[0][0];
  constellationName = constellationCodeNameList[0][1]; 
  
  table = loadTable(constellationStarsCSV, "header"); //"header" captures the name of columns
  
  createConstellation(table, constellationCode);
  
  prevBtn = new Rectangle(20, height-rectSize/2-20, rectSize, rectSize/2);
  nextBtn = new Rectangle(width-rectSize-20, height-rectSize/2-20, rectSize, rectSize/2);
  resetBtn = new Rectangle(width/2-45, height-rectSize/2-20, rectSize, rectSize/2);
  
  surface.setTitle("Sebastien Fambart - HighFive Group \t ///  \t Zodiac");
  
  /* start oscP5, listening for incoming messages at port 12345 */
  oscP5 = new OscP5(this,12345);
  
  /* myRemoteLocation is a NetAddress. a NetAddress takes 2 parameters,
   * an ip address and a port number. myRemoteLocation is used as parameter in
   * oscP5.send() when sending osc packets to another computer, device, application.
   */
  myRemoteLocation = new NetAddress("127.0.0.1",12346);
  // Pd sound instance
  OscMessage myBgMessage = new OscMessage("/puredata/playBgSound"); 
  oscP5.send(myBgMessage, myRemoteLocation); 
}

// ----------------------------------------------------------------------- DRAW()
void draw() {
  background(0);
  image(bgImage, 0, 0, width, height);
  for (int i = 0; i < stars.length; i++) {
    stars[i].display();
    if (stars[i].isOver(mouseX,mouseY) && mousePressed && starCountdown >= 1) {//called AFTER mouse btn is pressed and THEN released
      // Pd sound instance
      OscMessage myMessage = new OscMessage("/puredata/playSound"); 
      oscP5.send(myMessage, myRemoteLocation); 
      
      int index = stars[i].displayIndex();
      int x = (int) stars[i].displayCoords().x;
      int y = (int) stars[i].displayCoords().y;
      int group = (int) stars[i].displayCoords().z;
      String name = (String) stars[i].displayStarName();
      //println ("In Draw: isOver: Star name is: "+name);
      
      addToSeqList(index,x,y,group);
      prevMouse = new PVector(x,y);
    }
  }
  
  // Draw a line to follow mouse pointer otherwise check if finished constellation then load SVG
  if (prevMouse != null && starCountdown >= 1) {
    line(prevMouse.x,prevMouse.y,mouseX,mouseY);
  } else if (prevMouse != null && starCountdown == 0) {
        textSize(48);
        fill(255,160);
        textAlign(CENTER);
        text(constellationCodeNameList[currentConstellationCodeIndex][1], width/2,50);
        fill(255,0);
        strokeWeight(6);
        stroke(255,20);
        shape(svgImage[currentConstellationCodeIndex], 0, 0, width, height);
  }

  // Draw Lines
  drawLines();
  
  // Previous and Next buttons 
  stroke(255,100);
  strokeWeight(2);
  if (prevBtn.contains(mouseX, mouseY)) { fill(200); } else { fill(100); }
  rect(prevBtn.x, prevBtn.y, prevBtn.width, prevBtn.height);
  
  if (nextBtn.contains(mouseX, mouseY)) { fill(200); } else { fill(100); }
  rect(nextBtn.x, nextBtn.y, nextBtn.width, nextBtn.height);
  
  if (resetBtn.contains(mouseX, mouseY)) { fill(200); } else { fill(100); }
  rect(resetBtn.x, resetBtn.y, resetBtn.width, resetBtn.height);

  textSize(18);
  fill(0);
  textAlign(LEFT);
  
  text("Next", width-rectSize, height-36);
  text("Previous", rectSize-60, height-36);
  text("Reset", width/2-25, height-36);
  
} //-------------------------------------------------------------------------------- END DRAW()


void addToSeqList(int n, int x, int y, int g) {
  //println("Star idx: "+n+"\t Grp: "+g+"\t X: "+x);
  int group = g;
  int s1 = seq1.size();
  int s2 = seq2.size();
  int s3 = seq3.size();
  int s4 = seq4.size();
  int s5 = seq5.size();
  int seqIndex = 0;
  int grp = group;
  
  n = n+1; // add 1 to the index before adding
  switch(grp) {
      case 1: seqIndex = n; break;
      case 2: seqIndex = n-(s1); break;
      case 3: seqIndex = n-(s1+s2); break;
      case 4: seqIndex = n-(s1+s2+s3); break;
      case 5: seqIndex = n-(s1+s2+s3+s4); break;
    }
  seqIndex = seqIndex-1;
  
  PVector z = new PVector(x,y,1);  
  switch(group) {
    case 1: seq1.set(seqIndex, z); break;
    case 2: seq2.set(seqIndex, z); break;
    case 3: seq3.set(seqIndex, z); break;
    case 4: seq4.set(seqIndex, z); break;
    case 5: seq5.set(seqIndex, z); break;
  }  
}

void drawLines() {
  stroke(colours[currentConstellationCodeIndex]);
  strokeWeight(4);
  noFill();
  constellationStarCounter = 0; // reset and recount
  if (!seq1.isEmpty()) {
    beginShape();
      for (PVector p: seq1) { // Foreach loop
        if (p.z > 0) { 
          vertex(p.x,p.y);
          constellationStarCounter +=1;
        } else {
          endShape();
          beginShape();
        }
      }
    endShape();
  }
  if (!seq2.isEmpty()) {
    beginShape();
      for (PVector p: seq2) { // Foreach loop
        if (p.z > 0) { 
          vertex(p.x,p.y);
          constellationStarCounter +=1;
        } else {
          endShape();
          beginShape();
        }
      }
    endShape();
  }
  if (!seq3.isEmpty()) {
    beginShape();
      for (PVector p: seq3) {
        if (p.z > 0) { 
          vertex(p.x,p.y);
          constellationStarCounter +=1;
        } else {
          endShape();
          beginShape();
        }
      }
    endShape();
  }
  if (!seq4.isEmpty()) {
    beginShape();
      for (PVector p: seq4) {
        if (p.z > 0) { 
          vertex(p.x,p.y);
          constellationStarCounter +=1;
        } else {
          endShape();
          beginShape();
        }
      }
    endShape();
  }
  if (!seq5.isEmpty()) {
    beginShape();
      for (PVector p: seq5) {
        if (p.z > 0) { 
          vertex(p.x,p.y);
          constellationStarCounter +=1;
        } else {
          endShape();
          beginShape();
        }
      }
    endShape();
  }
  
  starCountdown = constellationStarTotal - constellationStarCounter;
  
  //println("constellationStarCounter: "+constellationStarCounter+" and starCountdown is: "+starCountdown);
}

// ----------------------------------------------------------------------- CREATE CONSTELLATION CODES ARRAY

void createConstCodes(Table data, String s) {
  int i = 0; 
  
  //println("CSV: "+data);
  //println(data.getRowCount() + " total rows in table"); 
  
  for (TableRow row : data.rows()) {
    constellationCodeNameList[i][0] = row.getString("CON");
    constellationCodeNameList[i][1] = row.getString("CONNAME");
    constellationCodeNameList[i][2] = row.getString("COLOUR");
    colours[i] =  unhex(constellationCodeNameList[i][2]);  
    
  //println ("ConstCod "+i+": "+constellationCodeNameList[i][0]+" is named: "+constellationCodeNameList[i][1]);
  //println ("And loaded colour: "+constellationCodeNameList[i][2]+" and unhex Colours is: "+colours[i]); 
     
   svgImageFile = constellationCodeNameList[i][1].toLowerCase() + ".svg";  
   
   svgImage[i] = loadShape(svgImageFile);
   svgImage[i].disableStyle();
   
   // Look for # rows in Code file
   i+=1;
  }
}


// ----------------------------------------------------------------------- CREATE CONSTELLATIONS
void createConstellation(Table data, String s) {
  int iStar = 0; 

  for (TableRow tr : data.findRows(s, "CON")) { //Foreach enhanced loop to populate ArrayList w coordinates
    coordList.add(new PVector(tr.getFloat("RA"),tr.getFloat("DEC"),tr.getFloat("MAG")));
    starNameList[iStar][0] = tr.getString("CON");
    starNameList[iStar][1] = tr.getString("NAME");
    //println ("constellation: "+starNameList[iStar][0]+" StarName: "+starNameList[iStar][1]);
    iStar+=1;
  }
  constellationStarTotal = coordList.size();
  //println ("constellationStarTotal is: "+constellationStarTotal);
  // To work out min/max coordinates and magnitude for this constellation
  float[] xPos = new float[coordList.size()];
  float[] yPos = new float[coordList.size()];
  float[] zPos = new float[coordList.size()];
  for(int i = 0; i < coordList.size(); i++) { 
    xPos[i] = coordList.get(i).x;
    yPos[i] = coordList.get(i).y;
    zPos[i] = coordList.get(i).z;
  }
  minMax[0] = min(xPos); minMax[1] = max(xPos);
  minMax[2] = min(yPos); minMax[3] = max(yPos);
  minMax[4] = min(zPos); minMax[5] = max(zPos); //printArray(coordList); printArray(minMax);
  
  // map(); the constellation to screen size
  for(int i = 0; i < coordList.size(); i++) {
    float x = map(coordList.get(i).x, minMax[0], minMax[1], X2, X1);
    float y = map(coordList.get(i).y, minMax[2], minMax[3], Y2, Y1);
    float z = map(coordList.get(i).z, minMax[4], minMax[5], 5, 10);
    PVector p = new PVector(x,y,z);
    coordList.set(i, p);   //println(p);
  }
  
  starGroup = new int[coordList.size()];
  int groupID = 0;
  for (TableRow tr : data.findRows(s, "CON")) {
    starGroup[groupID] = tr.getInt("SEQ");
    groupID++;
  } //printArray(starGroup);
  
  stars = new Star[coordList.size()];   // Initialize all Star objects

  for (int i = 0; i < coordList.size(); i++) {
    float x = round(coordList.get(i).x);
    float y = round(coordList.get(i).y);
    float z = round(coordList.get(i).z);
    int index = i;
    stars[i] = new Star(x,y,z, index, starGroup[i], starNameList[i][1]);
  } //printArray(coordList);
  
  // Seperate constellation sequences for grouping lines together for drawLines();
  for (int i = 0; i < coordList.size(); i++) {
    int x = (int) coordList.get(i).x;
    int y = (int) coordList.get(i).y;
    int g = starGroup[i];
    String n = starNameList[i][0];
    if (g == 1) {
      seq1.add(new PVector(x,y));
    } else if (g == 2) {
      seq2.add(new PVector(x,y));
    } else if (g == 3) {
      seq3.add(new PVector(x,y));
    } else if (g == 4) {
      seq4.add(new PVector(x,y));
    } else if (g == 5) {
      seq5.add(new PVector(x,y));
    }
  }
  //printArray(seq1); printArray(seq2);  printArray(seq3);  printArray(seq4);  printArray(seq5);
}


// ----------------------------------------------------------------------- MOUSE EVENTS

void mouseClicked() {  // called ONCE after every time a mouse button is PRESSED
  if (nextBtn.contains(mouseX,mouseY)) {
    clearStuff();
    if (currentConstellationCodeIndex == (CONST_CODE_NAME_ROWS - 1)) {
      currentConstellationCodeIndex = 0; 
    } else { 
      currentConstellationCodeIndex += 1;
    }
  
    constellationCode = constellationCodeNameList[currentConstellationCodeIndex][0];
    //println ("Next Constelation Code: "+constellationCode);
    createConstellation(table, constellationCode);
  }
  
  if (prevBtn.contains(mouseX,mouseY)) {
    clearStuff();
    if (currentConstellationCodeIndex == 0) {
    currentConstellationCodeIndex = (CONST_CODE_NAME_ROWS - 1);
    } else { 
      currentConstellationCodeIndex -= 1;
    }
    constellationCode = constellationCodeNameList[currentConstellationCodeIndex][0];
    createConstellation(table, constellationCode);
  }
  
  if (resetBtn.contains(mouseX,mouseY)) {
    clearStuff();
    createConstellation(table, constellationCode);
 }   
}

void clearStuff() {  // Empty out arrays and ArrayLists
  coordList.clear(); seqList.clear();
  prevMouse = null; starGroup = null; 
  seq1.clear(); seq2.clear(); seq3.clear(); seq4.clear(); seq5.clear();
}