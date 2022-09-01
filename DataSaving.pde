import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.Serializable;

import java.util.Enumeration;
import java.util.Scanner;

import java.util.zip.*;

ArrayList<String> saveFileNames = new ArrayList<String>();
boolean canSave;

String saveFilePath = null;

File zippedSavesFile;
ZipFile zippedSaves;

ZipOutputStream zStream;

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
  canSave = true; // This is to tell if caught exceptions occur and disallow saving!

  // DON'T YOU DARE CALL PART OF THAT CONCATENATED STRING MICRO-SOFTY:
  zippedSavesFile = new File(sketchPath + SKETCH_NAME + "_Save.sav");
  saveFilePath = zippedSavesFile.getAbsolutePath();

  boolean didExist =  zippedSavesFile.exists();

  if (!zippedSavesFile.exists())
  try {
    zippedSavesFile.createNewFile();
  } 
  catch(IOException e) {
    canSave = false;
    logError("Could not create `zippedSavesFile`.");
    logEx(e);
  } else try {
    //if (!didExist) {
    ////ZipEntry dummy = new ZipEntry("dummy");
    //zStream.putNextEntry(new ZipEntry("dummy"));
    //zStream.closeEntry();
    //zStream.flush();
    //}
  }
  catch (FileNotFoundException e) {
    logError("Could not create a `ZipOutputStream`!");
    logEx(e);
  }
  catch (IOException e) {
  }

  try {
    zippedSaves = new ZipFile(zippedSavesFile);
  }
  catch (ZipException e) {
    logError("cOuLd nOt cR3ATe `zIpfILE`.");
    logEx(e);
  }
  catch (IOException e) {
    logError("cOuLd nOt cR3ATe `zIpfILE`.");
    logEx(e);
  }

  if (canSave) {
    logInfo("Save location:");
    logInfo('\t', zippedSavesFile.getAbsolutePath());
  }
  logInfo("Save system ", canSave? "initialized successfully!" : "failed to initialize ; - ;)");

  class TestClass implements Serializable {
    String name = "null";

    TestClass(String p_name) {
      this.name = p_name;
    }
  }

  //writeFile("test", new TestClass("Brahvim"));
  //TestClass read = readFile("test");
  //println("Read name:", read.name);
}

// JIT for the win!:
// Also, ease of use for users - scaleable code! :D
ZipEntry getEntry(String p_name) {
  Enumeration<? extends ZipEntry> saveFiles = zippedSaves.entries();

  while (saveFiles.hasMoreElements()) {
    ZipEntry e = saveFiles.nextElement();
    String name = e.getName();
    if (name.substring(0, name.length() - 8).equals(p_name))
      return e;
  }

  logError("No save file called `", p_name, "` exists.");
  return null;
} 

<T> T readFile(String p_name) {
  ZipEntry entry = getEntry(p_name);
  InputStream entryStream = null;
  ObjectInputStream oStream = null;

  if (entry == null)
    return null;

  try {
    entryStream = zippedSaves.getInputStream(entry);
  }
  catch (IOException e) {
    logError("The saving system could not get an input stream to some `ZipEntry`.");
    logEx(e);
  }

  try {
    oStream = new ObjectInputStream(entryStream);
  }
  catch (IOException e) {
    logError("Failed to create an `ObjectInputStream`...");
    logEx(e);
  }

  try {
    if (oStream == null)
      throw new IOException();
    return (T)oStream.readObject();
  }
  catch (IOException e) {
    logError("`ObjectInputStream` was `null` :|");
    logEx(e);
  }
  catch (ClassNotFoundException e) {
  }

  return null;
}

void writeFile(String p_name, Serializable p_data) {
  FileOutputStream fStream = null;
  ObjectOutputStream oStream = null;

  try {
    fStream = new FileOutputStream(zippedSavesFile);
  }
  catch (FileNotFoundException e) {
    logError("Wait, what?! Failed to find `zippedSavesFile`!");
    logEx(e);
  }

  // Zipping:
  ZipEntry zEntry = new ZipEntry(p_name + ".sav_frag");

  try {
    zStream.putNextEntry(zEntry);
  }
  catch (IOException e) {
    logError("Could not make a `ZipEntry`");
    logEx(e);
  }

  try {
    oStream = new ObjectOutputStream(zStream);
    oStream.writeObject(p_data); // Object is written.
    zStream.closeEntry();
    zStream.flush();

    oStream.close();
    if (fStream != null)
      fStream.close();
  }
  catch (IOException e) {
    logError("Could not create an `ObjectOutputStream`, "
      + "or maybe it failed to write the object, or something failed to close. "
      + "I dunno, man. This code is HUGE, and EVERY function is throwing an `IOException`!");
    logEx(e);
  }
}
