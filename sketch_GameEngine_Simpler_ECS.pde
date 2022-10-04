void settings() {
  size(INIT_WIDTH, INIT_HEIGHT, P3D);
  //PJOGL.setIcon(new String[]{"sunglass_nerd.png"});
  // For when you need to provide multiple resolution icons yourself!
}

// This used to be an overload for `exit()`.
void dispose() {
  window.setVisible(false);
  while (window.isVisible());

  nerdLogInfo("`engineExit()` called...");

  if (onExit != null)
    onExit.run();

  Log.logFile.setWritable(false);
  Log.fileLogger.flush();

  if (Log.openFileOnExit)
  try {
    if (Log.nerdCanLog)
      println("Find the log file at: ", Log.absPath);
    new ProcessBuilder("notepad", Log.absPath).start();
  }  
  catch (IOException e) {
    e.printStackTrace();
    // Seriously? What do you expect me to do now? Open that stream up again and write to it?
    // <sigh.>
    // Fine, here we go...
    nerdLogInfo("Hey! By the way, the log file kinda got logged out,"
      + " if you will... you know, understand?");
    nerdLogEx(e);
  }

  Log.fileLogger.flush();
  Log.fileLogger.close();

  super.dispose();

  // With proper monitoring of window fullscreen events in `post()` now, this is superfast :D
  //super.exit(); // This is now `dispose()` and not `exit()`.

  // Fun fact: `Ctrl + G`, in the PDE, continues to search for the text you last searched for.

  //window.destroy(); // Faster, but might let the application stop responding completely!
  // No longer needed though :D
}

void setup() {
  updateRatios();

  // Should load this up from a save file (or a `--smooth` argument from the launcher):
  //int a = 2;
  //smooth(a);
  // `smooth()`can be called in `setup()` :D
  // (NOT `draw()`, THOUGH!)

  surface.setTitle("Nerd Engine");

  //g = createPrimaryGraphics(); // Super important discovery!
  // [https://github.com/processing/processing/blob/8b15e4f548c1426df3a5ebe4c2106619faf7c4ba/
  // core/src/processing/core/PApplet.java#L2343]

  sketchFolder = new File(sketchPath());
  dataFolder = new File(sketchFolder, "data");

  sketchArgsStr = System.getProperty("sun.java.command");
  sketchArgs = sketchArgsStr.split(" ");
  insidePde = sketchArgs.length > 2 && 
    sketchArgs[1].contains("display") && sketchArgs[2].contains("sketch-path");

  // This was one of the ways to get the sketch's path:
  // It already has `File.separator` appended to it :D
  //sketchPath = INSIDE_PDE ? sketchArgs[2].substring(14, sketchArgs[2].length()) + File.separator
  //  : sketchPath();
  // ...back when I thought `sketchPath()` was inaccurate. Hmph.

  initLog();
  initSaving();
  initSphere(SPHERE_DETAIL);

  nerdLogInfo("Executable directory: ");
  nerdLogInfo("\t", sketchPath());
  //logInfo(
  //"(Perhaps the only difference is that it ends in a `File.separator`, but `sketchPath()` DOES that!)");

  //soundDevices = Sound.list();
  //logToFile(Log.lvInfo, "Audio devices:");
  //for (String s : soundDevices)
  //logToFile(Log.lvInfo, '\t', s);

  nerdLogInfo("Will load LibBulletJME from:");
  nerdLogInfo("\t", new File(sketchPath("lib")).getAbsolutePath());
  // Where's my `logInfoIndented()`?! :rofl:

  // Library initialization:

  Fisica.init(this);
  //fx = new PostFXSupervisor(this);
  nerdLogInfo("Loading LibBulletJME...");
  NativeLibraryLoader.loadLibbulletjme(true, 
    new File(sketchPath("lib")), // Do NOT use `sketchPath + "lib"`! That failed. 
    "Release", "Sp");

  // Can't do this on Android!:
  nerdLogInfo("Sketch arguments:");
  for (String s : sketchArgs)
    nerdLogInfo('\t', s);

  nerdLogInfo(insidePde? "Yep! The sketch is running inside the PDE!" 
    : "Nope, the sketch wasn't running in the PDE.");

  window = (GLWindow)surface.getNative();
  glGraphics = (PGraphicsOpenGL)g;

  javaGraphicsEnvironment = GraphicsEnvironment.getLocalGraphicsEnvironment();
  javaScreens = javaGraphicsEnvironment.getScreenDevices();

  REFRESH_RATE = javaScreens[0].getDisplayMode().getRefreshRate();
  refreshRates = new int[javaScreens.length];

  for (int i = 0; i < javaScreens.length; i++)
    refreshRates[i] = javaScreens[i].getDisplayMode().getRefreshRate();

  // [https://developer.android.com/reference/android/view/Display#getSupportedModes()]:
  //REFRESH_RATE = getActivity().getWindowManager().getDefaultDisplay()
  //.getSupportedDisplayModes()[0].getRefreshRate();

  // Alternative:
  //REFRESH_RATE = getActivity().getWindowManager().getDefaultDisplay().getRefreshRate();

  if (REFRESH_RATE == DisplayMode.REFRESH_RATE_UNKNOWN) {
    REFRESH_RATE = -1;
    frameRate(60); // Unknown refresh rate, let's run at the standard for FPS video games!
  } else
    frameRate(REFRESH_RATE); // Let the user enjoy the magic of VSync!
  // Processing already looks good both with and without it, but anyway!

  surface.setResizable(true);
  surface.setSize(INIT_WIDTH, INIT_HEIGHT);
  centerWindow();

  registerMethod("pre", this);
  registerMethod("post", this);

  rectMode(CENTER);
  imageMode(CENTER);
  //hint(ENABLE_STROKE_PERSPECTIVE);

  textFont(createFont("SansSerif", TEXT_TEXTURE_SIZE));
  textSize(DEFAULT_TEXT_SIZE);
  textAlign(CENTER, CENTER);

  nerdLogInfo("`engineSetup()` TO BE CALLED!"); // Errors would occur after this.

  int beforeEngineSetup = millis();

  Method engineSetupMethod = null;

  // Could "search the array from both sides" for speed!
  // Nope! This is not faster because CPU cache is not utilized at all!

  //for (int i = 0; i < SKETCH_METHODS.length; i++) {
  //Method m = SKETCH_METHODS[(i & 1) == 1? i : SKETCH_METHODS.length - i];
  for (Method m : SKETCH_METHODS) // Comment this out to use the "both side" method.
    if (m.getName() == "engineSetup") {
      engineSetupMethod = m;
      break;
    }
  //}

  if (engineSetupMethod == null) {
    nerdLogError("Found no `engineSetup()`, loading up `SCENES.get(0)`.");
    if (SCENES.size() > 0)
      setScene(SCENES.get(0));
  } else try {
    // You have to pass an object instance to invoke the method on if the method isn't static.
    // If the method is parameterless, pass `null`.
    // Else, pass parameters into `invoke()` - it is a `varargs` method.
    // The return value of the method called, is what `invoke` returns, as well.
    engineSetupMethod.invoke(this);
  }  
  catch (InvocationTargetException e) {
    logError("`engineSetup()` encountered an exception!");
    logEx(e);
  }
  catch (IllegalAccessException e) {
    logError("Please declare `engineSetup()` as `public`!");
  }
  catch (IllegalArgumentException e) {
    logError("Please declare `engineSetup()` without any parameters!");
  }

  //engineSetup(); // Was here just for da teshts.
  // Funnily enough using reflection to invoke the method is not slow at all! 
  nerdLogInfo("`engineSetup()` succeded in `", millis() - beforeEngineSetup
    , "` milliseconds."); // Errors would occur... after this.
}

void pre() {
  preBegun = true;
  frameDidUpdate = false;
  // More update cancellation goes here...

  mouseScrollDelta = mouseScroll - pmouseScroll;

  if (!(pwidth == width || pheight == height)) {
    //fx.setResolution(width, height); // If I ever want to bring PostFX back, well, this is how.
    updateRatios();
    currentScene.windowResized();
  }
  preEnded = true;
}

// Trying to ONLY keep things, that need rendering, here:
void draw() {
  drawBegun = true;

  // ...ahahaha! Do this first!:
  frameStartTime = millis(); // Timestamp.
  frameTime = frameStartTime - pframeTime;
  pframeTime = frameStartTime;
  deltaTime = frameTime * 0.01f;

  if (currentCam == null)
    setCam(DEFAULT_CAMERA);

  // Ah... the tradition of using `background()` first :)
  if (doCamera && currentCam != null)
    if (currentCam.doAutoClear)
      currentCam.clear();

  // *OpenGL reference.*
  // *Every video game reference:*
  gl = beginPGL();

  // Start *post* Processing with PostFX!:
  //if (doPostProcessingState)
  //fx.render();

  if (doLights)
    lights(); //, `camera()`, // `action()`! :D!

  // Apply camera transformations first, so
  // that entities and Rendering components
  // can use methods such as `modelX()`, and check matrices.

  push();
  if (doCamera && currentCam != null)
    currentCam.runScript();
  // ^^^ Running the script here does not cause Z-fighting issues :O
  // [https://stackoverflow.com/questions/55185184/objects-shake-when-rotating]
  // [https://en.wikipedia.org/wiki/Z-fighting]

  // (If you run the script later, for example, right before the next call to `cam.applyMatrix()`,
  // **after this `if`**, the camera rotation causes mouse-ray objects to shake.)

  // Unproject the mouse position:

  //if (focused)
  unprojectMouse();

  // (Yeah. This place? Running the script here? There's gunna be Z-fighting action - get popcorn! :joy:)
  if (doCamera && currentCam != null)
    currentCam.applyMatrix();

  for (Component c : currentScene.components)
    if (!(c instanceof RenderingComponent))
      if (c.enabled && c.parent.enabled)
        c.update();
      else c.disabledUpdate();

  frameDidComponentUpdate = true;

  currentScene.draw();
  frameDidSceneUpdate = true;

  for (Entity e : currentScene.entities)
    if (e.enabled)
      e.update();

  frameDidEntityUpdate = true;
  frameDidUpdate = true;

  if (doAnyDrawing && doRendering) 
    // I applied ^^^ that check EVEN to post processing as well but GPU usage remained unchanged.
    for (RenderingComponent r : currentScene.renderers) {
      r.parent.render();
      if (r.enabled)
        r.update();
      r.parent.postRender();
    }

  frameDidRender = true;

  // Step the Physics Engines later, because...
  // I'd like to be at the origin of the world on my first frame...
  // Also, the user changes Physics-related data in their updates.
  if (b2d != null && b2dShouldUpdate)
    b2d.step(deltaTime);

  if (bt != null && btShouldUpdate)
    bt.update(deltaTime);
  pop();

  frameDidPhysics = true;

  if (doAnyDrawing && doUIRendering) {
    begin2D();
    noLights();
    currentScene.drawUi();
    end2D();
  }

  frameDidUI = true;
  endPGL();

  drawEnded = true;
}


// Ayo, do the post - update!:
void post() {
  postBegun = true;
  // "Post Processing":
  // (...get it? :rofl:)

  // YOU CAN RENDER HERE APPARENTLY!:
  // (Might break libraries :|)
  // (It did. Our UI rendered on top of ControlP5's.)

  //if (doPostProcessingState && focused) {
  //blendMode(SCREEN);
  //image(fx.getCurrentPass(), cx, cy, width, height);
  //blendMode(BLEND);
  //}

  //doPostProcessingState = doPostProcessing;

  pwidth = width;
  pheight = height;
  pfocused = focused;

  pmouse.set(mouse);
  pmouseLeft = mouseLeft;
  pmouseMid = mouseMid;
  pmouseRight = mouseRight;
  pmouseButton = mouseButton;
  pmouseScroll = mouseScroll;
  pmouseScrollDelta = mouseScrollDelta;

  pkey = key;
  pkeyCode = keyCode;
  pkeyPressed = keyPressed;
  pmousePressed = mousePressed;

  pfullscreen = fullscreen;

  //if (pfullscreen != fullscreen) {
  window.setFullscreen(fullscreen);
  while (fullscreen ? !window.isFullscreen() : window.isFullscreen());
  //}

  window.confinePointer(cursorConfined);
  while (cursorConfined ? !window.isPointerConfined() : window.isPointerConfined());

  window.setPointerVisible(cursorVisible);
  while (cursorVisible ? !window.isPointerVisible() : window.isPointerVisible());

  // Doing this in the end:
  for (Asset a : ASSETS)
    synchronized(a) {
      a.ploaded = a.loaded;
    }

  postEnded = true;
}

void mousePressed() {
  Timers.mousePress = millis();
  switch(mouseButton) {
  case LEFT:
    mouseLeft = true;
    break;
  case RIGHT:
    mouseRight = true;
    break;
  case CENTER : 
    mouseMid = true;
    break;
  }

  // Calling this later so that our variables have the latest values:
  currentScene.mousePressed();
  for (Entity e : currentScene.entities)
    e.mousePressed();
}

void mouseReleased() {
  switch(mouseButton) {
  case LEFT:
    mouseLeft = false;
    break;
  case RIGHT:
    mouseRight = false;
    break;
  case CENTER : 
    mouseMid = false;
    break;
  }

  // Calling this later so that our variables have the latest values:
  currentScene.mouseReleased();
  for (Entity e : currentScene.entities)
    e.mouseReleased();
}

void mouseMoved() {
  currentScene.mouseMoved();
  for (Entity e : currentScene.entities)
    e.mouseMoved();
}

void mouseClicked() {
  currentScene.mouseClicked();
  for (Entity e : currentScene.entities)
    e.mouseClicked();
}

void mouseDragged() {
  currentScene.mouseDragged();
  for (Entity e : currentScene.entities)
    e.mouseDragged();
}

void mouseWheel(MouseEvent p_event) {
  currentScene.mouseWheel(p_event);
  mouseScroll -= p_event.getCount();

  for (Entity e : currentScene.entities)
    e.mouseWheel(p_event);
}

void keyPressed() {
  Timers.keyPress = millis();

  // `Shift + Esc` to close, by the way.
  if (keyCode == 27) // If `Esc` is pressed,
    if (!keyIsPressed(16)) { // Check if `Shift` wasN'T held.
      key = 0; // If `Shift` wasn't held, reset `key` to not be `Esc`, so the sketch does not close.
    } else {
      exit();
      //window.destroy(); // THAT WORKED?! *Does not anymore now that we have a proper way of exiting!*
    }


  if (keyCode == 107) {
    background(0);
    fullscreen = !fullscreen;
  }

  keysHeld.add(keyCode);

  // Calling this later so that our variables have the latest values:
  currentScene.keyPressed();

  for (Entity e : currentScene.entities)
    e.keyPressed();
}

void keyReleased() {  
  try {
    keysHeld.remove(keysHeld.indexOf(keyCode));
  }
  catch (IndexOutOfBoundsException e) {
  }

  // Calling this later so that our variables have the latest values:
  currentScene.keyReleased();
  for (Entity e : currentScene.entities)
    e.keyReleased();
}


// Context:
// [https://github.com/processing/processing/blob/8b15e4f548c1426df3a5ebe4c2106619faf7c4ba/
// core/src/processing/core/PApplet.java#L3181]

// Note: these functions cause random crashes if not used in this way.
// As a fallback method, use this (much safer) code inside `draw()`:

//if (focused && !pfocused) {
//println("Focused!");
//currentScene.onFocusGained();
//} else if (pfocused && !focused) {
//println("Lost focus!");
//currentScene.onFocusLost();
//}

// The reason why I'm not using that method is because these callbacks are more accurate.
// `focused` does not always remain updated, which was an issue I came to know of when I first used it.

// I have corrected this problem here by updating it here. Hope it stays working!

// PS these are available only for scenes to use. Entities probably won't need it.

void focusGained() {
  // For compatibility with newer versions of Processing, I guess:
  super.focusGained();

  focused = true;

  // I guess this works because `looping` is `false` for sometime after `handleDraw()`,
  // which is probably when events are handled:
  if (!looping)
    currentScene.focusGained();
}

void focusLost() {
  // For compatibility with newer versions of Processing, I guess:
  super.focusLost();

  focused = false;

  // I guess this works because `looping` is `false` for sometime after `handleDraw()`,
  // which is probably when events are handled:
  if (!looping)
    currentScene.focusLost();
}
