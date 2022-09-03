import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.Serializable;

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


Transform readTransform(String p_fname) throws NullPointerException {
  TransformSer ser = readObject(p_fname);

  if (ser == null)
    return null;

  return new Transform(null, 
    new PVector(ser.data[0], ser.data[1], ser.data[2]), 
    new PVector(ser.data[3], ser.data[4], ser.data[5]), 
    new PVector(ser.data[6], ser.data[7], ser.data[8]));
}

void writeTransform(Transform p_form, String p_fname) {
  writeObject(new TransformSer(p_form), p_fname);
}

static class TransformSer implements Serializable {
  float[] data = new float[9];

  TransformSer(Transform p_form) {
    this.data[0] = p_form.pos.x;
    this.data[1] = p_form.pos.y;
    this.data[2] = p_form.pos.z;

    this.data[3] = p_form.rot.x;
    this.data[4] = p_form.rot.y;
    this.data[5] = p_form.rot.z;

    this.data[6] = p_form.scale.x;
    this.data[7] = p_form.scale.y;
    this.data[8] = p_form.scale.z;
  }
}
