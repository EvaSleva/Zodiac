void constellation1 (){
    
  // detect if mouse is on control/anchor point
  if (((dist(mouseX, mouseY, bye[0].x, bye[0].y) < 20)) && (mousePressed)) {
    ok0 = true;
  } 
  else if(((dist(mouseX, mouseY, bye[1].x, bye[1].y) < 20)) && (mousePressed)){
    ok1 = true; 
  }
  else if(((dist(mouseX, mouseY, bye[2].x, bye[2].y) < 20)) && (mousePressed)){
    ok2 = true;
  }
  else if (((dist(mouseX, mouseY, bye[3].x, bye[3].y) < 20)) && (mousePressed)){
    ok3 = true;
  }
  else if (((dist(mouseX, mouseY, bye[4].x, bye[4].y) < 20)) && (mousePressed)){
    ok4 = true;
  }
  else if (((dist(mouseX, mouseY, bye[5].x, bye[5].y) < 20)) && (mousePressed)){
    ok5 = true;
  }
  else if (((dist(mouseX, mouseY, bye[6].x, bye[6].y) < 20)) && (mousePressed)){
    ok6 = true;
  }
  
  
  if(!mousePressed){
        ok0 = ok1 = ok2 = ok3 = ok4 = ok5 = ok6 = false;
  }
 
  // Change the radius of the star
  if (ok0) {
    bye[0].radius = 7; 
  } 
  else if (ok1) {
    bye[1].radius = 7;
  } 
  else if (ok2) {
   bye[2].radius = 7;
  }
  else if (ok3) {
   bye[3].radius = 7;
  }
  else if (ok4) {
   bye[4].radius = 7;
  }
  else if (ok5) {
   bye[5].radius = 7;
  }
   else if (ok6) {
   bye[6].radius = 7;
  }
  
  // Constellation completed -> Display of name
  if( (bye[0].radius == 7) && (bye[1].radius == 7) && (bye[2].radius == 7) && (bye[3].radius == 7) && (bye[4].radius == 7) && (bye[5].radius == 7) && (bye[6].radius == 7)){
     image(LittleDipper, 570, 295, 97, 16); 
  }
  
}