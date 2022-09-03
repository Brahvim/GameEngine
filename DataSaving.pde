import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.Serializable;

import java.util.Enumeration;
import java.util.Scanner;

import java.util.zip.*;


File savesFolder;
String savesFolderPath = null;

// Every part of this should be very scalable.

// The plan of action:
// Just create a system that allows one to save and load objects.
//
// Put them into a folder, `saves`, at runtime, (which also has a README file alerting
// users to NOT mess around with the files).
//
// When the program 'should exit', **a function** should zip the files into one!
// (...rather than making a parsing system to build a single one.)
// Delete the `saves` folder now!
// PS `saves` could be put in `temp` on Windows (`C:\\Windows\\Temp`).
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

  TestData t;
  writeObject(t = new TestData(), "cake");
  t = readObject("cake");
  if (t != null)
    println(t.word);
}

static class TestData implements Serializable {
  private final static long serialVersionUID = 390743L;
  String word = "Caaaaaake!";
}

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
  logInfo(objFile.getAbsolutePath());

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
