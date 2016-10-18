//a short explanation of this prototype...the processing sketch runs an array of 'stars' from the star class, creating a 'starfield' which the camera slowly rotates around. the star class creates spheres run through vec3D vectors randomly generated and displayed. they have a velocity and acceleration for fun purposes, but can be turned off by greying out the update function in run() to remain stationary. As a placeholder for the kinect camera/movement, a temporary mouse vector has been inserted to mimic some of the interaction one would have with the stars. because there is no Z-axis equivalent to mouseX and mouseY functions, it is set to 0 in the vector, and so limits the effectiveness and fun of the mouse movement (however this should not be a problem once the kinect is installed. when the mouse is in the vicinity (the sensitivity of this distance can and will be changed later on) of a star, it will double in size and change colour, and send signal to pure data to create sound.

//to do...maybe make sounds everytime a link is made between stars...
//modulo on framerate...?

import oscP5.*;      //oscp5 library
import netP5.*;

import toxi.geom.*;                //for vector physics

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

void setup() {
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

void draw() {
  background(0);

  float x = cos(0.005*frameCount) * camdistance;        //camera movement
  float y = -camdistance/2;
  float z = sin(0.005*frameCount) * camdistance;
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
