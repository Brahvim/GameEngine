import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.Serializable;

import java.nio.charset.Charset;

import java.util.Enumeration;
import java.util.Scanner;

import java.util.zip.ZipEntry;
import java.util.zip.ZipFile;
import java.util.zip.ZipOutputStream;

HashMap<String, ZipEntry> saveMap = new HashMap<String, ZipEntry>();
ArrayList<String> saveFileNames = new ArrayList<String>();

File saveFolder = new File("saves"), zippedSaves;

// Every part of this should be very scalable.

void initSaving() {
  zippedSaves = new File(saveFolder, SKETCH_NAME + "savefile.zip");
}

//void a() {
//}
