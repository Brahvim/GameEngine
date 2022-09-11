class Transformation extends SerializableComponent {
  PVector pos, rot, scale;
  protected PMatrix3D mat;

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
    this.refreshMatrix();
    SKETCH.applyMatrix(this.mat);
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
  // even easier to use with Bullet:
  public void applyMatrix4f(Matrix4f p_mat) {
    this.refreshMatrix();
    this.mat.apply(p_mat.m00, p_mat.m01, p_mat.m02, p_mat.m03, 
      p_mat.m10, p_mat.m11, p_mat.m12, p_mat.m13, 
      p_mat.m20, p_mat.m21, p_mat.m22, p_mat.m23, 
      p_mat.m30, p_mat.m31, p_mat.m32, p_mat.m33);
  }

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
      nerdLogError("Failed to load `" + p_fname + "`.");
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
      nerdLogError("Failed to load `" + p_fname + "`.");
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

  void disabledUpdate() {
    switch(this.type) {
    case AMBIENT:
      ambientLight(this.col.x, this.col.y, this.col.z, 
        this.pos.x, this.pos.y, currentCam.far + Float.MAX_VALUE);
      break;
    case DIRECTIONAL:
      directionalLight(this.col.x, this.col.y, this.col.z, 
        this.pos.x, this.pos.y, currentCam.far + Float.MAX_VALUE);
      break;
    case POINT:
      pointLight(this.col.x, this.col.y, this.col.z, 
        this.pos.x, this.pos.y, currentCam.far + Float.MAX_VALUE);
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

// Dream.
//class InstancedRenderer {
//Transform form;
//RendererType type;
//PShape THE_POWERFUL_ONE;
//}

class ParticleSystem extends Component {
  Transformation startPos;
  PShape shape;
  float lifetime = -1, startTime = 0;

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
};

// What to name this now that we have the need for so many renderers? `ImmediateShapeRenderer`?
class ShapeRenderer extends RenderingComponent {
  Transformation form;

  color fill, stroke; // Tinting should be done by the user themselves.
  float strokeWeight = 1;
  int type, strokeCap = MITER, strokeJoin = ROUND, roundness = 36;
  boolean doFill = true, doStroke = true, doTexture = true;

  // Texturing:
  Asset textureLoader;
  int textureWrap = CLAMP; 
  // ^^^ Will I remove this? If they really want so much control,
  // they better write their own render method.
  PImage texture;

  ShapeRenderer(Entity p_entity) {
    super(p_entity);
    this.form = p_entity.getComponent(Transformation.class);

    if (this.form == null)
      nerdLogEx(new NullPointerException("A `Renderer` needs a `Transform`!"));
  }

  ShapeRenderer(Entity p_entity, int p_type) {
    this(p_entity); // Uhm, too many constructor calls. Sign of a code smell.
    this.type = p_type;
  }

  ShapeRenderer(Entity p_entity, int p_type, Asset p_assetLoader) {
    this(p_entity);
    this.type = p_type;
    this.textureLoader = p_assetLoader;
  }

  ShapeRenderer(Entity p_entity, int p_type, PImage p_texture) {
    this(p_entity);
    this.type = p_type;
    this.texture = p_texture;
  }

  public void applyTexture() {
    if (!this.doTexture)
      return;

    textureMode(NORMAL);
    textureWrap(this.textureWrap);

    // `texture()` checks for `null`. No need to check it ourselves.
    texture(this.texture);
  }

  public void textureLoaderCheck() {
    if (this.textureLoader != null)
      this.texture = (PImage)this.textureLoader.loadedData; //this.textureLoader.asPicture();
  }

  public void update() {
    pushMatrix();
    pushStyle();

    this.textureLoaderCheck();

    // For the Bullet Physics Engine!:
    // Yes, it might be slow, but it's something we'll have to do.
    this.form.applyMatrix();

    if (this.doFill)
      fill(this.fill);
    else noFill();
    if (this.doStroke) {
      stroke(this.stroke);
      strokeCap(this.strokeCap);
      strokeJoin(this.strokeJoin);
      strokeWeight(this.strokeWeight);
    } else noStroke();

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
      // ...and that's how you get work done faster. Pfft.
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

      // [https://stackoverflow.com/a/24843626/13951505]
      // Only used as a reference! I understand the Math, only forgot the expression :joy:
      // Fun fact, even *that* code was borrowed from: [http://slabode.exofire.net/circle_draw.shtml]

    case ELLIPSE:
      beginShape(POLYGON);
      this.applyTexture();

      float x, y, tauFract; // STACK ALLOC!!!11
      for (int i = 0; i < this.roundness; i++) {
        tauFract = i * TAU / this.roundness;
        vertex(x = cos(tauFract), y = sin(tauFract), // Wish I had a LUT! 
          // The addition translates in the texture,
          // The multiplication *inversely* scales it.
          0.5f + x * 0.5f, 
          0.5f + y * 0.5f);
      }
      endShape(CLOSE);
      break;
    }

    popStyle();
    popMatrix();
  }
}


// DO NOT INHERIT FROM THIS.
// ...I guess :P

class SvgRenderer extends ShapeRenderer {
  // I could've declared `shape` as `private` and used a pair of
  // getter and setter / accessor and modifier methods, but I
  // went with this approach instead for performance!

  // In a setter, you'd be rendering the SVG to a texture.
  // With this approach, you render in the update loop itself
  // when an update is needed.
  boolean doStyle = true, doAutoCalc = true, doAutoRaster = false;

  PShape svg, psvg = null;
  // ^^^ That's the magic of this approach!
  // `if (this.psvg != this.svg) reRender();`!

  protected PVector pscale;
  float resScale;

  SvgRenderer(Entity p_entity) {
    super(p_entity);
    this.pscale = new PVector();
  }

  SvgRenderer(Entity p_entity, int p_type, Asset p_assetLoader) {
    super(p_entity, p_type, p_assetLoader);
    this.pscale = new PVector();
  }

  SvgRenderer(Entity p_entity, int p_type, PShape p_shape) {
    this(p_entity);
    super.type = p_type;
    this.svg = p_shape;
    this.pscale = new PVector();
    this.resScale = dist(0, 0, this.svg.width, this.svg.height) * 0.05f;
  }

  public void calcScale() {
    this.resScale = dist(0, 0, this.svg.width, this.svg.height) * 0.05f;
  }

  public void rasterize() {
    if (this.svg != null)
      this.texture = svgToImage(this.svg, abs(this.form.scale.x * this.resScale), 
        abs(this.form.scale.y * this.resScale));
    println("Re-rendererd SVG.");
  }

  public void textureLoaderCheck() {
    if (super.textureLoader != null)

      if (super.textureLoader.type == AssetType.SHAPE) {
        this.svg = (PShape)super.textureLoader.loadedData; //super.textureLoader.asShape();

        // Calculate the rasterization scale before rasterizing!:
        if (this.svg != null)
          if (this.doAutoCalc)
            this.resScale = dist(0, 0, this.svg.width, this.svg.height) * 0.05f;

        if (!super.textureLoader.ploaded && super.textureLoader.loaded)
          this.rasterize();
      } else if (super.textureLoader.type == AssetType.PICTURE)
        super.texture = (PImage)this.textureLoader.loadedData;
  }

  public void applyTexture() {
    this.textureLoaderCheck();

    // Re-render :D
    if (!(this.svg != null && super.form.scale.x == 0 && super.form.scale.y == 0))
      if (this.form.scale != this.pscale && this.doAutoRaster)
        this.rasterize();

    this.pscale = super.form.scale;

    if (!super.doTexture)
      return;
    textureMode(NORMAL);
    textureWrap(this.textureWrap);
    texture(this.texture);
  }
}
