/* ---------- star generation ---------- */

void GenerateStars() {
  // generate random stars
  for(int i = 0; i < STAR_COUNT; i++) {
     stars[i] = 
     new Star(int(random(-width, width)), int(random(-height, height)), int(random(-height, height)), int(random(MIN_STAR_SIZE, MAX_STAR_SIZE)), RANDOM_STAR_NOTE, "", "");
  }
}

void GenerateConstellations() {
       
  Table constellationCodeTable;
  constellationCodeTable = loadTable(constellationCodesCSV, "header"); //"header" captures the name of columns
  
  for (TableRow row : constellationCodeTable.rows()) {
        
    // Get data about constellation
    String conCode = row.getString("CON");
    String conName = row.getString("CONNAME");
    float sizeX = row.getFloat("sizeX");
    float sizeY = row.getFloat("sizeY");
    float posX = row.getFloat("posX");
    float posY = row.getFloat("posY");
    float posZ = random(-CONSTELLATION_Z_AXIS_DEPTH, CONSTELLATION_Z_AXIS_DEPTH);
    
    String svgImageFile = conName.toLowerCase() + ".svg";     
    PShape image = loadShape(svgImageFile);
    image.disableStyle();
        
    // Get data about stars
    Table constellationTable;
    ArrayList<PVector> coordList = new ArrayList<PVector>();
    ArrayList<String> starNames = new ArrayList<String>();
    ArrayList<Integer> notes = new ArrayList<Integer>();
    HashMap<String, ArrayList<String>> starLinks = new HashMap<String, ArrayList<String>>();
      
    constellationTable = loadTable(constellationStarsCSV, "header"); //"header" captures the name of columns
  
    for (TableRow tr : constellationTable.findRows(conCode, "CON")) { // Foreach enhanced loop to populate ArrayList w coordinates
      
      coordList.add(new PVector(tr.getFloat("RA"),tr.getFloat("DEC"),tr.getFloat("MAG")));
      String starName = tr.getString("NAME");
      starNames.add(starName);      
      
      Integer note = tr.getInt("noteNUM");
      notes.add(note);
      
      String linkString = tr.getString("LINKS");
      String[] linkArray = linkString.split("-");      
      ArrayList<String> linkedStars =  new ArrayList<String>();

      for(int indx = 0; indx < linkArray.length; indx++) {
        linkedStars.add(linkArray[indx]);
      }      
      
      starLinks.put(starName, linkedStars);    
      
    }
        
    // To work out min/max coordinates and magnitude for this constellation
    float[] xPos = new float[coordList.size()];
    float[] yPos = new float[coordList.size()];
    float[] zPos = new float[coordList.size()];
    for(int idx = 0; idx < coordList.size(); idx++) { 
      xPos[idx] = coordList.get(idx).x;
      yPos[idx] = coordList.get(idx).y;
      zPos[idx] = coordList.get(idx).z;
    }
    
    float[] minMax = new float[6]; 
    minMax[0] = min(xPos); minMax[1] = max(xPos);
    minMax[2] = min(yPos); minMax[3] = max(yPos);
    minMax[4] = min(zPos); minMax[5] = max(zPos);
    
    if (USE_CSV_POSITIONS) {
      // map the constellations according to values from csv
      for(int index = 0; index < coordList.size(); index++) {
        float x = map(coordList.get(index).x, minMax[0], minMax[1], width*posX+width*sizeX, width*posX);
        float y = map(coordList.get(index).y, minMax[2], minMax[3], height*posY+height*sizeY, height*posY);
        float z = map(coordList.get(index).z, minMax[4], minMax[5], CONSTELLATION_STAR_SIZE_MIN, CONSTELLATION_STAR_SIZE_MAX);
        // let's centre the map
        x = x-width;
        y = y-height;
        PVector p = new PVector(x,y,z);
        coordList.set(index, p);
      }
    }
    else {      
      // map(); the constellation to screen size
      for(int index = 0; index < coordList.size(); index++) {
        float x = map(coordList.get(index).x, minMax[0], minMax[1], width-SCREEN_MARGIN_X, SCREEN_MARGIN_X);
        float y = map(coordList.get(index).y, minMax[2], minMax[3], height-SCREEN_MARGIN_Y, SCREEN_MARGIN_Y);
        float z = map(coordList.get(index).z, minMax[4], minMax[5], CONSTELLATION_STAR_SIZE_MIN, CONSTELLATION_STAR_SIZE_MAX);
        // let's centre the map
        x = x-width/2;
        y = y-height/2;
        PVector p = new PVector(x,y,z);
        coordList.set(index, p);
      }
    }
    
    Star[] conStars = new Star[coordList.size()];    
    
    for(int starIndex = 0; starIndex < coordList.size(); starIndex++) {
      conStars[starIndex] = 
      new Star(coordList.get(starIndex).x, coordList.get(starIndex).y, posZ, coordList.get(starIndex).z, notes.get(starIndex), starNames.get(starIndex), conName);
    }
    
    Constellation t = new Constellation(conName, conStars, starLinks, image);
    constellations.put(conName, t);  
    findImagePosition(t);
  }
}