class star{
  float x;
  float y;
  int radius;
  
  star() { // Constructor
  x = random(0, width);
  y = random(0, height);
  radius = 3;
  }

  star(float x, float y){ // Constructor with parameters
  this.x = x;
  this.y = y;
  radius = 3;
}

void display() {
    noStroke();
    ellipse(x, y, radius*2, radius*2); // Simple drawing...
  } 
}