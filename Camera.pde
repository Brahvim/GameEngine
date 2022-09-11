final ArrayList<Camera> CAMERAS = new ArrayList<Camera>();
Camera currentCam, 
  lerpeable; // `lerpeable` is allocated all the time during lerps, don't do that right now.


final PVector DEFAULT_CAM_POS = new PVector(INIT_WIDTH / 2, INIT_HEIGHT / 2, 300), 
  DEFAULT_CAM_CENTER = new PVector(INIT_WIDTH / 2, INIT_HEIGHT / 2, 0), 
  DEFAULT_CAM_UP = new PVector(0, 1, 0);

final static float DEFAULT_CAM_FOV = radians(60), 
  DEFAULT_CAM_NEAR = 0.05f, DEFAULT_CAM_FAR = 10000;

final Camera DEFAULT_CAMERA = new Camera(
  DEFAULT_CAM_POS, DEFAULT_CAM_CENTER, DEFAULT_CAM_UP, 
  DEFAULT_CAM_FOV, DEFAULT_CAM_NEAR, DEFAULT_CAM_FAR);


boolean camLerpRequest, pcamLerpRequest, camIsLerp = false, camLerpMouse = true;
float camLerpAmt;
Camera camToLerpFrom, camToLerpTo;
SineWave camLerpWave;

void setCam(Camera p_camera) {
  currentCam = p_camera;
}

void startCamLerp(Camera p_from, Camera p_to) {
  //camIsLerp = true; // If you're gunna call `camLerpUpdate()` anyway, why this?
  camToLerpFrom = p_from;
  camToLerpTo = p_to;
}

void updateCam() {
  if (currentCam != null) {
    if (currentCam.script != null)
      currentCam.script.run(currentCam);
    currentCam.applyMatrix();
  }
}

void updateCam(Camera p_cam) {
  if (p_cam != null)
    if (p_cam.script != null)
      p_cam.script.run(p_cam);
}

void camLerpUpdate(Camera p_from, Camera p_to, float p_lerpAmt) {
  camLerpUpdate(p_from, p_to, p_lerpAmt, 0, 1);
}

void camLerpUpdate(Camera p_from, Camera p_to, float p_lerpAmt, float p_start, float p_stop) {
  camIsLerp = true;
  // Update both cameras:
  updateCam(p_from);
  updateCam(p_to);

  // Set the current settings to the lerping camera's:
  lerpeable = p_from.copy();

  // Skip the calculations in these edge cases:
  if (p_lerpAmt > p_stop) {
    setCam(p_to);
    lerpeable.clearColor = color(red(p_to.clearColor), 
      green(p_to.clearColor), blue(p_to.clearColor), 255);
    if (p_to.doAutoClear)
      lerpeable.clear();
    p_to.applyMatrix();
    camIsLerp = false;
    return;
  } else if (p_lerpAmt < p_start) {
    setCam(p_from);
    lerpeable.clearColor = color(red(p_from.clearColor), 
      green(p_from.clearColor), blue(p_from.clearColor), 255);
    if (p_from.doAutoClear)
      lerpeable.clear();
    p_from.applyMatrix();
    camIsLerp = false;
    return;
  }

  // Lerp!:

  // "HERE YOU GO >:("
  lerpeable.up.x = p_from.up.x + (p_to.up.x - p_from.up.x) * p_lerpAmt;
  lerpeable.up.y = p_from.up.y + (p_to.up.y - p_from.up.y) * p_lerpAmt; 
  lerpeable.up.z = p_from.up.z + (p_to.up.z - p_from.up.z) * p_lerpAmt;

  lerpeable.center.x = p_from.center.x + (p_to.center.x - p_from.center.x) * p_lerpAmt; 
  lerpeable.center.y =  p_from.center.y + (p_to.center.y - p_from.center.y) * p_lerpAmt;
  lerpeable.center.z =  p_from.center.z + (p_to.center.z - p_from.center.z) * p_lerpAmt;

  lerpeable.pos.x = p_from.pos.x + (p_to.pos.x - p_from.pos.x) * p_lerpAmt;
  lerpeable.pos.y = p_from.pos.y + (p_to.pos.y - p_from.pos.y) * p_lerpAmt;
  lerpeable.pos.z = p_from.pos.z + (p_to.pos.z - p_from.pos.z) * p_lerpAmt;

  // ...let's not lerp that..?
  if (camLerpMouse)
    lerpeable.mouseZ = p_from.mouseZ + (p_to.mouseZ - p_from.mouseZ) * p_lerpAmt;

  // Remember: if your FOV changes, the `z` position of the camera must, as well.
  lerpeable.fov = p_from.fov + (p_to.fov - p_from.fov) * p_lerpAmt;
  lerpeable.far = p_from.far + (p_to.far - p_from.far) * p_lerpAmt;
  lerpeable.near = p_from.near + (p_to.near - p_from.near) * p_lerpAmt;
  lerpeable.clearColor = lerpColor(p_from.clearColor, p_to.clearColor, p_lerpAmt);

  //lerpeable.apply(); // Doesn't work for some reason.
  lerpeable.clear();
  lerpeable.applyMatrix();
}

@FunctionalInterface
  interface CamScript {
  // Every camera object willing to update itself with
  // a specified script will have to pass itself into this function:
  public void run(Camera p_cam);
  // This was done to ensure scripts can be shared between camera copies
  // by passing them by reference.
}

class Camera extends Entity {
  PVector pos, center, up;
  float fov = DEFAULT_CAM_FOV, near = 0.05f, far = 10000, mouseZ = 25;
  CamScript script;
  color clearColor = color(0);
  boolean doScript = true, doAutoClear = true;
  int projection = PERSPECTIVE;

  Camera() {
    this.up = new PVector(0, 1, 0);
    this.center = new PVector(0, 0, 0);
    this.pos = new PVector(0, 0, 0);
  }

  Camera(float p_fov, float p_near, float p_far) {
    this.fov = p_fov;
    this.far = p_far;
    this.near = p_near;
  }

  Camera(PVector p_pos, PVector p_center, PVector p_up) {
    this.up = p_up;
    this.pos = p_pos;
    this.center = p_center;
  }

  Camera(PVector p_pos, PVector p_center, PVector p_up, 
    float p_fov, float p_near, float p_far) {
    this.up = p_up;
    this.pos = p_pos;
    this.center = p_center;

    this.fov = p_fov;
    this.far = p_far;
    this.near = p_near;
  }

  void apply() {
    // #JIT_FTW!:
    this.clear();
    this.runScript();
    this.applyMatrix();
  }

  void runScript() {
    if (this.script != null && this.doScript)
      this.script.run(this);
  }

  void clear() {
    begin2D();
    camera(); // Removing this will not display the previous camera's view, but still show clipping.
    rectMode(CORNER);
    noStroke();
    fill(this.clearColor);
    //rect(-width * 2.5f, -height * 2.5f, width * 7.5f, height * 7.5f);
    rect(0, 0, width, height);
    end2D();
  }

  void applyMatrix() {
    switch (this.projection) {
    case PERSPECTIVE:
      perspective(this.fov, (float)width / (float)height, this.near, this.far);
      break;
    case ORTHOGRAPHIC:
      ortho(-cx, cx, -cy, cy, this.near, this.far);
    }

    camera(this.pos.x, this.pos.y, this.pos.z, 
      this.center.z, this.center.y, this.center.z, 
      this.up.x, this.up.y, this.up.z);

    //translate(-cx, -cy);
  }

  void reset() {
    this.up = new PVector(0, 1, 0);
    this.center = new PVector(cx, cy, 0);
    this.pos = new PVector(cx, cy, 0);
    this.fov = radians(60);
    this.near = 0.1f; 
    this.far = 10000;
  }

  Camera copy() {
    Camera ret = new Camera(this.pos, this.center, this.up, this.fov, this.near, this.far);
    ret.script = this.script;
    return ret;
  }
}
