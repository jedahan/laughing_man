import processing.xml.*;
import hypermedia.video.*;

/*

REQUIRES:
OpenCV library for Processing

CHANGELOG:
1/5/09 - Incorporated fixes from Josh, Brett, & Deltadesu: Text now rotates and image scales! Thanks guys!

KNOWN BUGS:
1) Fast movement head movement will lose the head-tracker for a second.
2) Still some flicker issues, but better than it was...
3) Must tinker with OpenCV a bit to get profiles working as well as frontal faces!

No express purpose is intended or implied, use at own risk.

Ben Kurtz
awgh@awgh.org
12/15/08

*/

OpenCV opencv;

// contrast/brightness values
int contrast_value    = 0;
int brightness_value  = 0;

Rectangle[] lastfaces;

PFont font;
String s;
PImage img;
float angle;
PImage p1;
PImage p2;
float n = 1;

void setup() 
{
    size(640,480);
    frameRate( 30 );
    
    smooth();
    stroke(255);
    fill(255);
    
    p1  = loadImage("ltext.png");
    p2  = loadImage("limg.png");
    p1.resize(360,0);
    p2.resize(360,0);
    //I thought what I'd do was, I'd pretend I was one of those deaf-mutes

    opencv = new OpenCV( this );
    opencv.capture( width, height );                   // open video stream
    opencv.cascade( OpenCV.CASCADE_FRONTALFACE_ALT );  // load detection description, here-> front face detection : "haarcascade_frontalface_alt.xml"

    // print usage
    println( "Drag mouse on X-axis inside this sketch window to change contrast" );
    println( "Drag mouse on Y-axis inside this sketch window to change brightness" );

}

public void stop() {
    opencv.stop();
    super.stop();
}

void draw() {
    angle = angle + 0.1;

    try{
      
    // grab a new frame
    // and convert to gray
    opencv.read();
    //opencv.convert( GRAY );
    opencv.contrast( contrast_value );
    opencv.brightness( brightness_value );

    // proceed detection
    Rectangle[] faces = opencv.detect( 1.2, 2, OpenCV.HAAR_DO_CANNY_PRUNING, 40, 40 );

    // display the image
    image( opencv.image(), 0, 0 );

    // to smooth it out
    if( faces.length > 0 ) {
       lastfaces = faces;
    }
    
    if( lastfaces != null ) {
      for( int i=0; i<lastfaces.length; i++ ) {
        pushMatrix();
        translate(lastfaces[i].x+110, lastfaces[i].y+110);  
                
        if( p1 != null && p2 != null )
        {
          imageMode(CENTER);
          rectMode(CENTER);
          
          float scaleFactorW = ((float)lastfaces[i].width / (float)p1.width);
          float scaleFactorH = ((float)lastfaces[i].height / (float)p1.height);
          float scaleFactor = (scaleFactorW > scaleFactorH) ? scaleFactorW : scaleFactorH;
          if( scaleFactor < 0 ) scaleFactor = -scaleFactor;
          scale(scaleFactor * 1.2); 
          
          ellipse(0,0,280,280);
          
          rotate(angle);
          image(p1,0,0);
          
          rotate(-angle);
          image(p2,0,0);
          
          imageMode(CORNER);
          rectMode(CORNER);
        }
        
        popMatrix();
      }
    }
    
    } catch(Exception e) { e.printStackTrace(); }
}


/**
 * Changes contrast/brigthness values
 */
void mouseDragged() {
    contrast_value   = (int) map( mouseX, 0, width, -128, 128 );
    brightness_value = (int) map( mouseY, 0, width, -128, 128 );
}
