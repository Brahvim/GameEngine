import java.io.*;

File savesFolder;
String savesFolderPath = null;

// Every part of this should have FULL control and should be as scalable as possible.

// The plan of action:
// Just create a system that allows one to save and load objects.
//
// Put them into a folder, `saves`, at runtime, (which also has a README file alerting
// users to NOT mess around with the files).
//
// PS the logs could be put in `temp` on Windows (`C:\\Windows\\Temp`).
// (On GNU/Linux, `/tmp` or `/var/tmp`. ...and who'd like to read the Apple T&Cs daily?)
// (Actually, store that temporary stuff in the same dir as the app. That's Apple's good practices.)
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
    nerdLogEx(e);
  }

  try {
    FileOutputStream fout = new FileOutputStream(objFile);
    ObjectOutputStream oStream = new ObjectOutputStream(fout);

    oStream.writeObject(p_object);

    oStream.close();
    fout.close();
  }
  catch (FileNotFoundException e) {
    nerdLogEx(e);
  }
  catch (IOException e) {
    nerdLogEx(e);
  }
}

<T> T readObject(String p_fname) throws FileNotFoundException {
  T ret = null;
  File objFile = new File(savesFolder, p_fname.concat(".sav_frag"));

  try {
    FileInputStream fin = new FileInputStream(objFile);
    ObjectInputStream oStream = new ObjectInputStream(fin);

    try { 
      ret = (T)oStream.readObject();
    }
    catch(ClassNotFoundException e) {
      nerdLogEx(e);
    }
    finally {
      oStream.close();
      fin.close();
    }
    return ret;
  } 
  catch (FileNotFoundException e) {
    throw e;
  }
  catch (IOException e) {
    nerdLogEx(e);
    return null;
  }
}


class VectorSerializer implements Serializable {
  private final static long serialVersionUID = 685642643L;
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
 
 ColorSerializer(int p_color) {
 this.data[0] = p_color >> 16 & 0xFF;
 this.data[1] = p_color & 0xFF;
 this.data[2] = p_color >> 8 & 0xFF;
 }
 
 ColorSerializer(float p_red, float p_green, float p_blue, float p_alpha) {
 }
 }
 */

class ColorSerializer implements Serializable {
  private final static long serialVersionUID = 54865654L;
  int data;

  ColorSerializer(int p_color) {
    this.data = p_color;
  }

  ColorSerializer(float p_red, float p_green, float p_blue, float p_alpha) {
    this.data = color(p_red, p_green, p_blue, p_alpha);
  }
}

static class TransformationSerializer implements Serializable {
  private final static long serialVersionUID = 856598746L;
  float[] data = new float[9];

  TransformationSerializer(Transformation p_form) {
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

static class MaterialSerializer implements Serializable {
  private final static long serialVersionUID = 435461531L;
  float[] data = new float[10];

  MaterialSerializer(Material p_mat) {
    this.data[0] = p_mat.amb.x;
    this.data[1] = p_mat.amb.y;
    this.data[2] = p_mat.amb.z;

    this.data[3] = p_mat.emm.x;
    this.data[4] = p_mat.emm.y;
    this.data[5] = p_mat.emm.z;

    this.data[6] = p_mat.spec.x;
    this.data[7] = p_mat.spec.y;
    this.data[8] = p_mat.spec.z;

    this.data[9] = p_mat.shine;
  }
}
