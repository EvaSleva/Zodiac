void ProcessStar(Star star, boolean constellationStar) {
  
  // use different color if star is chosen
    if(star.chosen) {
      star.clr = color(255, 255, 102); 
    } 
    else {
      star.clr = color(255); 
    }    
  
    pushMatrix();
    translate(star.x, star.y, star.z);
    
    // draw star
    fill(star.clr);
    sphere(star.size);    
    fill(255);
    
    // find actual screen coordinates 
    float x = screenX(0, 0, 0);
    float y = screenY(0, 0, 0);
    
    // save the model coordinates on the star
    star.pX = modelX(0, 0, 0);
    star.pY = modelY(0, 0, 0);
    star.pZ = modelZ(0, 0, 0);
    
    popMatrix();    
    
    // check if mouse touches star
    if((mouseX >= (x - TOUCH_MARGIN) && mouseX <= (x + TOUCH_MARGIN)) && (mouseY >= (y - TOUCH_MARGIN) && mouseY <= (y + TOUCH_MARGIN))) {
      
      // set to chosen star
      if(previousStar != null) {
        previousStar.chosen = false;
      }
      star.chosen = true;
        
      // add a line if there should be one
      if(constellationStar) {       
        if(previousStar != null 
        && previousStar.constellationName == star.constellationName 
        && CheckStarMapping(star, previousStar, constellations.get(star.constellationName))) {
          AddLine(previousStar, star, constellations.get(star.constellationName));          
        }    
        // otherwise just draw a line and don't save it
        else if (previousStar != null) {
          DrawLine(new Line(previousStar.pX, previousStar.pY, previousStar.pZ, star.pX, star.pY, star.pZ));
        }
      }
      else {        
        if(previousStar != null) {
          DrawLine(new Line(previousStar.pX, previousStar.pY, previousStar.pZ, star.pX, star.pY, star.pZ));
        }
      }
      
      previousStar = star;
      
      // play star sound only once
      if(!star.soundPlayed) {
        PlaySound(star.sound);
        star.soundPlayed = true;
      }
  }
  else {
    star.soundPlayed = false;
  }     
  
  // check if constellation is done and mouse is clicked on the constellation, then play the melody (position not working properly in 3D)
  if(constellationStar && mousePressed && constellations.get(star.constellationName).complete) {
     Constellation c = constellations.get(star.constellationName); 
     
     pushMatrix();
     translate(c.imgPosX, c.imgPosY, 0);
     c.mImgPosX = screenX(0, 0, 0);
     c.mImgPosY = screenY(0, 0, 0);       
     popMatrix();
     
     if((mouseX >= c.mImgPosX && mouseX <= c.mImgPosX+c.cWidth/2 && (mouseY >= c.mImgPosY && mouseY <= c.mImgPosY+c.cHeight/2))) {
       PlayFinalMelody obj = new PlayFinalMelody(constellations.get(star.constellationName));
       obj.start();
     }
  }
}