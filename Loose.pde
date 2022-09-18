// Fun Fact: these are the SAME as `javax.media.opengl.ClassName`:
import com.jogamp.newt.opengl.GLWindow;

// `PJOGL` holds references to `gl` and `glu`! (...and even the OpenGL context!)
// [file:///C:/Projects/ProcessingAll_JavaDocs/core/processing/opengl/PJOGL.html]
//import com.jogamp.opengl.glu.GLU;
//import java.nio.*; //FloatBuffer;

// These are also interesting:
//println(PJOGL.WIKI);
//println(PJOGL.VERSION);
//println(PJOGL.profile);
//println(PJOGL.SAMPLES);

import java.awt.DisplayMode;
import java.awt.GraphicsDevice;
import java.awt.GraphicsEnvironment;
import java.lang.reflect.*;
import java.util.Map;
import java.util.Date;
import java.text.SimpleDateFormat;
import java.awt.event.KeyEvent;


// The one. The only one:
final PApplet SKETCH = this;

// DO NOT use `getFields()`! That will scan for ones from `super` classes as well!:
final Field[] SKETCH_FIELDS = SKETCH.getClass().getDeclaredFields();

// Deeper access into Processing's inner workings:
GLWindow window;
PGraphicsOpenGL glGraphics;
PGL gl;

//GLU glu; // Don't need a reference to GL-Utilities now that we have the `Unprojector` class :D
// These are best retrieved from Processing, by the way.
// `PJOGL` has them, as stated in a comment on line 4 of this `.pde` file.

final Sound SOUND = new Sound(this);
String[] soundDevices; // Should use OpenAL to provide these, but JSyn handles device changes very well.
Runnable onExit = null;

// Environment identification:
final String SKETCH_NAME = SKETCH.getClass().getSimpleName();
boolean INSIDE_PDE;
String sketchArgsStr;
String[] sketchArgs; // `sketchArgs.length` is only `1` when the application runs outside the PDE.
String sketchPath; // Do I actually need this?

// Windowing and co-ordinates:
boolean fullscreen, pfullscreen;
boolean pfocused;

// `doAnyDrawing` refers to both UI and world rendering.
boolean doUpdates = true, doAnyDrawing = true, 
  doRendering = true, doUIRendering = true, 
  doCamera = true, doLights = true;

//final int INIT_WIDTH = 800, INIT_HEIGHT = 600;
final static int INIT_WIDTH = 1280, INIT_HEIGHT = 720;
final static float INIT_DEPTH = INIT_WIDTH + INIT_HEIGHT; // Super simple! No `sqrt()`.
float pwidth, pheight;

// Getting the refresh rate and number of display, etcetera:
GraphicsEnvironment javaGraphicsEnvironment;
GraphicsDevice[] javaScreens;
int REFRESH_RATE = 0;
int[] refreshRates;

// Suggestion: use `SNAKE_CASE` for these?
// People won't always use the `p_` convention like me for parameters and end up re-using these names...
float cx, cy;
float qx, qy;
float q3x, q3y;

final int TEXT_TEXTURE_SIZE = 72, 
  TEXT_TEXTURE_SIZE_2 = 2 * TEXT_TEXTURE_SIZE, 
  DEFAULT_TEXT_SIZE = 40;

// Timing and status:
float frameStartTime, deltaTime, pframeTime, frameTime;
boolean frameDidUpdate, frameDidComponentUpdate, frameDidSceneUpdate, frameDidEntityUpdate;
boolean frameDidRender, frameDidPhysics, frameDidUI;
boolean preBegun, preEnded, drawBegun, drawEnded, postBegun, postEnded;
//long millisBegin; // `PApplet.millisOffset` is not visible, so I made this!.
// `PApplet.millis()` starts counting from when the class is instantiated, and returns an `int`.
// Bad, bad, bad!
// The overload in this class returns a long, and starts at the end of `setup()`.
// Wait, I can't overload it, *my bad!* :sweat_smile:


// From the sphere texturing example from APDE.
final int SPHERE_DETAIL = 36;
float[] sphereCX, sphereCZ, sphereX, sphereY, sphereZ;
float sinLUT[];
float cosLUT[];
float SINCOS_PRECISION = 0.5f;
int SINCOS_LENGTH = (int)(360.0f / SINCOS_PRECISION);

// Failed to get these via reflection, copy-pasted them. I hope I use these at some point!:
// [https://github.com/processing/processing/blob/master/core/src/processing/core/PGraphics.java]
//static float[] sinLUT;
//static float[] cosLUT;
//static float SINCOS_PRECISION = 0.5f;
//static int SINCOS_LENGTH = (int) (360.0f / SINCOS_PRECISION);

//static {
//  sinLUT = new float[SINCOS_LENGTH];
//  cosLUT = new float[SINCOS_LENGTH];
//  for (int i = 0; i < SINCOS_LENGTH; i++) {
//    sinLUT[i] = (float) Math.sin(i * DEG_TO_RAD * SINCOS_PRECISION);
//    cosLUT[i] = (float) Math.cos(i * DEG_TO_RAD * SINCOS_PRECISION);
//  }
//}

// The `PostFX` library:
//import ch.bildspur.postfx.builder.*;
//import ch.bildspur.postfx.pass.*;
//import ch.bildspur.postfx.*;

//PostFXSupervisor fx;
//boolean doPostProcessing, doPostProcessingState;
//void applyPass(Pass p_pass) {
//if (this.doPostProcessingState)
//fx.pass(p_pass);
//}

@FunctionalInterface
  interface AnonFxn {
  public void run(Object... p_args);
}

@FunctionalInterface
  interface OnCatch {
  public void run(Exception p_except);
}

void initSphere(int p_resolution) {
  sinLUT = new float[SINCOS_LENGTH];
  cosLUT = new float[SINCOS_LENGTH];

  float a;
  for (int i = 0; i < SINCOS_LENGTH; i++) {
    a = i * DEG_TO_RAD * SINCOS_PRECISION;
    sinLUT[i] = sin(a);
    cosLUT[i] = cos(a);
  }

  float delta = (float) SINCOS_LENGTH / p_resolution;
  float[] cxVal = new float[p_resolution];
  float[] czVal = new float[p_resolution];

  // Calculate a unit circle in the `X`-`Z` plane:
  for (int i = 0; i < p_resolution; i++) {
    cxVal[i] = -cosLUT[(int) (i * delta) % SINCOS_LENGTH];
    czVal[i] = sinLUT[(int) (i * delta) % SINCOS_LENGTH];
  }

  // Computing vertices - they start at the south pole:
  int vertCount = p_resolution * (p_resolution - 1) + 2;
  int currVert = 0;

  // Re-init arrays to store vertices:
  sphereX = new float[vertCount];
  sphereY = new float[vertCount];
  sphereZ = new float[vertCount];
  float angleStep = (SINCOS_LENGTH * 0.5f) / p_resolution;
  float angle = angleStep;

  // Step along Y axis:
  for (int i = 1; i < p_resolution; i++) {
    float curRad = sinLUT[(int) angle % SINCOS_LENGTH];
    float curY = -cosLUT[(int) angle % SINCOS_LENGTH];

    for (int j = 0; j < p_resolution; j++) {
      sphereX[currVert] = cxVal[j] * curRad;
      sphereY[currVert] = curY;
      sphereZ[currVert++] = czVal[j] * curRad;
    }

    angle += angleStep;
  }
}

void updateRatios() {
  cx = width * 0.5f;
  cy = height * 0.5f;
  qx  = cx * 0.5f;
  qy  = cx * 0.5f;
  q3x = cx + qx;
  q3y = cy + qy;
}

// Now that the `Transform` class has `applyMatrix()`, well...
//void transform(PVector p_pos, PVector p_rot, PVector p_scale) {
//  translate(p_pos.x, p_pos.y, p_pos.z);
//  rotateX(p_rot.x);
//  rotateY(p_rot.y);
//  rotateZ(p_rot.z);
//  scale(p_scale.x, p_scale.y, p_scale.z);
//}

void camera(Camera p_cam) {
  camera(p_cam.pos.x, p_cam.pos.y, p_cam.pos.z, 
    p_cam.center.x, p_cam.center.y, p_cam.center.z, 
    p_cam.up.x, p_cam.up.y, p_cam.up.z);
}

void perspective(Camera p_cam) {
  perspective(p_cam.fov, (float)width / (float)height, p_cam.near, p_cam.far);
}

void ortho(Camera p_cam) {
  ortho(-cx, cx, -cy, cy, p_cam.near, p_cam.far);
}

void begin2D() {
  hint(DISABLE_DEPTH_TEST);
  pushMatrix();
  pushStyle();
}

void end2D() {
  hint(ENABLE_DEPTH_TEST);
  popStyle();
  popMatrix();
}

// Processing Modifications (inherited from `PApplet`):
void translate(PVector p_v) {
  translate(p_v.x, p_v.y, p_v.z);
}

// These simply don't work LOL:
void push() {
  pushMatrix();
  pushStyle();
}

void pop() {
  popStyle();
  popMatrix();
}

PImage svgToImage(PShape p_shape, float p_width, float p_height) {
  if (p_shape == null)
    new NullPointerException("`svgToImage(null , p_width, p_height)` won't work.").printStackTrace();

  PGraphics buffer = createGraphics((int)ceil(p_width), (int)ceil(p_height), P3D);

  if (buffer == null)
    new NullPointerException("`buffer` is `null`!").printStackTrace();

  buffer.beginDraw();
  buffer.shape(p_shape, 0, 0, p_width, p_height);
  buffer.endDraw();
  return buffer;
}

PImage svgToImage(Asset p_shapeLoader, float p_width, float p_height) {
  PGraphics buffer = createGraphics((int)ceil(p_width), (int)ceil(p_height), P3D);
  //while (!p_shapeLoader.loaded);

  buffer.beginDraw();
  buffer.shape(p_shapeLoader.asShape(), 0, 0, p_width, p_height);
  buffer.endDraw();
  return buffer;
}

PGraphics createGraphics(int p_width, int p_height) {
  return createGraphics(p_width, p_height, P3D);
}

PGraphics createGraphics(float p_width, float p_height) {
  return createGraphics((int)p_width, (int)p_height, P3D);
}

void image(PImage p_image) {
  super.image(p_image, 0, 0);
}

void image(Asset p_imageAsset) {
  if (p_imageAsset.loaded)
    super.image(p_imageAsset.asImage(), 0, 0);
}

void image(Asset p_imageAsset, float p_x, float p_y) {
  if (p_imageAsset.loaded)
    super.image(p_imageAsset.asImage(), p_x, p_y);
}

void image(Asset p_imageAsset, float p_x, float p_y, float p_width, float p_height) {
  if (p_imageAsset.loaded)
    super.image(p_imageAsset.asImage(), p_x, p_y, p_width, p_height);
}


// ..I'll let the underscores remain. Nostalgia...
// I feel cold inside when I see these functions...


// Using these where `static` 
// methods cause issues:

PVector normalize(PVector _v) {
  return new PVector(_v.x, _v.y, _v.z).normalize();
}

PVector cross(PVector _a, PVector _b) {
  return new PVector(_a.x, _a.y, _a.z).cross(_b);
}

float dot(PVector _a, PVector _b) {
  return new PVector(_a.x, _a.y, _a.z).dot(_b);
}

PVector mult(PVector _v, float _f) { 
  return new PVector(_v.x, _v.y, _v.z).mult(_f);
}

void centerWindow() {
  updateRatios();
  // Remember: computers with multiple displays exist! We shouldn't cache this:
  window.setPosition((int)(displayWidth / 2 - cx), (int)(displayHeight / 2 - cy));
}

PVector vecLerp(PVector p_from, PVector p_to, float p_lerpAmt) {
  return new PVector(p_from.x + (p_to.x - p_from.x) * p_lerpAmt, 
    p_from.y + (p_to.y - p_from.y) * p_lerpAmt, 
    p_from.z + (p_to.z - p_from.z) * p_lerpAmt);
}

void vecLerp(PVector p_from, PVector p_to, float p_lerpAmt, PVector p_out) {
  //if (p_out == null) p_out = new PVector(); // Skipping for 'oPtImZiATion'.
  // ...this method remains unused in the engine. It's for users! :sparkles:

  p_out.set(p_from.x + (p_to.x - p_from.x) * p_lerpAmt, 
    p_from.y + (p_to.y - p_from.y) * p_lerpAmt, 
    p_from.z + (p_to.z - p_from.z) * p_lerpAmt);
}
