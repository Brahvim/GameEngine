

// YO! Go work on the Renderer class.
// The `update()` method's `switch` needs stuff to draw! (For `SPHERE`!)
// Also, get it textured! :joy: 

// It's in the "Components" tab.
// Go, go, go! ":D!


void settings() {
  size(INIT_WIDTH, INIT_HEIGHT, P3D);
  smooth(-1);
  PJOGL.setIcon("sunglass_nerd.png");
  //PJOGL.setIcon(new String[]{"sunglass_nerd.png"});
  // For when you need to provide multiple resolution icons yourself!
}


// This used to be an overload for `exit()`.
void dispose() {
  //window.setVisible(false);
  //while (window.isVisible());

  super.dispose();
  logInfo("`engineExit()` called...");

  if (onExit != null)
    onExit.run();

  Log.logFile.setWritable(false);
  Log.fileLogger.flush();
  Log.fileLogger.close();

  if (Log.openFileOnExit)
  try {
    println("Find the log file at: " + Log.filePath);
    new ProcessBuilder("notepad", Log.logFile.getAbsolutePath()).start();
  }
  catch(IOException ioe) {
  }

  // With proper monitoring of window fullscreen events in `post()` now, this is superfast :D
  //super.exit(); // This is now `dispose()` and not `exit()`.

  // Fun fact: `Ctrl + G` continues to search for the text you last searched for.

  //window.destroy(); // Faster, but might let the application stop responding completely!
  // No longer needed though :D
}

void setup() {
  //new TTS().speak(new File("").getAbsolutePath());
  updateRatios();

  posted = createGraphics(INIT_WIDTH, INIT_HEIGHT, P3D);

  // Should load this up from a save file (or a `--smooth` argument from the launcher):
  //int a = 2;
  //smooth(a);
  // `smooth()`can be called in `setup()` :D

  surface.setTitle("Nerd Engine");
  cursor(loadImage("Unnamed_RPG_cursor.png"), -4, -4);

  //g = createPrimaryGraphics(); // Super important discovery!
  // [https://github.com/processing/processing/blob/8b15e4f548c1426df3a5ebe4c2106619faf7c4ba/
  // core/src/processing/core/PApplet.java#L2343]

  String sketchArgsStr = System.getProperty("sun.java.command");
  sketchArgs = sketchArgsStr.split(" ");
  INSIDE_PDE = sketchArgs.length == 3 && 
    sketchArgs[1].contains("display") && sketchArgs[2].contains("sketch-path");

  sketchPath = INSIDE_PDE ? sketchArgs[2].substring(14, sketchArgs[2].length()) + "\\"
    : sketchPath();

  println(new File(sketchPath("lib\\")).getAbsolutePath());

  // Library initialization:
  //fx = new PostFX(this);
  fxApplier = new PostFXSupervisor(this);
  Fisica.init(this);
  NativeLibraryLoader.loadLibbulletjme(true, 
    new File("C:\\ProcessingSketches\\libraries\\LibBulletJME\\library\\"), 
    //new File("./lib\\"), 
    "Release", "Sp");

  uibd = new UiBooster(UiBoosterOptions.Theme.DARK_THEME);
  uibn = new UiBooster(UiBoosterOptions.Theme.OS_NATIVE);
  uibs = new UiBooster(UiBoosterOptions.Theme.SWING);

  initLog();

  logInfo("Sketch arguments:");
  logInfo(sketchArgsStr);

  //NativeLibraryLoader.loadLibbulletjme(true, new File("./lib"), "Release", "Sp");

  window = (GLWindow)surface.getNative();
  glGraphics = (PGraphicsOpenGL)g;

  /*
    // Javadoc:
   // [C:\Users\Brahvim\Documents\PC stuff I always want with me\jogl-javadoc
   // \jogl\javadoc\com\jogamp\nativewindow\SurfaceUpdatedListener.html]
   
   //import com.jogamp.nativewindow.SurfaceUpdatedListener;
   //import com.jogamp.nativewindow.NativeSurface;
   
   window.addSurfaceUpdatedListener(0, new SurfaceUpdatedListener() {
   public void surfaceUpdated(Object updater, NativeSurface ns, long when) {
   println("Surface updated!");
   }
   }
   );
   */

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

  if (REFRESH_RATE == DisplayMode.REFRESH_RATE_UNKNOWN)
    REFRESH_RATE= -1;

  frameRate(REFRESH_RATE);

  surface.setResizable(true);
  surface.setSize(INIT_WIDTH, INIT_HEIGHT);
  centerWindow();

  registerMethod("pre", this);
  registerMethod("post", this);

  rectMode(CENTER);
  imageMode(CENTER);

  textFont(createFont("SansSerif", TEXT_TEXTURE_SIZE));
  textSize(DEFAULT_TEXT_SIZE);
  textAlign(CENTER, CENTER);

  /*
    Method[] sketchMethods = this.getClass().getDeclaredMethods();
   Method engineSetupMethod = null;
   
   for (Method m : sketchMethods) {
   if (m.getName() == "engineSetup") {
   engineSetupMethod = m;
   break;
   }
   }
   
   if (engineSetupMethod == null)
   if (SCENES.size() > 0)
   setScene(SCENES.get(0));
   else try{
   // You have to pass an object instance if the method isn't static.
   // If the method is parameterless, pass `null`.
   // Else, pass parameters into `invoke()` - it is a `varargs` method.
   // The return value of the method called, is what `invoke` returns, as well.
   engineSetupMethod.invoke(this);
   }  
   catch(Exception e) {
   }
   */

  engineSetup();
}

void pre() {
  mouseScrollDelta = mouseScroll - pmouseScroll;

  if (!(pwidth == width || pheight == height)) {
    posted.setSize(width, height);
    fxApplier.setResolution(width, height);
    updateRatios();
    currentScene.windowResized();
  }
}

// Trying to ONLY keep things, that need rendering, here:
void draw() {
  frameStartTime = millis(); // Timestamp.
  frameTime = frameStartTime - pframeTime;
  pframeTime = frameStartTime;
  deltaTime = frameTime * 0.01f;

  // OpenGL reference:
  gl = beginPGL();
  //gl.enable(PGL.CULL_FACE);
  //gl.cullFace(PGL.FRONT); // :(
  //gl.frontFace(PGL.CCW);
  // Everything else works by the way : D
  //flush();

  // Start *post Processing!:*
  fxApplier.render();
  lights(); //camera(); // `action();`! ";D!

  // Apply transformations first, so
  // that entities can use methods such
  // as `modelX()`, and check matrices.

  push();
  // Unproject the mouse position:
  if (!camIsLerp) {
    float originalNear = currentCam.near;
    currentCam.near = currentCam.mouseZ;
    currentCam.apply();

    // Unproject:
    Unprojector.captureViewMatrix((PGraphics3D)g);
    // `0.9f`: at the near clipping plane.
    // `0.9999f`: at the far clipping plane.
    Unprojector.gluUnProject(mouseX, height - mouseY, 
      //0.9f+ map(mouseY, height, 0, 0, 0.1f),
      0, mouse);
    currentCam.near = originalNear;
    currentCam.apply();
  }

  for (Component c : currentScene.components)
    if (!(c instanceof Renderer))
      c.update();

  currentScene.draw();

  for (Entity e : currentScene.entities)
    if (e.enabled)
      e.update();

  //if (focused) // I applied this check EVEN to post processing as well but GPU remained unchanged.
  for (Renderer r : currentScene.renderers) {
    r.parent.render();
    if (r.enabled)
      r.update();
  }

  // Step the Physics Engines later, because...
  // I'd like to be at the origin of the world on my first frame...
  // Also, the user changes Physics- related data in their updates.
  if (b2d != null && b2dShouldUpdate)
    b2d.step(deltaTime);

  if (bt!= null && btShouldUpdate)
    bt.update(deltaTime);
  pop();

  // Post processing:
  // (...get it? :rofl:)



  //endPGL();
}

// Ayo, do the post - update!:
void post() {
  // YOU CAN RENDER HERE APPARENTLY!:
  // (Might break libraries :|)

  blendMode(SCREEN);
  image(fxApplier.getCurrentPass(), cx, cy);
  blendMode(BLEND);

  noLights();
  begin2D();
  currentScene.drawUI();
  end2D();

  endPGL();

  pwidth = width;
  pheight = height;
  pfocused = focused;

  pmouse.set(mouse);
  pmouseLeft = mouseLeft;
  pmouseMid = mouseMid;
  pmouseRight = mouseRight;
  pmouseScroll = mouseScroll;

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

  // Doing this in the end as a test:
  for (Asset a : ASSETS)
    a.ploaded = a.loaded;
}

void mousePressed() {
  lastMousePressTime = millis();
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
  lastKeyPressTime = millis();

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
  catch(IndexOutOfBoundsException ioobe) {
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
