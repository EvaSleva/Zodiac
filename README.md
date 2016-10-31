# ZODIAC

## UTS 32027 Interactive Media (2016 Spring)

YouTube Demo: https://youtu.be/x9tJvQMzi6g

### 1. TEAM: High Five
    - Dom Svejkar (12213551)
    - Eva Drewsen (12688824)
    - Flora Maurincomme (12684534)
    - Mingzhu CAO (11599798)
    - Sebastien Fambart (11748290)

### 2. IDEA Description

The Zodiac App will offer a 3D dark sky environment that will present the user with one or more of the 12 main Zodiac constellations. The user is geographically located in the centre of the interface where only a viewport section of the sky is visible at any one time. The user will interact by touching stars to connect them in the correct fashion to join into a single constellation, and once completed the associated Zodiac sign illustration is displayed. Background ambient music and sound effects will be used for each correct star sequence connection and chords played once it is complete.

### 3. SETUP INSTRUCTIONS

* Requirements
    - Microsoft Kinect device version 1 (1414) 
    - Processing software version 2.2.1 (to use SimpleOpenNI-1.96)
    - Pure Data software (Pd-Extended 0.43.4)
* Processing Libraries
    - oscP5 | An Open Sound Control (OSC) 
    - SimpleOpenNI version 1.96
* Kinect version
    - Open Pure Data sketch and turn up volume in sketch.
    - Open Processing sketch in Processing 2.
    - Stand in front of Kinect and wait until it registers the user.
    - Use hands to touch stars. Connect stars to form a constellation.
    - The final melody is composed from the order in which you selected the stars.
    - When constellation is solved, wait 10 seconds until the next appears.
    - If a keyboard is present, it is also possible to press Enter and ’s’ to skip or solve.
* Mouse version
    - Open Pure Data sketch and turn up volume in sketch.
    - Open Processing sketch. (Looks better in Processing 3)
    - Use mouse to touch stars. Connect the stars to form a constellation.
    - Click the solved constellation to play back melody.
    - Press 'Enter' to go to next constellations.
    - Press 's' to solve constellations automatically.


### 4. REFERENCES

* Star charts (RA/DEC/MAG) from The Department of Physics and Astronomy at Stephen F. Austin State University: http://www.midnightkite.com/index.aspx?AID=0&URL=StarChartFAQ
* RA/DEC/MAG CSV data (http://observe.phy.sfasu.edu/SFAStarCharts/ExcelCharts/ConstellationLinesAll2002.xls) that contains:
    - Zodiac codename
    - Magnitude
    - Converted RA/DEC coordinates (https://en.wikipedia.org/wiki/Right_ascension | https://en.wikipedia.org/wiki/Declination) 
* Background Image: http://www.samsung.com/global/galaxy/galaxy-tab-s2/images/galaxy-tab-s2_feature_your-pick.jpg
* Zodiac Vectors for SVGs illustrations: http://www.freevectors.net/details/Zodiac
* Background sound by Sonicfreak on freesound.org: http://freesound.org/people/Sonicfreak/sounds/174450/
* Stick figure style inspired by Andrew Johnston’s lecture Sketch on Kinect usage.





















