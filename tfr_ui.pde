import twitter4j.conf.*;
import twitter4j.*;
import twitter4j.auth.*;
import twitter4j.api.*;
import java.util.*;

import http.requests.*;
import rekognition.faces.*;
import processing.video.*;

Twitter twitter;
String searchString = "#AnvilHack";
List<Status> tweets;
StatusUpdate status;

Textbox location = new Textbox("Location",new PVector(800,250),new PVector(200,50),15,3);
Textbox hashtags = new Textbox("Hash Tags",new PVector(800,150),new PVector(200,50),15,3);

String[] cameras = Capture.list();
Capture cam;

String filename = "image.jpg";
File imageFile;
PImage img;
int opacity,recognisedFaces;

boolean pictureTaken = false; //Checks if picture has been taken

Rekognition rekog;
RFace[] faces;
String overAllFace = "";

ArrayList<Integer> missingFaces = new ArrayList<Integer>();
Textbox[] missingFacesText;

ArrayList<PImage> faceImages = new ArrayList<PImage>();
//PImage img2;
PVector img2Pos,img2Size;
int img2Counter;

int i;

String rememberedFaces;
PFont Fbold, FIitalic, Fitalic;

void setup()
{
  Fbold = createFont("Arial Bold", 18);
  Fitalic = createFont("Arial Bold Italic", 70);
  FIitalic = createFont("Arial Italic", 70);
  size(950,430);
  textAlign(CENTER);
  
  ConfigurationBuilder cb = new ConfigurationBuilder();
  cb.setOAuthConsumerKey("jWUIVdtwF5CEaYQxAJuGgmYnO");
  cb.setOAuthConsumerSecret("Beua1Di2UZqLC5r33rYACYjKDt5c8Y9P8CJJUIWKUSMBpdWePg");
  cb.setOAuthAccessToken("2993053133-ehfsp3rlj0BgIT0iY3crxVvOm3vzdD34zdCQ5s9");
  cb.setOAuthAccessTokenSecret("xfE3Zny2yWQlLcFuJBzSHFFDTIJbGHSRaNxBKnlwanCEI");
  
  TwitterFactory tf = new TwitterFactory(cb.build());
  
  twitter = tf.getInstance();
  
  cam = new Capture(this,cameras[3]);
  cam.start();
//  filename = "image.jpg";
//  img = loadImage(filename);
//  imageFile = new File(sketchPath+"/image.jpg");

  // Create the face recognizer object
  rekog = new Rekognition(this, "mHhFaA7fCIcDhJCf", "FMrWr7jBSIfPF1wS");
//    rekog = new Rekognition(this, "35keNhBuWQb4PlJV", "VVWCksRWgCKtbCE4");
//  matches

  // Recognize faces in image
//  faces = rekog.recognize(filename);
    
}

void draw()
{
  background(255);
  if (cam.available() == true) {
    cam.read();
  }
  if(pictureTaken)
  {
    for(int i=0; i<faceImages.size(); i++)
    {
      PImage _img = faceImages.get(i);
      image(_img,faces[i].center.x-faces[i].w/2,faces[i].center.y-faces[i].h/2);
      for(Integer _missingFace : missingFaces)
      {
        missingFacesText[_missingFace].display();
      }
      noFill();
      rect(faces[i].center.x, faces[i].center.y, faces[i].w, faces[i].h);
    }
    
  }
  else
  {
    image(cam,0,0);
  }
  textFont(Fitalic);
  text("#TFR", 700, 10);
  textFont(Fbold);
  text("Space to take picture\n'/' to fill in missing people\n'|' to learn faces and upload",700,300);
  pushMatrix();
  fill(0);
  rect(670,200,10,380);
  popMatrix();
  location.display();
  hashtags.display();
}

void keyPressed()
{
  if(!location.selected && !hashtags.selected && !pictureTaken)
  {
    if(key==' ')
    {
      faceImages = new ArrayList<PImage>();
      missingFaces = new ArrayList<Integer>();
      overAllFace = "";
      filename = "image.jpg";
      cam.save(filename);
      img = loadImage(filename);
      faces = rekog.recognize(filename);
      checkFaces();
      pictureTaken=true;
    }
    if(key=='.')
    {
      println(location.getFinalText());
    }
  }
  else
  {
    location.typed();
    hashtags.typed();
    for(Integer _missingFace : missingFaces)
    {
      missingFacesText[_missingFace].typed();
      if(key==',')
      {
        println(_missingFace,missingFacesText[_missingFace].getFinalText());
      }
    }
  }
  if(key=='/')
  {
    pictureTaken=false;
    teachProgram();
  }
  if(key=='|')
  {
    learnFace();
    imageFile = new File(sketchPath+"/image.jpg");
    if(rememberedFaces!="")
    {
      overAllFace+=". I'll try to remember "+rememberedFaces;
    }
    status = new StatusUpdate(overAllFace+" at "+location.getFinalText()+" "+hashtags.getFinalText());
    status.setMedia(imageFile);
    println(status.getStatus());
    try {
       twitter.updateStatus(status);
    } catch (TwitterException e) {
        System.err.println("Error occurred while updating the status!");
    }
    println("Uploaded");
  }
}

void mousePressed()
{
  location.checkSelected();
  hashtags.checkSelected();
  for(Integer _missingFace : missingFaces)
  {
    missingFacesText[_missingFace].checkSelected();
  }
  
}

void pixelStuff(float faceX, float faceY, float faceSizeX, float faceSizeY)
{
  PImage img2 = new PImage(int(faceSizeX),int(faceSizeY-1));
  img2Counter=0;
  img2 = img.get(int(faceX-faceSizeX/2),int(faceY-faceSizeY/2),int(faceSizeX),int(faceSizeY));
  faceImages.add(img2);
}

void checkFaces()
{
  missingFacesText = new Textbox[faces.length];
  for (int i = 0; i < faces.length; i++) {
    stroke(255, 0, 0);
    strokeWeight(1);
    noFill();
    rectMode(CENTER);

    // Face center, with, and height
    // We could also get eye, mouth, and nose positions like in FaceDetect
    rect(faces[i].center.x, faces[i].center.y, faces[i].w, faces[i].h);  
    println(faces[i].getMatches());

    // Possible face matches come back in a FloatDict
    // A string (name of face) is paired with a float from 0 to 1 (how likely is it that face)
    FloatDict matches = faces[i].getMatches();
    fill(255);
    String display = "";
    
    boolean checked = false; //Boolean to check if it has noted someone
    boolean emotionCheck = false;
    int faceCounter = 0;
    for (String key : matches.keys()) {
      float likely = matches.get(key);
      display += key + ": " + likely + "\n";
      if(likely>0.85)
      {
        overAllFace+=key;
        checked=true;
      }
      else
      {
        faceCounter++;
        if(!checked && faceCounter==matches.size())
        {
          println(i);
          missingFaces.add(i);
          for(int _missingFace : missingFaces)
          {
            missingFacesText[_missingFace] = new Textbox("Who is this?",new PVector(faces[_missingFace].center.x,faces[_missingFace].center.y+faces[_missingFace].h),new PVector(200,25),20,1);
          }
          overAllFace+= "{";
          checked = true;
        }            
      }
      if(checked && !emotionCheck)
      {
        String emotion;
        println(faces[i].smile_rating);
        if(faces[i].smile_rating>=0.8)
        {
          emotion = "happy ";
        }
        else if(faces[i].smile_rating>=0.3 && faces[i].smile_rating<0.8)
        {
          emotion = "neutral ";
        }
        else
        {
          emotion = "sad ";
        }
        overAllFace+=" is "+emotion;
        emotionCheck=true;
        pixelStuff(faces[i].center.x, faces[i].center.y, faces[i].w, faces[i].h);
      }
    }

    // We could also get Age, Gender, Smiling, Glasses, and Eyes Closed data like in the FaceDetect example
    println(display, faces[i].center.x,faces[i].center.y);
    println(overAllFace);
  }
  
  //Checking for blank
  if(faces.length==0)
  {
    overAllFace = "No one is in the picture";
  }
}

void teachProgram()
{
  int[] missFaceIndex = new int[missingFaces.size()];
  int oldIndex = 0;
  for(int i=0; i<missFaceIndex.length; i++)
  {
    missFaceIndex[i] = overAllFace.indexOf('{',oldIndex);
    oldIndex = missFaceIndex[i]+5;
  }
  String[] overAllFacePieces = split(overAllFace,'{');
  overAllFace = "";

  for(int i=missingFaces.size()-1; i>=0; i--)
  {
    Integer _missingFace = missingFaces.get(i);
    overAllFacePieces = splice(overAllFacePieces, missingFacesText[_missingFace].getFinalText(),_missingFace+1);
  }
  for(String _piece : overAllFacePieces)
  {
    overAllFace += _piece;
  }
  println(overAllFace);
}

void learnFace()
{
  rememberedFaces = "";
  for(Integer _missingFace : missingFaces)
  {
    PImage _img = faceImages.get(_missingFace);
    _img.save(missingFacesText[_missingFace].getFinalText()+".jpg");
    rekog.addFace(missingFacesText[_missingFace].getFinalText()+".jpg", trim(missingFacesText[_missingFace].getFinalText()));
    rekog.train();
    rememberedFaces = missingFacesText[_missingFace].getFinalText()+",";
  }
}
