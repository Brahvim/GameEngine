// Fun Fact: these are the SAME as `javax.media.opengl.ClassName`:
import com.jogamp.newt.opengl.GLWindow;

// `PJOGL` holds references to `gl` and `glu`! (...and even the OpenGL `context`!)
// [file:///C:/Projects/ProcessingAll_JavaDocs/core/index.html]
//import com.jogamp.opengl.glu.GLU;
//import java.nio.FloatBuffer;

import java.awt.DisplayMode;
import java.awt.GraphicsDevice;
import java.awt.GraphicsEnvironment;
import java.lang.reflect.*;
import java.util.Map;
import java.util.Date;
import java.text.SimpleDateFormat;
import java.io.*;

// Deeper access into Processing's inner workings:
static GLWindow window;
static PGraphicsOpenGL glGraphics;
static PGL gl;
//GLU glu;
final PApplet SKETCH = this;
String SKETCH_NAME = this.getClass().getSimpleName();
static boolean INSIDE_PDE;
static String[] sketchArgs; // `sketchArgs.length` is only `1` when the application runs outside the PDE.
static String sketchPath;
static boolean fullscreen, pfullscreen;
static boolean pfocused;

Runnable onExit = null;

//final int INIT_WIDTH = 800, INIT_HEIGHT = 600;
final int INIT_WIDTH = 1280, INIT_HEIGHT = 720;
final float INIT_DEPTH = INIT_WIDTH + INIT_HEIGHT; // Super simple! No `sqrt()`.
float pwidth, pheight;

// Suggestion: use `SNAKE_CASE` for these?
// People won't always use `p_` or `m_` conventions like me and end up re-using these names...
float cx, cy;
float qx, qy;
float q3x, q3y;

final int TEXT_TEXTURE_SIZE = 72, 
  TEXT_TEXTURE_SIZE_2 = 2 * TEXT_TEXTURE_SIZE, 
  DEFAULT_TEXT_SIZE = 40;

GraphicsEnvironment javaGraphicsEnvironment;
GraphicsDevice[] javaScreens;

int REFRESH_RATE = 0;
int[] refreshRates;

float frameStartTime, deltaTime, pframeTime, frameTime;


// Failed to get these via reflection, copy-pasted them:
// [https://github.com/processing/processing/blob/master/core/src/processing/core/PGraphics.java]
static float[] sinLUT;
static float[] cosLUT;
static float SINCOS_PRECISION = 0.5f;
static int SINCOS_LENGTH = (int) (360.0f / SINCOS_PRECISION);

static {
  sinLUT = new float[SINCOS_LENGTH];
  cosLUT = new float[SINCOS_LENGTH];
  for (int i = 0; i < SINCOS_LENGTH; i++) {
    sinLUT[i] = (float) Math.sin(i * DEG_TO_RAD * SINCOS_PRECISION);
    cosLUT[i] = (float) Math.cos(i * DEG_TO_RAD * SINCOS_PRECISION);
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

void transform(PVector p_pos, PVector p_rot, PVector p_scale) {
  translate(p_pos.x, p_pos.y, p_pos.z);
  rotateX(p_rot.x);
  rotateY(p_rot.y);
  rotateZ(p_rot.z);
  scale(p_scale.x, p_scale.y, p_scale.z);
}

void push() {
  pushMatrix();
  pushStyle();
}

void pop() {
  popStyle();
  popMatrix();
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

// Processing Modifications:
void translate(PVector _v) {
  translate(_v.x, _v.y, _v.z);
}


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
  //if (p_out == null) p_out = new PVector(); // skipping for 'oPtImZiATion'.
  // ...this method remains unused in the engine. It's for users! :sparkles:

  p_out.set(p_from.x + (p_to.x - p_from.x) * p_lerpAmt, 
    p_from.y + (p_to.y - p_from.y) * p_lerpAmt, 
    p_from.z + (p_to.z - p_from.z) * p_lerpAmt);
}
