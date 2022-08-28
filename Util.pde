// My `SineWave` utility! Written on mobile!
class SineWave {
  private float angleOffset, 
    beginOffset, freqMult;
  private int endFrame, endFrameMinusOne;
  private boolean useFrames;

  // Right here! Public stuff!:
  boolean active = true;
  float freq;

  SineWave() {
  }

  SineWave(float p_freqMult) {
    this.freqMult = p_freqMult;
  }

  SineWave(float p_freqMult, 
    float p_angleOffset) {
    this.freqMult = p_freqMult;
    this.angleOffset
      = radians(p_angleOffset);
  }

  void useFrames(boolean p_b) {
    this.useFrames = p_b;
  }

  void endIn(int p_frame) {
    this.useFrames = true;

    this.endFrame 
      = frameCount + p_frame;
  }

  void endWhenAngleAccumulatesTo(float p_angle) {
    this.useFrames = true;

    this.endFrame
      = frameCount
      + (int)(p_angle * 
      (p_angle * this.freqMult)
      - this.angleOffset);

    this.endFrameMinusOne
      = this.endFrame - 1;
  }

  void set() {
    this.beginOffset = this.useFrames?
      frameCount : millis();
  }

  void set(float p_angleOffset) {
    this.angleOffset
      = radians(p_angleOffset);
    this.beginOffset = this.useFrames?
      frameCount : millis();
  }

  void setFreqMult(
    float p_freqMult) {
    this.freqMult = p_freqMult;
  }

  float get() {
    if (frameCount == this.endFrameMinusOne)
      this.active = false;

    // No options for optimization
    // here, but hey, it's awesome!:
    if (frameCount < this.endFrame)
      return sin(this.freq
        = (((this.useFrames? 
        frameCount : millis())
        - this.beginOffset)
        * this.freqMult
        + this.angleOffset));

    return 0;
  }
}





// Dr. Andrew Marsh's `gluUnProject()` code! ":D!~
// [http://andrewmarsh.com/blog/2011/12/04/gluunproject-p3d-and-opengl-sketches/]

//public class Selection_in_P3D_OPENGL_A3D {
public static class Unprojector {
  // True if near and far points calculated.
  public boolean isValid() { 
    return bValid;
  }

  private static boolean bValid = false;

  // Maintain own projection matrix.
  public static PMatrix3D getMatrix() { 
    return pMatrix;
  }

  private static PMatrix3D pMatrix = new PMatrix3D();

  // Maintain own viewport data.
  public static int[] getViewport() { 
    return aiViewport;
  }

  private static int[] aiViewport = new int[4];

  // Store the near and far ray positions.
  public static PVector ptStartPos = new PVector();
  public static PVector ptEndPos = new PVector();

  // -------------------------

  public static void captureViewMatrix(PGraphics3D p_g3d) {
    // Call this to capture the selection matrix after
    // you have called perspective() or ortho() and applied your
    // pan, zoom and camera angles - but before you start drawing
    // or playing with the matrices any further.


    // Check for a valid 3D canvas.

    // Capture current projection matrix.
    //pMatrix.set(p_g3d.projection);

    // Multiply by current modelview matrix.
    //pMatrix.apply(p_g3d.modelview);

    // Invert the resultant matrix.
    //pMatrix.invert();

    // "Couldn't we do this in today's modern world?:" 
    // - Brahvim
    //
    pMatrix.set(p_g3d.projmodelview);
    pMatrix.invert();

    // Store the viewport.
    aiViewport[0] = 0;
    aiViewport[1] = 0;
    aiViewport[2] = p_g3d.width;
    aiViewport[3] = p_g3d.height;
  }

  // -------------------------

  public static boolean gluUnProject(float winx, float winy, float winz, PVector result) {
    float[] in = new float[4];
    float[] out = new float[4];

    // Transform to normalized screen coordinates (-1 to 1).
    in[0] = ((winx - (float)aiViewport[0]) / (float)aiViewport[2]) * 2.0f - 1.0f;
    in[1] = ((winy - (float)aiViewport[1]) / (float)aiViewport[3]) * 2.0f - 1.0f;
    in[2] = constrain(winz, 0f, 1f) * 2.0f - 1.0f;
    in[3] = 1.0f;

    // Calculate homogeneous coordinates.
    out[0] = pMatrix.m00 * in[0]
      + pMatrix.m01 * in[1]
      + pMatrix.m02 * in[2]
      + pMatrix.m03 * in[3];
    out[1] = pMatrix.m10 * in[0]
      + pMatrix.m11 * in[1]
      + pMatrix.m12 * in[2]
      + pMatrix.m13 * in[3];
    out[2] = pMatrix.m20 * in[0]
      + pMatrix.m21 * in[1]
      + pMatrix.m22 * in[2]
      + pMatrix.m23 * in[3];
    out[3] = pMatrix.m30 * in[0]
      + pMatrix.m31 * in[1]
      + pMatrix.m32 * in[2]
      + pMatrix.m33 * in[3];

    // Check for an invalid result.
    if (out[3] == 0.0f) { 
      result.x = 0.0f;
      result.y = 0.0f;
      result.z = 0.0f;
      return false;
    }

    // Scale to world coordinates.
    out[3] = 1.0f / out[3];
    result.x = out[0] * out[3];
    result.y = out[1] * out[3];
    result.z = out[2] * out[3];
    return true;
  }

  // Calculate positions on the near and far 3D frustum planes.
  public static boolean calculatePickPoints(int x, int y) { 
    bValid = true; // Have to do both in order to reset PVector on error.
    if (!gluUnProject((float)x, (float)y, 0.0f, ptStartPos)) bValid = false;
    if (!gluUnProject((float)x, (float)y, 1.0f, ptEndPos)) bValid = false;
    return bValid;
  }
}

// Next Utility:
// ...
