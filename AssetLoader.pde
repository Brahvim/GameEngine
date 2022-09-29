import processing.sound.*;

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
