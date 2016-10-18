//Zodiac Project Prototype
//TEAM: High Five
//Dom Svejkar (12213551)
//Eva Drewsen (12688824)
//Flora Maurincomme (12684534) 
//Mingzhu CAO (11599798) 
//Sebastien Fambart (11748290)

//created by Mingzhu CAO (11599798) 

import peasy.*;

PeasyCam cam;

Star star;

ArrayList<Constellation>constellations;

PVector[]pts;

import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress myRemoteLocation;

void setup(){
size(1080, 720, P3D);
oscP5 = new OscP5(this,12345);
myRemoteLocation = new NetAddress("127.0.0.1",12346);

  cam=new PeasyCam(this, 400);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(1800);

 star=new Star(new PVector(0, 0, 0), 50, color(random(255), random(255), random(255)), true);
  
  constellations=new ArrayList<Constellation>();
  constellations.add(new Constellation(-450,0,0,100,16,5,6));
  constellations.add(new Constellation(450,-100,200,200,16,5,6));
  constellations.add(new Constellation(50,400,-100,250,16,8,12));
  constellations.add(new Constellation(100,400,-600,300,20,8,12));
  constellations.add(new Constellation(-400,-400,-600,300,20,8,12));
  
  constellations.add(new Constellation(350,100,0,100,2,20,50));
  constellations.add(new Constellation(40,300,-300,100,1,40,50));
  constellations.add(new Constellation(540,-300,100,100,1,40,50));
  
  pts=new PVector[1000];
  for(int i=0;i<pts.length;i++){
    pts[i]=PVector.random3D();
    pts[i].mult(2000);
  }
  
}

void draw() {
  background(0);

  lights();
  star.display();
  
  for(Constellation one:constellations){
    one.display();
    one.drawLines();
  }
  
  stroke(255);
  strokeWeight(1);
  for(int i=0;i<pts.length;i++){
    point(pts[i].x,pts[i].y,pts[i].z);
  }
}

class Constellation {
  float centerx, centery, centerz;
  float range;
  int qty;
  ArrayList<Star>stars;
  float minRadius=5;
  float maxRadius=50;
  
  Constellation(float x,float y,float z,float range,int qty,float minR,float maxR){
    

    this.minRadius=minR;
    this.maxRadius=maxR;
    centerx=x;
    centery=y;
    centerz=z;
    this.range=range;
    this.qty=qty;

    stars=new ArrayList<Star>();

    for (int i=0; i<qty; i++) {
      stars.add(verify());
    }
  }
    

  Constellation(float x, float y, float z, float range, int qty) {
    centerx=x;
    centery=y;
    centerz=z;
    this.range=range;
    this.qty=qty;

    stars=new ArrayList<Star>();

    for (int i=0; i<qty; i++) {
      stars.add(verify());
    }
  }
  
  void display(){
    for(Star one:stars){
      one.display();
    }
  }
  
  void drawLines(){
    for(int i=1;i<stars.size();i++){
      if(stars.get(i).hasHalo)continue;
      for(int j=0;j<i;j++){
        if(stars.get(j).hasHalo)continue;
        if(PVector.dist(stars.get(i).loc,stars.get(j).loc)<50){
          strokeWeight(1);
          stroke(255);
          PVector first=stars.get(i).loc;
          PVector second=stars.get(j).loc;
          line(first.x,first.y,first.z,second.x,second.y,second.z);
        }
      }
    }
  }
  
  void drawLine(){
    pushStyle();
    noFill();
    stroke(255,150);
    strokeWeight(1);
    beginShape();
    for(Star one:stars){
      if(one.hasHalo)continue;
      vertex(one.loc.x,one.loc.y,one.loc.z);
    }
    endShape();
  }
          
  Star verify() {
    Star newOne=generate_star();
    for (Star exist : stars) {
      if (exist.tooClose(newOne)) {
        verify();
        break;
      }
    }
    return newOne;
  }

  Star generate_star() {
    PVector location= new PVector(random(centerx-range, centerx+range), 
      random(centery-range, centery+range), random(centerz-range, centerz+range));
    float radius=random(minRadius, maxRadius);
    boolean hasHalo;
    if (radius>40) {
      hasHalo=true;
    } else {
      hasHalo=false;
    }
    return new Star(location, radius, color(random(255), random(255), random(255)), hasHalo);
  }
}

class Star {
  PVector loc;
  float radius;
  color cl;
  int granularity;

  float rotX=random(PI);
  boolean hasHalo;
  Halo halo;

  Star(PVector loc, float radius, color cl, boolean hasHalo) {
    this.loc=new PVector(loc.x, loc.y, loc.z);
    this.radius=radius;
    this.cl=cl;
    granularity=max(9, int(radius/2));

    if (hasHalo) {
      halo=new Halo(radius*random(1.2,1.5), radius*random(1.6,2.5), cl);
    }
    
    this.hasHalo=hasHalo;
  }

  boolean tooClose(Star other) {
    if (PVector.dist(loc, other.loc)<(radius+other.radius)*2) {
      return true;
    } else {
      return false;
    }
  }

  void display() {
    pushMatrix();
    translate(loc.x, loc.y, loc.z);

    pushStyle();
    fill(cl);
    noStroke();
    sphereDetail(granularity);
    sphere(radius);

    if (hasHalo) {
      rotateX(rotX);
      halo.display();
    }

    popStyle();
    popMatrix();
  }
}


class Halo {
  float inDiam;
  float outDiam;
  PShape ps;
  color cl;
  int granular=36;

  Halo(float inDiam, float outDiam, color cl) {
    this.inDiam=inDiam;
    this.outDiam=outDiam;
    this.cl=cl;

    ps=createShape();
    ps.beginShape(QUAD_STRIP);
    ps.noStroke();
    ps.fill(cl, 180);

    float angle;
    for (int i=0; i<granular; i++) {
      angle=i*TWO_PI/granular;
      ps.vertex(cos(angle)*inDiam, sin(angle)*inDiam);
      ps.vertex(cos(angle)*outDiam, sin(angle)*outDiam);
    }
    ps.vertex(inDiam, 0);
    ps.vertex(outDiam, 0);
    ps.endShape();
  }

  void display() {
    shape(ps, 0, 0);
  }
}
  
  
  
  
  
  
    
void mouseMoved() {
  OscMessage myMessage = new OscMessage("/puredata");
  
  myMessage.add(mouseX);

  oscP5.send(myMessage, myRemoteLocation); 
}

void oscEvent(OscMessage theOscMessage) {
  /* print the address pattern and the typetag of the received OscMessage */
  print("### received an osc message.");
  print(" addrpattern: "+theOscMessage.addrPattern());
  println(" typetag: "+theOscMessage.typetag());
  println(" arguments: " + theOscMessage.get(0).intValue());
  

}