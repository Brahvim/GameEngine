import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.Serializable;

import java.nio.charset.Charset;

import java.util.Enumeration;
import java.util.Scanner;

import java.util.zip.*;

HashMap<String, ZipEntry> saveMap = new HashMap<String, ZipEntry>();
ArrayList<String> saveFileNames = new ArrayList<String>();
boolean canSave;

String saveFolderPath;

File saveFolder;
File zippedSavesFile;
ZipFile zippedSaves;

ZipOutputStream zStream;

// Every part of this should be very scalable.

void initSaving() {
  canSave = true;

  saveFolder = new File(sketchPath + "saves");
  if (!saveFolder.exists())
    saveFolder.mkdir();
  saveFolderPath = saveFolder.getAbsolutePath();

  // DON'T YOU DARE CALL THAT CONCATENATED STRING MICRO-SOFTY:
  zippedSavesFile = new File(saveFolder, SKETCH_NAME + "_Save.zip");
  if (!zippedSavesFile.exists())
  try {
    zippedSavesFile.createNewFile();
  } 
  catch (IOException ioe) {
    canSave = false;
    logError("Save system initialization failed! `zippedSavesFile` could not be created.");
    logEx(ioe);
  }

  try {
    zippedSaves = new ZipFile(zippedSavesFile);
  }
  catch (IOException e) {
    // A "`ZipException`" is also thrown, but apparently extends
    // `IOException`, meaning that it can be handled here as well.
  }

  logInfo("Save location:");
  logInfo('\t', saveFolder.getAbsolutePath());
  logInfo("Save system ", canSave? "initialized successfully!" : "failed to initialize ; - ;)");
}

void createNewSaveFile(String p_name) {
  saveMap.putIfAbsent(p_name, new ZipEntry(p_name));
  saveFileNames.add(p_name);
}

void removeSaveFile(String p_name) {
  saveMap.remove(p_name);
  saveFileNames.remove(p_name);
}

<T> T readFromSaveFile(String p_name) {
  ZipEntry entry = saveMap.get(p_name);
  InputStream entryStream = null;
  ObjectInputStream oStream = null;

  if (entry == null) {
    logError("No save file called `" + p_name + "` exists.");
    logEx(new NullPointerException());
  }

  try {
    entryStream = zippedSaves.getInputStream(entry);
  }
  catch (IOException ioe) {
    logError("The saving system Could not get an input stream to some `ZipEntry`.");
    logEx(ioe);
  }

  try {
    oStream = new ObjectInputStream(entryStream);
  }
  catch(IOException ioe) {
    logError("Failed to create an `ObjectInputStream`...");
    logEx(ioe);
  }

  try {
    return (T)oStream.readObject();
  }
  catch(IOException ioe) {
    logError("");
    logEx(ioe);
  }
  catch(ClassNotFoundException ioe) {
  }

  return null;
}

void writeToSaveFile(String p_name, Serializable p_data) {
  FileOutputStream fStream = null;
  ObjectOutputStream oStream = null;

  try {
    fStream = new FileOutputStream(zippedSavesFile);
  }
  catch (FileNotFoundException fnfe) {
    logError("Wait, what?! Failed to find `zippedSavesFile`!");
    logEx(fnfe);
  }

  // Zipping:
  ZipEntry zEntry = new ZipEntry(p_name + ".sav_frag");

  try {
    zStream.putNextEntry(zEntry);
  }
  catch(IOException ioe) {
    logError("Could not make a `ZipEntry`");
    logEx(ioe);
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
  catch(IOException ioe) {
    logError("Could not create an `ObjectOutputStream`, "
      + "or maybe it failed to write the object, or something failed to close. "
      + "I dunno, man. This code is HUGE, and EVERY function is throwing an `IOException`!");
    logEx(ioe);
  }
}
