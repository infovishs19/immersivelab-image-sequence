import oscP5.*;
import netP5.*;
////import codeanticode.syphon.*;
import spout.*;
import java.util.Collections;  

OscP5 oscCom;
PGraphics canvas;

// Configuration
String sketchName = "IL_basic_example";
int oscReceivePort = 12000;
int trackingMode = 0; // 0: touch points, 1: clusters
////String audioFilePath = "/Users/dbisig/Projects/ImmersiveLab/Agora_2017-2019/teaching/Mapping_2019/Software/ExampleCode/Processing/IL_basic_complete_audio/audio";
String audioFilePath = "C:/Users/il/Desktop/ImmersiveLab/Mapping_2019/Example_Code/Processing/IL_basic_example/audio";

Boolean loaded = false;

ArrayList<String> images = new ArrayList<String>();
ArrayList<PImage> actualImages = new ArrayList<PImage>();

int imageIndex = 0;
PImage current = null;

// Processing Standard Functions
void settings() 
{
  size(1280, 180, P3D);
  PJOGL.profile=1;
}

void setup()
{
  frameRate(60);

  setupCommunication();
  ////setupTracking();
  setupVideoMapping();
  ////setupAudio();
  ////setupContent();

  //===content
  //load images
  String path = sketchPath();
  String imagePath = path + "/img";
  println(imagePath);

  println("Listing all filenames in a directory: ");
  String[] filenames = listFileNames(imagePath);
  printArray(filenames);

  for (int i=0; i<filenames.length; i++) {

    if ( filenames[i].equals(".DS_Store")) {
      continue;
    }
    String filePath = imagePath + "/" + filenames[i];
    println("adding  " + filePath);
    images.add(filePath);
  }
  Collections.sort(images);  
  println("image paths");
  println(images);
  println("loading actual images");
  thread("loadFiles");
}

synchronized void draw()
{ 
  canvas.beginDraw();
  canvas.noStroke();
  canvas.background(255);

  ////udpateContent();
  ////drawContent();

  if (loaded) 
  {
    canvas.image(current, 0, 0);
    imageIndex++;
    if (imageIndex>actualImages.size()-1) {
      imageIndex = 0;
    }
    current = actualImages.get(imageIndex);
  } else
  {
    canvas.background(255, 0, 0);
  }

  canvas.endDraw();
  mappingControl.update(canvas);
  image(canvas, 0, 0, width, height);
}

// OSC Communication
void 
  setupCommunication()
{
  oscCom = new OscP5(this, oscReceivePort);
}

void oscEvent(OscMessage oscMessage) 
{ 
  String oscAddress = oscMessage.addrPattern();

  if ( oscAddress.equals("/tuio/2Dcur") )
  {
    trackingControl.update(oscMessage);

    if (trackingControl.updated == true)
    {
      updateContent(trackingControl.touchPoints);
    }
  }
}


void loadPath(int index) {
  String path = images.get(imageIndex);
  println("loading "  + path);
  println("duh");
  current = loadImage(path);

  println("done");
}


// This function returns all the files in a directory as an array of Strings  
String[] listFileNames(String dir) {
  File file = new File(dir);
  if (file.isDirectory()) {
    String names[] = file.list();
    return names;
  } else {
    // If it's not a directory
    return null;
  }
}

void loadFiles() {

  println("loadFiles");
  actualImages = new ArrayList<PImage>();
  for (int i=0; i<images.size(); i++) {
    String thePath = images.get(i);
    println("loading " + thePath);
    PImage img = loadImage(thePath);
    actualImages.add(img);
  }
  current = actualImages.get(0);
  println("loading images done");

  synchronized (loaded) 
  { 
    loaded = true;
  }
}
