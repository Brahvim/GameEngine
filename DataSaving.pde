import java.io.*;

//import java.util.Enumeration;
//import java.util.Scanner;
// Are we zippin'?
//import java.util.zip.*;
//
// ...we ain't zippin'.


File savesFolder;
String savesFolderPath = null;

// Every part of this should be very scalable.

// The plan of action:
// Just create a system that allows one to save and load objects.
//
// Put them into a folder, `saves`, at runtime, (which also has a README file alerting
// users to NOT mess around with the files).
//
// PS the logs could be put in `temp` on Windows (`C:\\Windows\\Temp`).
// (On GNU/Linux, `/tmp` or `/var/tmp`. ...and who'd like to read the Apple T&Cs daily?)
//
// *Very* easy, and efficient enough (e.g. if the user wants to load a specific object,
// you will have to traverse through the entire file to find it, then ever parse its
// 'header' to know how many bytes it is with your custom parser an so on.
// How else would you design a parser?
//
// ...zipping handles that much faster than we ever could.)


void initSaving() {
  savesFolder = new File(sketchPath("saves"));
  savesFolderPath = savesFolder.getAbsolutePath();

  if (!savesFolder.exists())
    savesFolder.mkdir();

  //writeObject(null.new Transform.a(), "cake"); 
  //println(((Transform.a)readObject("cake")).word);
}

//static class TestData implements Serializable {
//  private final static long serialVersionUID = 390743L;
//  String word = "Caaaaaake!";
//}

void writeObject(Serializable p_object, String p_fname) {
  File objFile = new File(savesFolder, p_fname.concat(".sav_frag"));

  try {
    if (!objFile.exists())
      objFile.createNewFile();
  }
  catch (IOException e) {
    logEx(e);
  }

  try {
    FileOutputStream fout = new FileOutputStream(objFile);
    ObjectOutputStream oStream = new ObjectOutputStream(fout);

    oStream.writeObject(p_object);

    oStream.close();
    fout.close();
  }
  catch (FileNotFoundException e) {
    logEx(e);
  }
  catch (IOException e) {
    logEx(e);
  }
}

<T> T readObject(String p_fname) {
  T ret = null;
  File objFile = new File(savesFolder, p_fname.concat(".sav_frag"));

  try {
    FileInputStream fin = new FileInputStream(objFile);
    ObjectInputStream oStream = new ObjectInputStream(fin);

    try { 
      ret = (T)oStream.readObject();
    }
    catch(ClassNotFoundException e) {
      logEx(e);
    }
    finally {
      oStream.close();
      fin.close();
    }
    return ret;
  } 
  catch (FileNotFoundException e) {
    logEx(e);
    return null;
  }
  catch (IOException e) {
    logEx(e);
    return null;
  }
}


class VectorSerializer implements Serializable {
  float[] data = new float[3];

  VectorSerializer(PVector p_vec) {
    this.data[0] = p_vec.x;
    this.data[1] = p_vec.y;
    this.data[2] = p_vec.z;
  }

  VectorSerializer(Vector3f p_vec) {
    this.data[0] = p_vec.x;
    this.data[1] = p_vec.y;
    this.data[2] = p_vec.z;
  }
}


// Should probably just use `Integer` instead:
/*
class ColorSerializer implements Serializable {
 float[] data = new float[4];
 
 ColorSerializer(color p_color) {
 this.data[0] = p_color >> 16 & 0xFF;
 this.data[1] = p_color & 0xFF;
 this.data[2] = p_color >> 8 & 0xFF;
 }
 
 ColorSerializer(float p_red, float p_green, float p_blue, float p_alpha) {
 }
 }
 */
