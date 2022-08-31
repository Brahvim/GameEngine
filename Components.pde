class Transform extends Component {
  PVector pos, rot, scale;
  private PMatrix3D mat;

  Transform(Entity p_entity) {
    super(p_entity);

    this.pos = new PVector();
    this.rot = new PVector();
    this.scale = new PVector(1, 1, 1);
    this.mat = new PMatrix3D();
  }

  Transform(Entity p_entity, PVector p_pos) {
    super(p_entity);

    this.pos = p_pos;
    this.rot = new PVector();
    this.scale = new PVector();
    this.mat = new PMatrix3D();
  }

  Transform(Entity p_entity, PVector p_pos, PVector p_rot, PVector p_scale) {
    super(p_entity);

    this.pos = p_pos;
    this.rot = p_rot;
    this.scale = p_scale;
    this.mat = new PMatrix3D();
  }

  public void set(Transform p_form) {
    if (p_form == null)
      throw new NullPointerException(
        "`Transform.set()` received a `null` `Transform` object :|");
    this.pos = p_form.pos.copy();
    this.rot = p_form.rot.copy();
    this.scale = p_form.scale.copy();
  }

  public void applyMatrix() {
    // Nobody needs *so* much function call reduction:
    SKETCH.applyMatrix(this.getRefreshedMatrix());
    // Who knows? The JIT might optimize `getRefreshedMatrix()`, too!
  }

  public PMatrix3D getRefreshedMatrix() {
    // Stop doing all of this!:
    //this.mat.reset(); // Sets it to an identity matrix.
    //this.mat.translate(this.pos.x, this.pos.y, this.pos.z);
    //this.mat.rotateX(this.rot.x);
    //this.mat.rotateY(this.rot.y);
    //this.mat.rotateZ(this.rot.z);
    //this.mat.scale(this.scale.x, this.scale.y, this.scale.z);

    // JIT for the win! All three functions are now faster, ":D!~
    this.refreshMatrix();
    return this.mat;
  }

  public PMatrix3D getMatrix() {
    return this.mat;
  }

  public void refreshMatrix() {
    this.mat.reset(); // Sets it to an identity matrix.
    this.mat.translate(this.pos.x, this.pos.y, this.pos.z);
    this.mat.rotateX(this.rot.x);
    this.mat.rotateY(this.rot.y);
    this.mat.rotateZ(this.rot.z);
    this.mat.scale(this.scale.x, this.scale.y, this.scale.z);
  }

  // This should be given a new name, or be made 
  // even easier to use with Bullet/bRigid:

  //public void applyMatrix4f(Matrix4f p_mat) {
  //  // Hope that the user called `this.refreshMatrix()` beforehand...
  //  //this.refreshMatrix();
  //this.mat.apply(p_mat.m00, p_mat.m01, p_mat.m02, p_mat.m03, 
  //p_mat.m10, p_mat.m11, p_mat.m12, p_mat.m13, 
  //p_mat.m20, p_mat.m21, p_mat.m22, p_mat.m23, 
  //p_mat.m30, p_mat.m31, p_mat.m32, p_mat.m33);
  //}
}

class Material extends Component {
  PVector cAmb, cEmm, cSpec; // Colors for lights.
  float shine;

  Material(Entity p_entity) {
    super(p_entity);
  }

  public void update() {
    ambient(this.cAmb.x, this.cAmb.y, this.cAmb.z);
    emissive(this.cEmm.x, this.cEmm.y, this.cEmm.z);
    specular(this.cSpec.x, this.cSpec.y, this.cSpec.z);
    shininess(this.shine);
  }
}

class Light extends Component {
  private Transform form; // There's NO reason to call it `parentForm`.
  private PVector pos;
  PVector off, col;

  int type;

  Light(Entity p_entity, Transform p_parentForm) {
    super(p_entity);
    this.form = p_parentForm;
    this.type = POINT;
    this.col = new PVector(255, 255, 255);
    this.off = new PVector();
  }

  Light(Entity p_entity, Transform p_parentForm, int p_lightType) {
    super(p_entity);
    this.form = p_parentForm;
    this.type = p_lightType;
    this.col = new PVector(255, 255, 255);
    this.off = new PVector();
  }

  public void update() {
    this.pos = PVector.add(this.form.pos, this.off);

    //println("Lighting...");

    if (!this.enabled)
      return;

    switch(this.type) {
    case AMBIENT:
      ambientLight(this.col.x, this.col.y, this.col.z, 
        this.pos.x, this.pos.y, this.pos.z);
      break;
    case DIRECTIONAL:
      directionalLight(this.col.x, this.col.y, this.col.z, 
        this.pos.x, this.pos.y, this.pos.z);
      break;
    case POINT:
      pointLight(this.col.x, this.col.y, this.col.z, 
        this.pos.x, this.pos.y, this.pos.z);
      break;
    case SPOT:
      throw new RuntimeException("Please use the `SpotLight` class instead of assigning " 
        + "`SPOT` to the `lightType` of a `Light`!");
    default:
      throw new RuntimeException("Unavailable light type!");
    }
  }
}

class SpotLight extends Light {
  PVector dir;
  float angle, conc;

  SpotLight(Entity p_entity, Transform p_parentForm) {
    super(p_entity, p_parentForm);
  }

  public void update() {
    super.pos = PVector.add(super.form.pos, super.off);
    spotLight(super.col.x, super.col.y, super.col.z, 
      super.pos.x, super.pos.y, super.pos.z, 
      this.dir.x, this.dir.y, this.dir.z, 
      this.angle, this.conc);
  }
}

public enum RendererType {
  QUAD, BOX, ELLIPSE, SPHERE;
}

/*
public enum RendererType {
 QUAD(4), BOX(24), SPHERE(32);
 
 int vertCount;
 
 private RendererType(int p_a) {
 this.vertCount = p_a;
 }
 }
 */

class ShapeRenderer extends Component {
  PShape shape;
  Transform form;
  Asset shapeLoader;

  ShapeRenderer(Entity p_entity) {
    super(p_entity);
  }

  ShapeRenderer(Entity p_entity, Asset p_shapeLoader) {
    super(p_entity);
    this.shapeLoader = p_shapeLoader;
  }

  ShapeRenderer(Entity p_entity, PShape p_shape) {
    super(p_entity);
    this.shape = p_shape;
  }

  void update() {
    shape(this.shape);
  }
}

// Dream.
//class InstancedRenderer {
//  Transform form;
//  RendererType type;
//}

class Renderer extends Component {
  Transform form;
  RendererType type;
  color fill, stroke; // Tinting should be done by the user themselves.
  float strokeWeight = 1;
  int strokeCap = MITER, strokeJoin = ROUND;
  boolean doFill = true, doStroke = true, doTexture = true;

  // Texturing:
  Asset textureLoader;
  int textureWrap = CLAMP;
  PImage texture;

  Renderer(Entity p_entity, Transform p_parentForm) {
    super(p_entity);
    this.form = p_parentForm;

    if (currentScene != null)
      currentScene.renderers.add(this);
  }

  Renderer(Entity p_entity, Transform p_parentForm, RendererType p_type) {
    super(p_entity);
    this.form = p_parentForm;
    this.type = p_type;

    if (currentScene != null)
      currentScene.renderers.add(this);
  }

  Renderer(Entity p_entity, Transform p_parentForm, Asset p_textureLoader) {
    super(p_entity);
    this.form = p_parentForm;
    this.textureLoader = p_textureLoader;

    if (currentScene != null)
      currentScene.renderers.add(this);
  }

  Renderer(Entity p_entity, Transform p_parentForm, RendererType p_type, Asset p_textureLoader) {
    super(p_entity);
    this.type = p_type;
    this.form = p_parentForm;
    this.textureLoader = p_textureLoader;

    if (currentScene != null)
      currentScene.renderers.add(this);
  }

  Renderer(Entity p_entity, Transform p_parentForm, PImage p_texture) {
    super(p_entity);
    this.form = p_parentForm;
    this.texture = p_texture.copy();

    if (currentScene != null)
      currentScene.renderers.add(this);
  }

  Renderer(Entity p_entity, Transform p_parentForm, RendererType p_type, PImage p_texture) {
    super(p_entity);
    this.type = p_type;
    this.form = p_parentForm;
    this.texture = p_texture;

    if (currentScene != null)
      currentScene.renderers.add(this);
  }

  public void applyTexture() {
    if (!this.doTexture) 
      return;
    textureMode(NORMAL);
    textureWrap(this.textureWrap);

    // `texture()` does this already, but I'll do it anyway:
    //if (this.texture != null)
    texture(this.texture);
  }

  public void update() {
    pushMatrix();
    pushStyle();

    // Do this only once:
    if (this.textureLoader != null 
      //&& !this.textureLoader.ploaded &&
      //this.textureLoader.loaded
      ) {
      //synchronized(this.textureLoader) {
      //synchronized(Assets.pictures) {
      //synchronized(this) {
      this.texture = this.textureLoader.asPicture();//.copy();
      //}
      //}
      //}
    }

    // For the Bullet Physics Engine!:
    // Yes, it might be slow, but it's something we'll have to do.
    this.form.applyMatrix();

    if (this.doFill)
      fill(this.fill);
    if (this.doStroke) {
      stroke(this.stroke);
      strokeCap(this.strokeCap);
      strokeJoin(this.strokeJoin);
      strokeWeight(this.strokeWeight);
    }

    switch(this.type) {
    case QUAD:
      beginShape(QUAD);
      this.applyTexture(); // Yes. You bind a texture AFTER `glBegin()`. 
      vertex(-0.5f, -0.5f, 0, 0);
      vertex(0.5f, -0.5f, 1, 0);
      vertex(0.5f, 0.5f, 1, 1);
      vertex(-0.5f, 0.5f, 0, 1);
      endShape(CLOSE);
      break;

    case BOX:
      // Coordinate data from:
      // [https://www.wikihow.com/Make-a-Cube-in-OpenGL]
      beginShape(QUADS);
      this.applyTexture();

      // Frontside:
      vertex(0.5f, -0.5f, -0.5f, 0, 0);
      vertex(0.5f, 0.5f, -0.5f, 1, 0);
      vertex(-0.5f, 0.5f, -0.5f, 1, 1);     
      vertex(-0.5f, -0.5f, -0.5f, 0, 1);

      // Backside:
      vertex(0.5f, -0.5f, 0.5f, 0, 0);
      vertex(0.5f, 0.5f, 0.5f, 1, 0);
      vertex(-0.5f, 0.5f, 0.5f, 1, 1);
      vertex(-0.5f, -0.5f, 0.5f, 0, 1);

      // Right:
      vertex(0.5f, -0.5f, -0.5f, 0, 0);
      vertex(0.5f, 0.5f, -0.5f, 1, 0);
      vertex(0.5f, 0.5f, 0.5f, 1, 1);
      vertex(0.5f, -0.5f, 0.5f, 0, 1);

      // Left:
      vertex(-0.5f, -0.5f, 0.5f, 0, 0);
      vertex(-0.5f, 0.5f, 0.5f, 1, 0);
      vertex(-0.5f, 0.5f, -0.5f, 1, 1);
      vertex(-0.5f, -0.5f, -0.5f, 0, 1);

      // Top:
      vertex( 0.5f, 0.5f, 0.5f, 0, 0);
      vertex( 0.5f, 0.5f, -0.5f, 1, 0);
      vertex(-0.5f, 0.5f, -0.5f, 1, 1);
      vertex(-0.5f, 0.5f, 0.5f, 0, 1);

      // Bottom:
      vertex(0.5f, -0.5f, -0.5f, 0, 0);
      vertex(0.5f, -0.5f, 0.5f, 1, 0);
      vertex(-0.5f, -0.5f, 0.5f, 1, 1);
      vertex(-0.5f, -0.5f, -0.5f, 0, 1);

      endShape();
      break;

    case SPHERE:
      // You don't want a textured sphere. Trust me, you don't.
      // - Me after looking at the p5.js source code.
      // :eyes: `Ctrl + Shift + O`, "Topics", "Textures".
      // - Me after recalling Processing's legacy.
      sphere(1);
      break;

      // [https://stackoverflow.com/a/24843626/13951505] ; - ;)
      // Only used as a reference! I already knew this Math, just keep forgetting it :joy:
      // Fun fact, even *that* code was borrowed from: [http://slabode.exofire.net/circle_draw.shtml]

    case ELLIPSE:
      beginShape(POLYGON); // Begin the circle. `LINE_LOOP`, `TRIANGLE_STRIP` etcetera... all have failed!
      //this.applyTexture(); // Not right now!
      //vertex(x, y, 0, 0); 
      // ^^^ Center of circle. THIS WAS CAUSING THE ISSUE. 
      // It placed a texture coordinate there, when it wasn't needed. 
      // The shape can be completed by iterating once more in the loop below, or,
      // using the `endShape()` function with `CLOSE`. `endShape(CLOSE);`.
      // Of course I used the latter techniquue because it saves the computer from 
      // from doing more trigonometry.
      // (Hope memory access is fast enough!)

      this.applyTexture(); // ...now, we can do this!

      // Here's what it does:
      //public void applyTexture() {
      //if (!this.doTexture) 
      //return;
      //textureMode(NORMAL);
      //textureWrap(this.textureWrap); // Preferred mode: `CLAMP`.
      //texture(this.texture);
      //flush(); // Nice idea, but it's not needed since we're using a batch renderer.
      // No, instance renderers won't be effected by this in any way either.
      // Basically, I should've removed that call to `flush()` rather writing all of these :joy:
      //}

      float x, y; // STACK ALLOC!!!11
      for (int i = 0; i < 36; i++)
        vertex(x = cos(i * TAU / 36), 
          y = sin(i * TAU / 36), 
          // The addition translates in the texture,
          // The multiplication *inversely* scales it.
          0.5f + x * 0.5f, 
          0.5f + y * 0.5f);
      endShape(CLOSE);
      // PS if we were to not use `x` and `y` in the place for `(u, v)` coordinates,
      // And write something like `trig_fxn(i * TAU / 36 * ROTATION_VALUE)`,
      // It would rotate the texture. We could do this over time!
      // For the sake of simplicity, that will be done by the transformation matrices.
      // This is a nice way to do it in shaders, though.

      // ...and with `textureWrap(REPEAT);`, and omitted code for 
      // that centre vertex, we can do some effects with our `(u, v)`s!:

      //cos(i * TAU / 36) * 0.5f - 1, sin(i * TAU / 36) * 0.5f - 1); // Crazy stuff.
      //1 + (0.25f * abs(cos(i * TAU / 36))), 1 + (0.25f * abs(sin(i * TAU / 36)))); // Eye!
      //abs(cos(0.25f + i * TAU / 36)), abs(sin(0.25f + i * TAU / 36))); // `0.25f` is rotation!
      break;

      // Use this when there are `int`s:
      //default:
      //throw new RuntimeException("Unavailable `Renderer` type !");
    }

    popStyle();
    popMatrix();
  }
}
