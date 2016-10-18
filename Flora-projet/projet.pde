import ddf.minim.*;

AudioInput in;
AudioPlayer song;

// VARIABLES DECLARATION
boolean ok0, ok1, ok2, ok3, ok4, ok5, ok6 ;
boolean val0, val1, val2, val3, val4, val5, val6;
float radius = 3;
star [] hello;
int N = 70; // number of random stars
star[] bye;
star[] cy;
PImage LittleDipper;
PImage Cygnus;
Minim minim_son;


void setup() {
  size(1000, 700);
  smooth();
  
  minim_son = new Minim(this);
  song = minim_son.loadFile("sounds/son1.wav", 1024);
  song.play();
  
  hello = new star[N]; // Creation of random stars
  for (int i=0;i<N;i++){
    hello[i] = new star();
  }
  
  bye = new star[7];
  cy = new star[7];
  
    // LITTLE DIPPER CREATION
    bye[0] = new star(590, 280);
    bye[1] = new star(640,270);
    bye[2] = new star(605, 330);
    bye[3] = new star(655,320);
    bye[4] = new star(685,330);
    bye[5] = new star(720,360);
    bye[6] = new star(750,400);
    
    //CYGNUS CREATION
    cy[0] = new star(200, 680);
    cy[1] = new star(180, 620);
    cy[2] = new star(160, 560);
    cy[3] = new star(140, 500);
    cy[4] = new star(124, 440);
    cy[5] = new star(110, 657);
    cy[6] = new star(250, 605);
    
    LittleDipper = loadImage("images/LD.png");
    Cygnus = loadImage("images/CY.png");
}

void draw(){
   background(0);
   fill(255);
   for(int i=0; i<N;i++){ // Display random stars
    hello[i].display();
   }
   
   for(int j=0;j<7;j++){ // Display Little Dipper
     bye[j].display();
   } 
   
   for(int k=0;k<7;k++){ // Display Cygnus
    cy[k].display();   
   }
   
constellation1(); 
constellation2();
   
}