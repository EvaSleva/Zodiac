void constellation2(){
    
  // detect if mouse is on control/anchor point
  if (((dist(mouseX, mouseY, cy[0].x, cy[0].y) < 20)) && (mousePressed)) {
    val0 = true;
  } 
  else if(((dist(mouseX, mouseY, cy[1].x, cy[1].y) < 20)) && (mousePressed)){
    val1 = true; 
  }
  else if(((dist(mouseX, mouseY, cy[2].x, cy[2].y) < 20)) && (mousePressed)){
    val2 = true;
  }
  else if (((dist(mouseX, mouseY, cy[3].x, cy[3].y) < 20)) && (mousePressed)){
    val3 = true;
  }
  else if (((dist(mouseX, mouseY, cy[4].x, cy[4].y) < 20)) && (mousePressed)){
    val4 = true;
  }
  else if (((dist(mouseX, mouseY, cy[5].x, cy[5].y) < 20)) && (mousePressed)){
    val5 = true;
  }
  else if (((dist(mouseX, mouseY, cy[6].x, cy[6].y) < 20)) && (mousePressed)){
    val6 = true;
  }
  
  
  if(!mousePressed){
        val0 = val1 = val2 = val3 = val4 = val5 = val6 = false;
  }
 
  // Change the radius of the star
  if (val0) {
    cy[0].radius = 7; 
  } 
  else if (val1) {
    cy[1].radius = 7;
  } 
  else if (val2) {
   cy[2].radius = 7;
  }
  else if (val3) {
   cy[3].radius = 7;
  }
  else if (val4) {
   cy[4].radius = 7;
  }
  else if (val5) {
   cy[5].radius = 7;
  }
   else if (val6) {
   cy[6].radius = 7;
  }
  
  // Constellation completed -> Display of name
  if( (cy[0].radius == 7) && (cy[1].radius == 7) && (cy[2].radius == 7) && (cy[3].radius == 7) && (cy[4].radius == 7) && (cy[5].radius == 7) && (cy[6].radius == 7)){
     image(Cygnus, 170, 650, 63, 15);
  }
  
}