void ProcessStar(Star star, boolean constellationStar) {
  
  // use different color if star is chosen
    if(star.chosen && star.sizeChanged == false) {
      star.clr = color(255, 255,153);
      star.size = star.size*(100/(100-STAR_TOUCHED_SIZE*100));    
      star.sizeChanged = true;  
    } 
    else {
      star.clr = color(255);
     star.size = star.originalSize;
     star.sizeChanged = false;

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
    
    PVector leftHand = getJointPosition(SimpleOpenNI.SKEL_LEFT_HAND);
    PVector rightHand = getJointPosition(SimpleOpenNI.SKEL_RIGHT_HAND);
    
    // Get screen coordinates for hands
    float lX = screenX(leftHand.x*USER_SCALE_FACTOR+USER_SHIFT_X, leftHand.y*USER_SCALE_FACTOR+USER_SHIFT_Y, 0);
    float lY = screenY(leftHand.x*USER_SCALE_FACTOR+USER_SHIFT_X, leftHand.y*USER_SCALE_FACTOR+USER_SHIFT_Y, 0);
    float rX = screenX(rightHand.x*USER_SCALE_FACTOR+USER_SHIFT_X, rightHand.y*USER_SCALE_FACTOR+USER_SHIFT_Y, 0);
    float rY = screenY(rightHand.x*USER_SCALE_FACTOR+USER_SHIFT_X, rightHand.y*USER_SCALE_FACTOR+USER_SHIFT_Y, 0);
    
    if(((lX >= (x - TOUCH_MARGIN) && lX <= (x + TOUCH_MARGIN)) 
    && (lY >= (y - TOUCH_MARGIN) && lY <= (y + TOUCH_MARGIN)))
    || ((rX >= (x - TOUCH_MARGIN) && rX <= (x + TOUCH_MARGIN)) 
    && (rY >= (y - TOUCH_MARGIN) && rY <= (y + TOUCH_MARGIN)))) {       
      
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
     translate(c.imgPosX, c.imgPosY, c.imgPosZ);
     c.mImgPosX = screenX(0, 0, 0);
     c.mImgPosY = screenY(0, 0, 0);       
     popMatrix();
     
     if((mouseX >= c.mImgPosX && mouseX <= c.mImgPosX+c.cWidth/2 
     && (mouseY >= c.mImgPosY && mouseY <= c.mImgPosY+c.cHeight/2))) {
       PlayFinalMelody obj = new PlayFinalMelody(constellations.get(star.constellationName));
       obj.start();
     }
  }
}