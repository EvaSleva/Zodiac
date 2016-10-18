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
    acc = new Vec3D(random(-0.1, 0.1), random(-0.1, 0.1), random(-0.1, 0.1));     //their acceleration; change accordingly
  }

  void run() {                    //run() contains all the other functions so we just need to call one function in main draw loop
    update();
    display();
  }

  void update() {              //Movement
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

  void display() {          //Looks/style    
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

  void grow() {
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

