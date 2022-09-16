// Dr. Andrew Marsh's `gluUnProject()` code! ":D!~
// [http://andrewmarsh.com/blog/2011/12/04/gluunproject-p3d-and-opengl-sketches/]

//public class Selection_in_P3D_OPENGL_A3D {
public static class Unprojector {
  // True if near and far points calculated. Use `.isValid()` to access!
  private static boolean bValid = false;

  // Maintain own projection matrix.
  private static PMatrix3D pMatrix = new PMatrix3D();

  private static int[] aiViewport = new int[4];
  // ^^^ `ai` stands for "Array of Integers", apparently.

  // Store the near and far ray positions.
  public static PVector ptStartPos = new PVector();
  public static PVector ptEndPos = new PVector();

  public boolean isValid() {
    return bValid;
  }

  public static PMatrix3D getMatrix() {
    return pMatrix;
  }

  // Maintain own viewport data.
  public static int[] getViewport() {
    return aiViewport;
  }

  public static void captureViewMatrix(PGraphics3D p_g3d) {
    // Call this to capture the selection matrix after
    // you have called `perspective()` or `ortho()` and applied your
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

  public static boolean gluUnProject(float p_winx, float p_winy, float p_winz, PVector p_result) {
    // "A `memset()` is definitely better. Put these into the class?" - Brahvim.
    float[] in = new float[4];
    float[] out = new float[4];

    // Transform to NDCs (`-1` to `1`):
    in[0] = ((p_winx - (float)aiViewport[0]) / (float)aiViewport[2]) * 2.0f - 1.0f;
    in[1] = ((p_winy - (float)aiViewport[1]) / (float)aiViewport[3]) * 2.0f - 1.0f;
    in[2] = constrain(p_winz, 0, 1) * 2.0f - 1.0f;
    in[3] = 1.0f;

    // Calculate homogeneous coordinates:
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

    // Check for an invalid result:
    if (out[3] == 0.0f) { 
      p_result.x = 0.0f;
      p_result.y = 0.0f;
      p_result.z = 0.0f;
      return false;
    }

    // Scale to world coordinates:
    out[3] = 1.0f / out[3];
    p_result.x = out[0] * out[3];
    p_result.y = out[1] * out[3];
    p_result.z = out[2] * out[3];
    return true;
  }

  // Calculate positions on the near and far 3D frustum planes.
  public static boolean calculatePickPoints(float p_x, float p_y) {
    bValid = true; // Have to do both in order to reset the `PVector` in case of an error.
    // Brahvim: "Can't we optimize this?"...

    bValid = gluUnProject(p_x, p_y, 0, ptStartPos);
    bValid = gluUnProject(p_x, p_y, 1, ptEndPos);
    return bValid;

    // Original version:
    //if (!gluUnProject(p_x, p_y, 0, ptStartPos))
    //bValid = false;
    //if (!gluUnProject(p_x, p_y, 1, ptEndPos))
    //bValid = false;
    //return bValid;
  }
}





class SineWave {
  float angleOffset, freqMult, freq;
  float endTime = Float.MAX_VALUE - 1, aliveTime;
  boolean active = true, zeroWhenInactive;

  SineWave() {
  }

  SineWave(float p_freqMult) {
    this.freqMult = p_freqMult;
  }

  SineWave(float p_freqMult, float p_angleOffset) {
    this.freqMult = p_freqMult;
    this.angleOffset = /*radians(*/p_angleOffset;//);
  }

  void start() {
    this.aliveTime = 0;
  }

  void start(float p_angleOff) {
    this.aliveTime = 0;
    this.angleOffset = p_angleOff;
  }

  void setAngleOffset(float p_angleOff) {
    this.angleOffset = p_angleOff;
  }

  void end() {
    this.endTime = 0;
  }

  void endIn(float p_millis) {
    this.endTime = this.aliveTime + p_millis;
  }

  void endWhenAngleIs(float p_angle) {
    this.endTime = this.aliveTime + (p_angle * (p_angle * this.freqMult) - this.angleOffset);
  }

  void extendEndBy(float p_millis) {
    this.endTime += p_millis;
  }

  void extendEndByAngle(float p_angle) {
    this.endTime += (p_angle * (p_angle * this.freqMult) - this.angleOffset);
  }

  float getStartTime() {
    return millis() - this.aliveTime;
  }

  float getTimeSinceStart() {
    return this.aliveTime;
  }

  float getEndTime() {
    return this.endTime;
  }

  float get() {
    this.active = this.aliveTime <= this.endTime;

    if (this.active)
      this.aliveTime += frameTime; // `frameTime` comes from the Engine by the way.
    else if (this.zeroWhenInactive)
      return 0;

    this.freq = this.aliveTime * this.freqMult + this.angleOffset;
    return sin(this.freq);
    // That looked like a matrix calculation LOL.
  }
}
