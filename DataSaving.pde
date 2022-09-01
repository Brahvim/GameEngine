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

String saveFilePath;

File zippedSavesFile;
ZipFile zippedSaves;

ZipOutputStream zStream;

// Every part of this should be very scalable.

void initSaving() {
  canSave = true; // This is to tell if caught exceptions occur and disallow saving!

  // The plan of action:
  // First, we create our zip file.
  // Then, we load all of its entries.
  // The user should load data from each entry themselves.

  // DON'T YOU DARE CALL THAT CONCATENATED STRING MICRO-SOFTY:
  zippedSavesFile = new File(sketchPath + SKETCH_NAME + "_Save.sav");
  saveFilePath = zippedSavesFile.getAbsolutePath();

  if (!zippedSavesFile.exists())
  try {
    zippedSavesFile.createNewFile();
  }
  catch (IOException e) {
    canSave = false;
    logError("Save system initialization failed! `zippedSavesFile` could not be created.");
    logEx(e);
  }

  try {
    zippedSaves = new ZipFile(zippedSavesFile);
  }
  catch (IOException e) {
    canSave = false;
    logError("Save system initialization failed! `zippedSaves` could not be created.");
    logEx(e);
    // A "`ZipException`" is also thrown, but apparently extends
    // `IOException`, meaning that it can be handled here as well.
  }
  catch (NullPointerException e) {
    logWarn("`zippedSaves` was `null`! Does it exist?");
    logEx(e);
  }

  Enumeration<? extends ZipEntry> zipEntries = null;

  if (zippedSaves != null)
    zipEntries = zippedSaves.entries();

  if (zipEntries != null) {
    saveMap.clear();
    while (zipEntries.hasMoreElements()) {
      ZipEntry e = zipEntries.nextElement();

      String name = e.getName();
      // Notice the usage of the `name` variable. You can't 'optimize' this:
      name = name.substring(0, name.lastIndexOf("."));

      saveMap.put(name, e);
    }
  }

  logInfo("Save location:");
  logInfo('\t', zippedSavesFile.getAbsolutePath());
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
    return null;
  }

  try {
    entryStream = zippedSaves.getInputStream(entry);
  }
  catch (IOException e) {
    logError("The saving system Could not get an input stream to some `ZipEntry`.");
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
    return (T)oStream.readObject();
  }
  catch (IOException e) {
    logError("");
    logEx(e);
  }
  catch (ClassNotFoundException e) {
  }

  return null;
}

void writeToSaveFile(String p_name, Serializable p_data) {
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
