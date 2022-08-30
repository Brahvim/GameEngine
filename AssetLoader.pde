import processing.sound.*;

// This approach will NOT work. You just can't return any type you want without casting!:
/*
public <T> T getAsset(Asset p_asset) { 
 switch(p_asset.type)
 case PICTURE:
 return (T)Assets.pictures[p_asset.id];
 */

// We're only loading a few types, so there is no use of generics:
static enum AssetType {
  SOUND, PICTURE, SHADER; //, TEXTFILE, SAVEFILE;

  static int getMaxEntriesForType(AssetType p_type) {
    if (!Assets.isInit)
      throw new RuntimeException("Please call `Assets.init()`!");

    switch (p_type) {
    case SOUND:
      return Assets.sounds.length - 1;
    case PICTURE:
      return Assets.pictures.length - 1;
    case SHADER:
      return Assets.shaders.length - 1;
      //case TEXTFILE: return Assets.textFiles.length - 1;
    default:
      throw new RuntimeException("Unknown `AssetType`. How did this error even occur?!");
    }
  }
}

static class Assets {
  static SoundFile[] sounds = null; 
  static PImage[] pictures = null; 
  static PShader[] shaders = null;
  // Strings are immutable, COME ON!:
  //final static StringBuilder[] textFiles = new StringBuilder[0];

  static boolean isInit = false;

  static void init(int p_soundFiles, int p_images, int p_shaders) {
    Assets.sounds = new SoundFile[p_soundFiles]; 
    Assets.pictures = new PImage[p_images]; 
    Assets.shaders = new PShader[p_shaders];

    Assets.isInit = true;
    logInfo("`Assets.init()` was called.");
  }

  static void extendArraysTo(int p_soundFiles, int p_images, int p_shaders) {
    Assets.sounds = (SoundFile[]) expand(Assets.sounds, p_soundFiles); 
    Assets.pictures = (PImage[]) expand(Assets.pictures, p_images); 
    Assets.shaders = (PShader[]) expand(Assets.shaders, p_shaders);
  }

  // Just a note: Method overloading is faster than `instanceof` checks (which are done at runtime).
  // [https://stackoverflow.com/questions/19394815/
  // why-is-overloading-methods-recommended-over-using-the-instanceof-operator-in-java].

  static SoundFile getSound(Asset p_asset) {
    return Assets.sounds[p_asset.id];
  }

  static PImage getPicture(Asset p_asset) {
    return Assets.pictures[p_asset.id];
  }

  static PShader getShader(Asset p_asset) {
    return Assets.shaders[p_asset.id];
  }

  static SoundFile getSound(int p_id) {
    return Assets.sounds[p_id];
  }

  static PImage getPicture(int p_id) {
    return Assets.pictures[p_id];
  }

  static PShader getShader(int p_id) {
    return Assets.shaders[p_id];
  }
}

ArrayList<Asset> ASSETS = new ArrayList<Asset>();
class Asset extends Thread {
  // None of these needs to be `private`. They're fine the way they are!:
  String path = null;
  Object loadedData = null;
  Runnable onLoad = null;
  boolean loaded, ploaded;
  int id = -1;
  int loadFrame = -1;
  float loadTime = -1;
  AssetType type = null;

  Asset(String p_path, AssetType p_type) {
    ASSETS.add(this);
    this.path = p_path; 
    this.type = p_type;
    this.id = AssetType.getMaxEntriesForType(p_type);
  }

  // I wanted to make an array of paths, 
  // but that would mean more `.pde` files, so here we are - it's an arg!
  Asset(String p_path, AssetType p_type, int p_id) {
    ASSETS.add(this);
    this.path = p_path;

    // Avoid the huge switch-case statement:
    if (p_id >= AssetType.getMaxEntriesForType(p_type))
      throw new ArrayIndexOutOfBoundsException("You gave an asset an incorrect ID :P");
    this.id = p_id;
    this.type = p_type;
  }

  Asset(String p_path, AssetType p_type, Runnable p_onLoad) {
    ASSETS.add(this);
    this.path = p_path;
    this.type = p_type;
    this.onLoad = p_onLoad;
    this.id = AssetType.getMaxEntriesForType(p_type);
  }

  Asset(String p_path, AssetType p_type, int p_id, Runnable p_onLoad) {
    // Thank you, `javac`:
    this(p_path, p_type, p_id);
    this.onLoad = p_onLoad;
    this.id = AssetType.getMaxEntriesForType(p_type);
  }

  Asset beginAsyncLoad() {
    super.start();
    return this;
  }

  void run() {
    this.load();
  }

  // Loads the asset. Use `.run()` instead to load in a new thread.
  Asset load() {
    // So now that we're here, welp, what else do we have to do?!
    // Determine the file's type and get loadiiiiiinggggg:

    switch(this.type) {
    case SOUND:
      while (this.loadedData == null)
        this.loadedData = new SoundFile(SKETCH, this.path); 
      if (this.id == -1)
        throw new RuntimeException("Cannot load an asset into its array.");
      synchronized(Assets.sounds) {
        synchronized(this.loadedData) {
          SoundFile snd = (Assets.sounds[this.id] = (SoundFile)this.loadedData);
          snd.rate(1.09f);
        }
      }
      break;

    case PICTURE:
      while (this.loadedData == null)
        this.loadedData = loadImage(this.path);
      if (this.id == -1)
        throw new RuntimeException("Cannot load an asset into its array.");
      synchronized(Assets.pictures) {
        synchronized(this.loadedData) {
          Assets.pictures[this.id] = (PImage)this.loadedData;
        }
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
        while (this.loadedData == null)
          // If the user is trying to load two shaders, do:
          this.loadedData = loadShader(shaders[0], shaders[1]);

      // Otherwise, it's just a fragment shader. Get it. Go on! :)
      else while (this.loadedData == null)
        this.loadedData = loadShader(this.path);

      if (this.id == -1)
        throw new RuntimeException("Cannot load an asset into its array.");
      synchronized(Assets.shaders) {
        synchronized(this.loadedData) {
          Assets.shaders[this.id] = (PShader)this.loadedData;
        }
      }
      break;
      //case TEXTFILE:  break;
    }

    this.loaded = true;
    this.loadFrame = frameCount;
    this.loadTime = millis();

    if (this.onLoad != null) 
      this.onLoad.run();

    return this;
  }

  void waitTillLoaded() {
    while (!this.loaded);
  }

  void runOnLoadCallback() {
    if (this.onLoad != null)
      this.onLoad.run();
  }

  PImage asPicture() {
    // No need to check for null values!    
    return this.type == AssetType.PICTURE? (PImage)this.loadedData : null;
    // ...and if the type of data being loaded is different, well...
  }

  SoundFile asSound() {
    // No need to check for null values!    
    return this.type == AssetType.SOUND? (SoundFile)this.loadedData : null;
    // ...and if the type of data being loaded is different, well...
  }

  PShader asShader() {
    // No need to check for null values!    
    return this.type == AssetType.SHADER? (PShader)this.loadedData : null;
    // ...and if the type of data being loaded is different, well...
  }
}
