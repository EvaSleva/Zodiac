import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import oscP5.*; 
import netP5.*; 
import toxi.geom.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class zodiac6_hmm extends PApplet {

//a short explanation of this prototype...the processing sketch runs an array of 'stars' from the star class, creating a 'starfield' which the camera slowly rotates around. the star class creates spheres run through vec3D vectors randomly generated and displayed. they have a velocity and acceleration for fun purposes, but can be turned off by greying out the update function in run() to remain stationary. As a placeholder for the kinect camera/movement, a temporary mouse vector has been inserted to mimic some of the interaction one would have with the stars. because there is no Z-axis equivalent to mouseX and mouseY functions, it is set to 0 in the vector, and so limits the effectiveness and fun of the mouse movement (however this should not be a problem once the kinect is installed. when the mouse is in the vicinity (the sensitivity of this distance can and will be changed later on) of a star, it will double in size and change colour, and send signal to pure data to create sound.

//to do...maybe make sounds everytime a link is made between stars...
//modulo on framerate...?

      //oscp5 library


                //for vector physics

float bounds=5000;        //bounds of starfield...
int numstars = 200;    //number of stars

float noff;              //for some perlin noise in stars alpha

float camdistance = 3000;

ArrayList starz;           //arraylist for the stars    

int sendport = 6002;
int receiveport = 6003;
OscP5 oscP5;
NetAddress myRemoteLocation;

Timer timer;

public void setup() {
  size(displayWidth, displayHeight, P3D);
  smooth();
  //noCursor();
  oscP5 = new OscP5(this, sendport);
  oscP5.plug(this, "push", "/sep");
  oscP5.plug(this, "pullz", "/pullz");
  oscP5.plug(this, "alignz", "/alignz");
  oscP5.plug(this, "radiuz", "/rad");

  myRemoteLocation = new NetAddress("127.0.0.1", receiveport);

  starz = new ArrayList();    //declare arraylist

    for (int i=0; i<numstars; i++) {
    Star star = new Star();
    starz.add(star);          //for every star, add a new star to the list of our class
  }

  timer = new Timer(5000);

  background(0);
}

public void draw() {
  background(0);

  float x = cos(0.005f*frameCount) * camdistance;        //camera movement
  float y = -camdistance/2;
  float z = sin(0.005f*frameCount) * camdistance;
  camera(x, y, z, 0, 0, 0, 0, 1, 0);

  pushStyle();
  noFill();
  stroke(255);
  sphere(100);
  box(bounds);        //temporary bounding box
  popStyle();
  lights();            //give a bit of shadow, maybe not needed...

  for (int i=0; i<starz.size (); i++) {
    Star str = (Star) starz.get(i);
    str.run();                      //access each star in the arraylist and execute all the actions in run()
  }
}


/*
OscMessage myMessage = new OscMessage("/test");
 
 myMessage.add(123); // add an int to the osc message 
 
 // send the message 
 oscP5.send(myMessage, myRemoteLocation); 
 */
class Star {

  Vec3D loc;                        //vectors for position, velocity, accleleration
  Vec3D vel;
  Vec3D acc;
  Vec3D mouse;

  float lineDist = 500;             //change this accordingly; distance for line to kick in

  float radius = random(30);        //sizes of the stars

  int startTime;
  int trigger = 0;
  int count = 10;                   //interval for ball to stay 'active'
  int interval = 1000;      
  float grow = 1;                  //change size of star when hit
  boolean sizechange = false;

  Star() {

    loc = new Vec3D(random(-bounds/2, bounds/2), random(-bounds/2, bounds/2), random(-bounds/2, bounds/2));        //x,y,z position of each star randomly generated
    vel = new Vec3D(random(-5, 5), random(-5, 5), random(-5, 5));                                              //their speed; change accordingly
    acc = new Vec3D(random(-0.1f, 0.1f), random(-0.1f, 0.1f), random(-0.1f, 0.1f));     //their acceleration; change accordingly
  }

  public void run() {                    //run() contains all the other functions so we just need to call one function in main draw loop
    update();
    display();
  }

  public void update() {              //Movement
    vel.addSelf(acc);          //velocity is affected by acceleration
    vel.limit(5);              //maximum velocity

    loc.addSelf(vel);          //and in turn the position is affected by velocity AND acceleration

    acc.clear();              //resets acceleration to zero so it doesnt runaway

    //IF reaching the limits of BOUNDS, flip the other way
    if (loc.x>(bounds/2-radius) || loc.x<(-bounds/2+radius)) {
      vel.x *=-1;
    }
    if (loc.y>(bounds/2-radius) || loc.y<(-bounds/2+radius)) {
      vel.y *=-1;
    }
    if (loc.z>(bounds/2-radius) || loc.z<(-bounds/2+radius)) {
      vel.z *=-1;
    }
  }

  public void display() {          //Looks/style    
    grow();

    mouse = new Vec3D(mouseX, mouseY, 0);      //mouse vector. replace with kinect parts later
    pushMatrix();
    pushStyle(); 
    noStroke();
    fill(0, 0, 255);
    translate(mouse.x, mouse.y, mouse.z);
    sphere(100);                        //draw the mouse location sphere
    popStyle();
    popMatrix();

    float distance = mouse.distanceTo(loc);            //calc distance from mouse to any other star

    if (distance < lineDist) {          //if stars are less than the lineDist 
      sizechange = true;
          OscMessage myMessage = new OscMessage("/ding");
          myMessage.add(distance); // add an int to the osc message 
          // send the message 
          oscP5.send(myMessage, myRemoteLocation);
      
      stroke(0,0,255);
      line(loc.x, loc.y, loc.z, mouse.x, mouse.y, mouse.z);    //remove this later on...
      
          if (sizechange == true) {
      for (int i=0; i< starz.size (); i++) {
        Star other = (Star) starz.get(i);          //call all other stars within...theres got to be a more efficient memory way of doing this...
        float newStarDist = mouse.distanceTo(other.loc);
        if (newStarDist < lineDist) {
          stroke(255);
          line(loc.x, loc.y, loc.z, other.loc.x, other.loc.y, other.loc.z);             //star creates a line between it and any other line that is within touching distance
          float starToStar = loc.distanceTo(other.loc);
         /* 
         myMessage = new OscMessage("/extrading");
          myMessage.add(1); // add an int to the osc message 
          // send the message 
          oscP5.send(myMessage, myRemoteLocation);
         */
        }
      }
    }
      
    } else {
      fill(255, 255, 255);            //white stars, a little bit of noise to make them twinkle?
      sizechange = false;
    }

    pushMatrix();
    pushStyle(); 
    noStroke();
    translate(loc.x, loc.y, loc.z);
    sphere(radius*grow);                        //draw the sphere
    popStyle();
    popMatrix();
  }

  public void grow() {
    //put sizechange AND counter in here?
    if (sizechange == false) {
      grow = 1;
    } 
    if (sizechange == true) {
      timer.start();                                        //timer doesn't seem to be working properly
      grow = 2;
      fill(255, 0, 0);            //white stars turn Red

      if (timer.isFinished()) {
        sizechange = false;
      }
    }
  }
}

//timer class adapted from code by 'zombience' on processing forums: https://forum.processing.org/one/topic/timer-call-reset.html

class Timer { 
  int savedTime; // When Timer started
  int totalTime; // How long Timer should last

  Timer(int _TotalTime) {
    totalTime = _TotalTime;
  }

  // Starting the timer
  public void start() {
    // When the timer starts it stores the current time in milliseconds.
    savedTime = millis(); 
    //println("timer start at" + savedTime);
  }


  // The function isFinished() returns true if 5,000 ms have passed. 
  // The work of the timer is farmed out to this method.
  public boolean isFinished() { 
    // Check how much time has passed
    int passedTime = millis()- savedTime;
    println(passedTime);
    if (passedTime > totalTime) {
      return true;
    } else {
      return false;
    }
  }
}

  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "--full-screen", "--bgcolor=#666666", "--stop-color=#cccccc", "zodiac6_hmm" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
