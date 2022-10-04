import java.io.*;
import processing.sound.*;

// Remember: `sketchPath()` works correctly ONLY in `setup()`!
File sketchFolder, dataFolder, savesFolder;
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

  TransformationSerializer(NerdTransform p_form) {
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



/*

 
 // Asset loader!:
 
 
 */


// *Bad idea?*

// Fun fact: the code could've had an alternate approach by having made a class to load assets,
// ..and then making a class wrapping that class doing the task async.
// (The super class would load the asset itself in a different method!)
// Only the async loader class would then implement the `onLoad` runnable / extra method.
// I'd might want to do this in a future version for workflow improvements, maybe?
// It is a de-optimization for performance...

// Do I really need this?
ArrayList<Asset> ASSETS = new ArrayList<Asset>();

Asset loadAsync(String p_path, AssetType p_type, Runnable p_onLoad) {
  return new Asset(p_path, p_type, p_onLoad).beginAsyncLoad();
}

Asset loadAsync(String p_path, AssetType p_type) {
  return new Asset(p_path, p_type).beginAsyncLoad();
}

Asset loadNow(String p_path, AssetType p_type, Runnable p_onLoad) {
  return new Asset(p_path, p_type, p_onLoad).load();
}

Asset loadNow(String p_path, AssetType p_type) {
  return new Asset(p_path, p_type).load();
}

// We're only loading a few types, so there is no use of generics:
static enum AssetType {
  SOUND, IMAGE, SHADER, SHAPE;

  static int getMaxEntriesForType(AssetType p_type) {
    switch (p_type) {
    case SOUND:
      return Assets.sounds.size();
    case IMAGE:
      return Assets.images.size();
    case SHADER:
      return Assets.shaders.size();
    case SHAPE:
      return Assets.shaders.size();
    default:
      throw new RuntimeException("Unknown `AssetType`. How did this error even occur?!");
    }
  }
}

static class Assets {
  static ArrayList<SoundFile> sounds = new ArrayList<SoundFile>();
  static ArrayList<PImage> images = new ArrayList<PImage>();
  static ArrayList<PShader> shaders = new ArrayList<PShader>();
  static ArrayList<PShape> shapes = new ArrayList<PShape>();

  // Just a note: Method overloading is faster than `instanceof` checks (which are done at runtime).
  // [https://stackoverflow.com/questions/19394815/
  // why-is-overloading-methods-recommended-over-using-the-instanceof-operator-in-java].

  static SoundFile getSound(Asset p_asset) {
    return Assets.sounds.get(p_asset.id);
  }

  static PImage getImage(Asset p_asset) {
    return Assets.images.get(p_asset.id);
  }

  static PShader getShader(Asset p_asset) {
    return Assets.shaders.get(p_asset.id);
  }

  static PShape getShape(Asset p_asset) {
    return Assets.shapes.get(p_asset.id);
  }


  // Do we really need these shortcuts?
  // Would you rather type `Assets.assetType.get(id);`
  // or `Assets.getAssetType(id);`?
  static PShape getShape(int p_id) {
    return Assets.shapes.get(p_id);
  }

  static SoundFile getSound(int p_id) {
    return Assets.sounds.get(p_id);
  }

  static PImage getImage(int p_id) {
    return Assets.images.get(p_id);
  }

  static PShader getShader(int p_id) {
    return Assets.shaders.get(p_id);
  }
}

class Asset extends Thread {
  // None of this class's fields needs to be `private`.
  // They're fine the way they are!:
  String path = null;
  AssetType type = null;
  Object loadedData = null;

  // Extra helper data:
  Runnable onLoad = null; // Should be replaced with an overload.
  Boolean loaded = new Boolean(false), ploaded = new Boolean(false);
  int id = -1, loadFrame = -1;
  int loadTime = -1;

  Asset(String p_path, AssetType p_type) {
    ASSETS.add(this);
    this.path = p_path; 
    this.type = p_type;
  }

  Asset(String p_path, AssetType p_type, Runnable p_onLoad) {
    ASSETS.add(this);
    this.path = p_path;
    this.type = p_type;
    this.onLoad = p_onLoad;
  }

  Asset beginAsyncLoad() {
    super.start();
    return this;
  }

  void run() {
    this.load();
  }

  // Loads the asset. Use `.run()` instead to load in a new thread:
  Asset load() {
    // So now that we're here, welp, what else do we have to do?!
    // Determine the file's type and get loadiiiiiinggggg:

    switch(this.type) {
    case SOUND:
      this.loadedData = new SoundFile(SKETCH, this.path); 

      synchronized(Assets.sounds) {
        this.id = Assets.sounds.size();

        SoundFile loadedAudio = (SoundFile)this.loadedData;
        loadedAudio.rate(1.09f);
        Assets.sounds.add(loadedAudio);
      }
      break;

    case IMAGE:
      this.loadedData = loadImage(this.path);

      synchronized(Assets.images) {
        this.id = Assets.images.size();
        Assets.images.add((PImage)this.loadedData);
      }
      break; 

    case SHADER:
      // Constructing a `PShader` object in Processing, can be done with file
      // paths for either just a vertex shader, or both a vertex and fragment shader.
      // To avoid making another asset instance, we will take a `\n` in the filepath. 
      // Pretty sure no file system allows the use of a `\n` in filenames!
      // The next line is checking for a `\n`:
      String[] shaders = split(this.path, '\n');


      if (shaders.length == 1)
        // If the user is trying to load two shaders, do:
        this.loadedData = loadShader(shaders[0], shaders[1]);

      // Otherwise, it's just a fragment shader. Get it. Go on! :)
      else this.loadedData = loadShader(this.path);

      synchronized(Assets.shaders) {
        this.id = Assets.shaders.size();
        Assets.shaders.add((PShader)this.loadedData);
      }
      break;

    case SHAPE:
      this.loadedData = loadShape(this.path);

      synchronized(Assets.shapes) {
        this.id = Assets.shapes.size();
        Assets.shapes.add((PShape)this.loadedData);
      }
      break;
    }

    synchronized(this.loaded) {
      this.loaded = true;
    }

    this.loadFrame = frameCount;
    this.loadTime = millis();

    if (this.onLoad != null)
      this.onLoad.run();

    return this;
  }

  PImage asImage() {
    // No need to check for null values!
    return (PImage)this.loadedData;
    // ...and if the type of data being loaded is different, well...
  }

  SoundFile asSound() {
    return (SoundFile)this.loadedData;
  }

  PShader asShader() {
    return (PShader)this.loadedData;
  }

  PShape asShape() {
    return (PShape)this.loadedData;
  }

  <T> T getData() {
    return (T)this.loadedData;
  }
}

/*

 
 // Networking!
 
 
 */
