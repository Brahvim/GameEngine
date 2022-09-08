class Transformation extends SerializableComponent {
  PVector pos, rot, scale;
  protected PMatrix3D mat;

  /*
  // Wish this worked <Sniffle>:
   class Serializer implements Serializable {
   float[] data = new float[9];
   private final static long serialVersionUID = 2024542466L;
   
   Serializer(Transform p_form) {
   this.data[0] = p_form.pos.x;
   this.data[1] = p_form.pos.y;
   this.data[2] = p_form.pos.z;
   
   this.data[3] = p_form.rot.x;
   this.data[4] = p_form.rot.y;
   this.data[5] = p_form.rot.z;
   
   this.data[6] = p_form.scale.x;
   this.data[7] = p_form.scale.y;
   this.data[8] = p_form.scale.z;
   }
   }
   */

  Transformation(Entity p_entity) {
    super(p_entity);

    this.pos = new PVector();
    this.rot = new PVector();
    this.scale = new PVector(1, 1, 1);
    this.mat = new PMatrix3D();
  }

  Transformation(Entity p_entity, PVector p_pos) {
    super(p_entity);

    this.pos = p_pos;
    this.rot = new PVector();
    this.scale = new PVector();
    this.mat = new PMatrix3D();
  }

  Transformation(Entity p_entity, PVector p_pos, PVector p_rot, PVector p_scale) {
    super(p_entity);

    this.pos = p_pos;
    this.rot = p_rot;
    this.scale = p_scale;
    this.mat = new PMatrix3D();
  }

  public void set(Transformation p_form) {
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

  // ...and finally,

  void write(String p_fname) {
    writeObject(new TransformationSerializer(this), p_fname);
  }

  void read(String p_fname, OnCatch p_catcher) {
    try {
      this.readImpl(p_fname);
    }
    catch (FileNotFoundException e) {
      p_catcher.run(e);
    }
  }

  void read(String p_fname) {
    try {
      this.readImpl(p_fname);
    }
    catch (FileNotFoundException e) {
      logError("Failed to load `" + p_fname + "`.");
      return;
    }
  }

  void readImpl(String p_fname) throws FileNotFoundException {
    TransformationSerializer ser = readObject(p_fname);

    this.pos.set(ser.data[0], ser.data[1], ser.data[2]);
    this.rot.set(ser.data[3], ser.data[4], ser.data[5]);
    this.scale.set(ser.data[6], ser.data[7], ser.data[8]);
  }
}

class Material extends SerializableComponent {
  PVector amb, emm, spec; // Colors for lights.
  float shine;

  Material(Entity p_entity) {
    super(p_entity);
  }

  public void update() {
    ambient(this.amb.x, this.amb.y, this.amb.z);
    emissive(this.emm.x, this.emm.y, this.emm.z);
    specular(this.spec.x, this.spec.y, this.spec.z);
    shininess(this.shine);
  }

  void write(String p_fname) {
    writeObject(new MaterialSerializer(this), p_fname);
  }

  void read(String p_fname) {
    try {
      this.readImpl(p_fname);
    }
    catch (FileNotFoundException e) {
      logError("Failed to load `" + p_fname + "`.");
    }
  }

  void read(String p_fname, OnCatch p_catcher) {
    try {
      this.readImpl(p_fname);
    }
    catch (FileNotFoundException e) {
      p_catcher.run(e);
    }
  }

  void readImpl(String p_fname) throws FileNotFoundException {
    MaterialSerializer ser = readObject(p_fname);

    this.shine = ser.data[9]; // :P-lease!
    this.amb.set(ser.data[0], ser.data[1], ser.data[2]);
    this.emm.set(ser.data[3], ser.data[4], ser.data[5]);
    this.spec.set(ser.data[6], ser.data[7], ser.data[8]);
  }
}

class Light extends Component {
  protected Transformation form; // There's NO reason to call it `parentForm`.
  protected PVector pos;
  PVector off, col;
  int type;

  Light(Entity p_entity) {
    super(p_entity);
    this.form = p_entity.getComponent(Transformation.class);

    if (this.form == null)
      throw new NullPointerException("A `Light` needs a `Transform` in the submitted `Entity`!");

    this.type = POINT;
    this.col = new PVector(255, 255, 255);
    this.off = new PVector();
  }

  Light(Entity p_entity, int p_lightType) {
    this(p_entity);
    this.type = p_lightType;
    this.col = new PVector(255, 255, 255);
    this.off = new PVector();
  }

  public void update() {
    this.pos = PVector.add(this.form.pos, this.off);

    if (!this.enabled)
      println("Lights off!");

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
        + "`SPOT` to the `p_lightType` of a `Light`!");
    default:
      throw new RuntimeException("Unavailable light type!");
    }
  }
}

class SpotLight extends Light {
  PVector dir;
  float angle, conc;

  SpotLight(Entity p_entity) {
    super(p_entity);
  }

  public void update() {
    super.pos = PVector.add(super.form.pos, super.off);
    spotLight(super.col.x, super.col.y, super.col.z, 
      super.pos.x, super.pos.y, super.pos.z, 
      this.dir.x, this.dir.y, this.dir.z, 
      this.angle, this.conc);
  }
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

// DO NOT INHERIT FROM THIS.
// ...I guess :P

/*
class SvgRenderer extends RenderingComponent {
 // I could've declared `shape` as `private` and used a pair of
 // getter and setter / accessor and modifier methods, but I
 // went with this approach instead for performance!
 
 // In a setter, you'd be rendering the SVG to a texture.
 // With this approach, you render in the update loop itself
 // when an update is needed.
 
 PShape svg;
 protected PShape psvg;
 Asset svgLoader;
 // ^^^ That's the magic of this approach!
 // `if (this.pshape != this.shape) reRender();`!
 
 protected PVector pscale;
 boolean doStyle = true;
 
 SvgRenderer(Entity p_entity) {
 super(p_entity);
 this.pscale = new PVector();
 }
 
 SvgRenderer(Entity p_entity, Asset p_assetLoader) {
 this(p_entity);
 this.svgLoader = p_assetLoader;
 }
 
 SvgRenderer(Entity p_entity, PShape p_shape) {
 this(p_entity);
 this.svg = p_shape;
 }
 
 public void applyTexture() {
 // Re-render :D
 if (this.svg != this.psvg || !this.form.scale.equals(this.pscale))
 this.texture = svgToImage(this.svg, this.form.scale.x, this.form.scale.y);
 // I guess not accessing the `z` helps CPU cache.
 
 if (!this.doTexture)
 return;
 textureMode(NORMAL);
 textureWrap(this.textureWrap);
 
 // `texture()` does this already, but I'll do it anyway:
 //if (this.texture != null)
 texture(this.texture);
 }
 }
 */

// Dream.
//class InstancedRenderer {
//  Transform form;
//  RendererType type;
//}

class ParticleSystem extends Component {
  Transformation startPos;
  PShape shape;
  float lifetime = -1, startTime;

  ParticleSystem(Entity p_entity) {
    super(p_entity);
    this.startPos = p_entity.getComponent(Transformation.class);
  }

  void start() {
    this.startTime = millis();
  }

  void update() {
    if (this.lifetime != -1)
      if (millis() - this.startTime > this.lifetime)
        return;
  }
}

// Simply a marker, hehe:
class RenderingComponent extends Component {
  // NO. Do NOT add a `Transform` reference here.
  // Who knows what might come our way?!

  // This is more of an interface than a class.

  RenderingComponent(Entity p_entity) {
    super(p_entity);

    // Welp, there's some ease of use right here:
    if (currentScene != null)
      currentScene.renderers.add(this);
  }

  // Format:
  // There is no format!

  // You can have this, I guess:
  public void update() {
  }
};


// What to name this now that we have the need for so many renderers? `ImmediateShapeRenderer`?
class Renderer extends RenderingComponent {
  Transformation form;
  int type;
  color fill, stroke; // Tinting should be done by the user themselves.
  float strokeWeight = 1;
  int strokeCap = MITER, strokeJoin = ROUND;
  boolean doFill = true, doStroke = true, doTexture = true;

  // Texturing:
  Asset textureLoader;
  int textureWrap = CLAMP;
  PImage texture;

  Renderer(Entity p_entity) {
    super(p_entity);
    this.form = p_entity.getComponent(Transformation.class);

    if (this.form == null)
      logEx(new NullPointerException("A `Renderer` needs a `Transform`!"));
  }

  Renderer(Entity p_entity, int p_type) {
    this(p_entity);
    this.type = p_type;
  }

  Renderer(Entity p_entity, int p_type, Asset p_assetLoader) {
    this(p_entity);
    this.type = p_type;
    this.textureLoader = p_assetLoader;
  }

  Renderer(Entity p_entity, int p_type, PImage p_texture) {
    this(p_entity);
    this.type = p_type;
    this.texture = p_texture.copy();
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

  // This exists so SvgRenderer can extend this class ._.
  // I don't want `ArrayLists` everywhere, ..alright?!
  // ...how about a `RenderingComponent` interface, though..? :thinking:
  public void textureCheck() {
    // Do this only once:
    if (this.textureLoader != null)
      this.texture = this.textureLoader.asPicture();
  }

  public void update() {
    this.textureCheck();

    pushMatrix();
    pushStyle();

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

      float x, y, tauFract; // STACK ALLOC!!!11
      for (int i = 0; i < 36; i++) {
        tauFract = i * TAU / 36;
        vertex(x = cos(tauFract), y = sin(tauFract), 
          // The addition translates in the texture,
          // The multiplication *inversely* scales it.
          0.5f + x * 0.5f, 
          0.5f + y * 0.5f);
      }
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
