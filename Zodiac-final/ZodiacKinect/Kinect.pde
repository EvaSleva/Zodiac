void drawCurveFigure() {

  pushMatrix();
  pushStyle();
  stroke(254, 201, 200);
  strokeWeight(3);
  fill(255, 20, 20);
  drawCircle(getJointPosition(SimpleOpenNI.SKEL_LEFT_HAND));
  drawCircle(getJointPosition(SimpleOpenNI.SKEL_RIGHT_HAND));
  noFill();

  beginShape();
  plotCurveVertexAtJointPosition(SimpleOpenNI.SKEL_HEAD);
  plotCurveVertexAtJointPosition(SimpleOpenNI.SKEL_HEAD);
  plotCurveVertexAtJointPosition(SimpleOpenNI.SKEL_NECK);
  plotCurveVertexAtJointPosition(SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  plotCurveVertexAtJointPosition(SimpleOpenNI.SKEL_RIGHT_ELBOW);
  plotCurveVertexAtJointPosition(SimpleOpenNI.SKEL_RIGHT_HAND);
  plotCurveVertexAtJointPosition(SimpleOpenNI.SKEL_RIGHT_HAND);
  endShape();

  beginShape();
  plotCurveVertexAtJointPosition(SimpleOpenNI.SKEL_HEAD);
  plotCurveVertexAtJointPosition(SimpleOpenNI.SKEL_HEAD);
  plotCurveVertexAtJointPosition(SimpleOpenNI.SKEL_NECK);
  plotCurveVertexAtJointPosition(SimpleOpenNI.SKEL_LEFT_SHOULDER);
  plotCurveVertexAtJointPosition(SimpleOpenNI.SKEL_LEFT_ELBOW);
  plotCurveVertexAtJointPosition(SimpleOpenNI.SKEL_LEFT_HAND);
  plotCurveVertexAtJointPosition(SimpleOpenNI.SKEL_LEFT_HAND);
  endShape();

  beginShape();
  plotCurveVertexAtJointPosition(SimpleOpenNI.SKEL_NECK);
  plotCurveVertexAtJointPosition(SimpleOpenNI.SKEL_NECK);
  plotCurveVertexAtJointPosition(SimpleOpenNI.SKEL_TORSO);
  plotCurveVertexAtJointPosition(SimpleOpenNI.SKEL_LEFT_HIP);
  plotCurveVertexAtJointPosition(SimpleOpenNI.SKEL_LEFT_KNEE);
  plotCurveVertexAtJointPosition(SimpleOpenNI.SKEL_LEFT_FOOT);
  plotCurveVertexAtJointPosition(SimpleOpenNI.SKEL_LEFT_FOOT);
  endShape();

  beginShape();
  plotCurveVertexAtJointPosition(SimpleOpenNI.SKEL_NECK);
  plotCurveVertexAtJointPosition(SimpleOpenNI.SKEL_NECK);
  plotCurveVertexAtJointPosition(SimpleOpenNI.SKEL_TORSO);
  plotCurveVertexAtJointPosition(SimpleOpenNI.SKEL_RIGHT_HIP);
  plotCurveVertexAtJointPosition(SimpleOpenNI.SKEL_RIGHT_KNEE);
  plotCurveVertexAtJointPosition(SimpleOpenNI.SKEL_RIGHT_FOOT);
  plotCurveVertexAtJointPosition(SimpleOpenNI.SKEL_RIGHT_FOOT);
  endShape();

  noStroke();
  popMatrix();
  popStyle();
}

void plotCurveVertexAtJointPosition(int joint) {
  PVector jointPositionRealWorld = new PVector();
  PVector jointPositionProjective = new PVector();
  context.getJointPositionSkeleton(1, joint, jointPositionRealWorld);
  context.convertRealWorldToProjective(jointPositionRealWorld, jointPositionProjective);

  curveVertex(jointPositionProjective.x*USER_SCALE_FACTOR+USER_SHIFT_X, jointPositionProjective.y*USER_SCALE_FACTOR+USER_SHIFT_Y);
}

PVector getJointPosition(int joint) {
  PVector jointPositionRealWorld = new PVector();
  PVector jointPositionProjective = new PVector();
  context.getJointPositionSkeleton(1, joint, jointPositionRealWorld);
  context.convertRealWorldToProjective(jointPositionRealWorld, jointPositionProjective);

  return jointPositionProjective;
}

void drawCircle(PVector position) {
  pushMatrix();
  translate(position.x*USER_SCALE_FACTOR+USER_SHIFT_X, position.y*USER_SCALE_FACTOR+USER_SHIFT_Y);
  ellipse(0, 0, 40, 40);
  popMatrix();
}

// -----------------------------------------------------------------
// SimpleOpenNI events

void onNewUser(SimpleOpenNI curContext, int userId)
{
  println("onNewUser - userId: " + userId);
  println("\tstart tracking skeleton");

  curContext.startTrackingSkeleton(userId);
}

void onLostUser(SimpleOpenNI curContext, int userId)
{
  println("onLostUser - userId: " + userId);
}

void onVisibleUser(SimpleOpenNI curContext, int userId)
{
  //println("onVisibleUser - userId: " + userId);
}