class Transformation extends SerializableComponent { //<>//
  PVector pos, rot, scale;
  PMatrix3D mat;

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
    catch (Exception e) {
      p_catcher.run(e);
    }
  }

  void read(String p_fname) {
    try {
      this.readImpl(p_fname);
    }
    catch (Exception e) {
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
  PVector pos;
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

class ParticleEmitter extends Component {
  Transformation startPos;
  PShape shape;
  float lifetime = -1, startTime = 0;

  ParticleEmitter(Entity p_entity) {
    super(p_entity);
    this.startPos = p_entity.getComponent(Transformation.class);
  }

  ParticleEmitter(Entity p_entity, int p_shape) {
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

// Marker, ":P!:
class RenderingComponent extends Component {
  RenderingComponent(Entity p_entity) {
    super(p_entity);
    if (currentScene != null)
      currentScene.renderers.add(this);
  }
}

// What to name this now that we have the need for so many renderers? `ImmediateShapeRenderer`?
class BasicRenderer extends RenderingComponent {
  protected Transformation form;

  int fill, stroke; // Tinting should be done by the user themselves.
  float strokeWeight = 1;
  int type, strokeCap = MITER, strokeJoin = ROUND, roundness = 36;
  boolean doFill = true, doStroke = true, doTexture = true;

  // Texturing:
  Asset textureLoader;
  int textureWrap = CLAMP; 
  PImage texture;

  BasicRenderer(Entity p_entity) {
    super(p_entity);
    this.form = p_entity.getComponent(Transformation.class);

    if (this.form == null)
      nerdLogEx(new NullPointerException("Any kind of renderer needs a `Transformation` component" 
        + " to be present in your `Entity`!"));
  }

  BasicRenderer(Entity p_entity, int p_type) {
    this(p_entity); // Uhm, too many constructor calls. Sign of a code smell.
    this.type = p_type;
  }

  BasicRenderer(Entity p_entity, int p_type, Asset p_assetLoader) {
    this(p_entity);
    this.type = p_type;
    this.textureLoader = p_assetLoader;
  }

  BasicRenderer(Entity p_entity, int p_type, PImage p_texture) {
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
    // ...but apparently the code for the sphere does suffer from not doing it!...
    texture(this.texture);
  }

  public void textureLoaderCheck() {
    if (this.textureLoader != null)
      this.texture = (PImage)this.textureLoader.loadedData; //this.textureLoader.asPicture();
  }

  public void update() {
    this.textureLoaderCheck();

    pushMatrix();
    pushStyle();

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
      if (this.texture == null) {
        popMatrix();
        popStyle();
        return;
      }

      // Thanks, Processing Community! :D
      int v1, v11, v2, i = 0;

      beginShape(TRIANGLE_STRIP);
      this.applyTexture();
      textureMode(IMAGE);

      float iu = (float) (this.texture.width - 1) / SPHERE_DETAIL;
      float iv = (float) (this.texture.height - 1) / SPHERE_DETAIL;
      float u = 0, v = iv;

      for (i = 0; i < SPHERE_DETAIL; i++) {
        vertex(0, -1, 0, u, 0);
        vertex(sphereX[i], sphereY[i], sphereZ[i], u, v);
        u += iu;
      }
      vertex(0, -1, 0, u, 0);
      vertex(sphereX[0], sphereY[0], sphereZ[0], u, v);
      endShape();

      // Middle rings:

      int voff = 0, j;
      for (i = 2; i < SPHERE_DETAIL; i++) {
        v1 = v11 = voff;
        voff += SPHERE_DETAIL;
        v2 = voff;
        u = 0;

        beginShape(TRIANGLE_STRIP);
        this.applyTexture();
        textureMode(IMAGE);

        for (j = 0; j < SPHERE_DETAIL; j++) {
          vertex(sphereX[v1], sphereY[v1], sphereZ[v1++], u, v);
          vertex(sphereX[v2], sphereY[v2], sphereZ[v2++], u, v + iv);
          u += iu;
        }

        // Close each ring:

        v1 = v11;
        v2 = voff;
        vertex(sphereX[v1], sphereY[v1], sphereZ[v1], u, v);
        vertex(sphereX[v2], sphereY[v2], sphereZ[v2], u, v + iv);
        endShape();
        v += iv;
      }

      u = 0;

      // Add the northern cap:

      beginShape(TRIANGLE_STRIP);
      this.applyTexture();
      textureMode(IMAGE);

      for (i = 0; i < SPHERE_DETAIL; i++) {
        v2 = voff + i;
        vertex(sphereX[v2], sphereY[v2], sphereZ[v2], u, v);
        vertex(0, 1, 0, u, v + iv);
        u += iu;
      }
      vertex(sphereX[voff], sphereY[voff], sphereZ[voff], u, v);
      endShape();
      break;

      // [https://stackoverflow.com/a/24843626/13951505]
      // Only used as a reference! I understand the Math, only forgot the expression :joy:
      // Fun fact, even *that* code was borrowed from: [http://slabode.exofire.net/circle_draw.shtml]

    case ELLIPSE:
      beginShape(POLYGON);
      this.applyTexture();

      float ex, ey, eTauFract; // STACK ALLOC!!!11
      for (int k = 0; k < this.roundness; k++) {
        eTauFract = k * TAU / this.roundness;
        vertex(ex = cos(eTauFract), ey = sin(eTauFract), // Wish I had a LUT! 
          // The addition translates in the texture,
          // The multiplication *inversely* scales it.
          0.5f + ex * 0.5f, 
          0.5f + ey * 0.5f);
      }
      endShape(CLOSE);
      break;
    }

    popStyle();
    popMatrix();
  }

  void setTexture(Asset p_asset) {
    this.texture = (PImage)p_asset.loadedData;
  }
}

// YES inheritance is bad, but at least it saves me from copy-pasting `update()` again...
class SvgRenderer extends BasicRenderer {
  // I could've declared `shape` as `private` and used a pair of
  // getter and setter / accessor and modifier methods, but I
  // went with this approach instead for performance!

  // In a setter, you'd be rendering the SVG to a texture.
  // With this approach, you render in the update loop itself
  // when an update is needed.
  boolean doStyle = true, doAutoScale, doAutoRaster, hasRasterized;
  PGraphics rasterBuffer;

  PShape svg, psvg = null;
  // ^^^ That's the magic of this approach!
  // `if (this.psvg != this.svg) this.rasterize();`!

  PVector pscale;
  float resScale;

  SvgRenderer(Entity p_entity) {
    super(p_entity);
    this.pscale = new PVector();
    this.rasterBuffer = createGraphics(0, 0, P3D);
  }

  SvgRenderer(Entity p_entity, int p_type, Asset p_assetLoader) {
    super(p_entity, p_type, p_assetLoader);
    this.pscale = new PVector();
    this.rasterBuffer = createGraphics(0, 0, P3D);
  }

  SvgRenderer(Entity p_entity, int p_type, PShape p_shape) {
    this(p_entity);
    super.type = p_type;
    this.svg = p_shape;
    this.pscale = new PVector();
    this.updateScale();
    this.rasterBuffer.setSize(
      (int)Math.abs(this.form.scale.x * this.resScale), 
      (int)Math.abs(this.form.scale.y * this.resScale));
    // The SVG will be rasterized later.
  }

  public void updateScale() {
    //this.resScale = dist(0, 0, this.svg.width, this.svg.height) * 0.5f;
    this.resScale = dist(0, 0, super.form.scale.x, super.form.scale.y) * 2;
  }

  public boolean rasterize() {
    if (this.svg == null)
      return false;

    float reqx = Math.abs(this.form.scale.x * this.resScale), 
      reqy = Math.abs(this.form.scale.y * this.resScale);
    int irx = (int)reqx, iry = (int)reqy;

    if (!(this.rasterBuffer.width == irx && this.rasterBuffer.height == iry))
      this.rasterBuffer.setSize(irx, iry);

    // Apparently the `PShape` width and height fields are `float`s?!

    this.rasterBuffer.beginDraw();
    this.rasterBuffer.shape(this.svg, 0, 0, reqx, reqy);
    this.rasterBuffer.endDraw();

    super.texture = (PImage)this.rasterBuffer;
    return true;
  }

  public void textureLoaderCheck() {
    if (super.textureLoader == null)
      return;

    switch(super.textureLoader.type) {
    case SHAPE:
      if (!this.hasRasterized) {
        // Update SVG:
        this.svg = (PShape)super.textureLoader.loadedData;

        // Let's not disturb those two functions down there... (things run faster with this check!):
        if (this.svg == null)
          return;

        if (this.doAutoScale)
          this.updateScale();

        this.hasRasterized = this.rasterize();
      }
      break;
    case IMAGE:
      super.texture = (PImage)super.textureLoader.loadedData;
      break;
    default:
    }

    /*
    if (super.textureLoader != null)
     
     if (super.textureLoader.type == AssetType.SHAPE) {
     this.svg = (PShape)super.textureLoader.loadedData; //super.textureLoader.asShape();
     
     // Calculate the rasterization scale before rasterizing!:
     if (this.svg != null)
     if (this.doAutoCalc)
     this.calcScale();
     
     // Re-render on the image loading :D
     if (//!super.textureLoader.ploaded && super.textureLoader.loaded
     //!this.hasRasterizedOnLoad) {
     ////println("Texture loader rasterized SVG.");
     //this.hasRasterizedOnLoad = true;
     //this.rasterize();
     } else if (super.textureLoader.type == AssetType.IMAGE)
     super.texture = (PImage)this.textureLoader.loadedData;
     }
     */
  }

  public void applyTexture() {
    this.textureLoaderCheck();

    // Re-render on size changes :D
    if (!(this.svg == null && super.form.scale.x == 0 && super.form.scale.y == 0))
      if (this.form.scale != this.pscale && this.doAutoRaster)
        this.rasterize();

    this.pscale = super.form.scale;

    if (!super.doTexture)
      return;
    textureMode(NORMAL);
    textureWrap(this.textureWrap);
    texture(this.texture);
  }

  void setTexture(Asset p_asset) {
    this.svg = (PShape)p_asset.loadedData;
    this.hasRasterized = false;
  }
}

class ModelRenderer extends BasicRenderer {
  ModelRenderer(Entity p_entity) {
    super(p_entity);
  }
}

// "Favor composition over inheritance."
class InstancedRenderer extends RenderingComponent {
  protected Transformation form;
  PShape instance;

  int fill, stroke;
  float strokeWeight = 1;
  int type, ptype, strokeCap = MITER, strokeJoin = ROUND, vertCount = -1;
  boolean doFill = true, doStroke = true, doTexture = true;

  Asset textureLoader;
  PImage texture;

  boolean exists; // State management :P
  // (It took me an entire week to figure out I could do that
  // instead of constantly checking `ploaded` and `loaded`!)

  InstancedRenderer(Entity p_entity) {
    super(p_entity);

    this.form = p_entity.getComponent(Transformation.class);

    if (this.form == null)
      nerdLogEx(new NullPointerException("An `InstacedRenderer` needs a `Transformation` component" 
        + " to be present in your `Entity`!"));
  }

  // Caching shapes is useless. I already have the vertices for cubes, and
  // Sphere and circles need a quality/edge/resolution control!
  // (It is a totally good idea to cache their vertices anyway so people can
  // actually make use of the `Entity.render()` method :D)

  InstancedRenderer(Entity p_entity, int p_type) {
    this(p_entity);
    this.type = p_type;
    this.instance = nerdCreateShape(p_type);
  }

  InstancedRenderer(Entity p_entity, PShape p_instance) {
    this(p_entity);
    this.instance = p_instance;
  }

  InstancedRenderer(Entity p_entity, int p_type, PImage p_texture) {
    this(p_entity);
    this.type = p_type;
    this.texture = p_texture;
    this.instance = nerdCreateShape(p_type, this.texture);
  }

  InstancedRenderer(Entity p_entity, int p_type, Asset p_textureLoader) {
    this(p_entity);
    this.type = p_type;
    this.textureLoader = p_textureLoader;
  }

  void update() {
    if (!(this.textureLoader == null && this.exists)) {
      this.exists = true;
      this.instance = nerdCreateShape(this.type, this.texture);
      this.texture = (PImage)this.textureLoader.loadedData;
    }

    if (this.instance == null)
      return;

    this.vertCount = this.instance.getVertexCount();

    // This can take `null`, too!:
    this.instance.setTexture(this.doTexture? this.texture : null);

    this.instance.setStroke(this.stroke);
    this.instance.setStrokeWeight(this.strokeWeight);
    this.instance.setStrokeCap(this.strokeCap);
    this.instance.setStrokeJoin(this.strokeJoin);
    this.instance.setStroke(this.doStroke); // Do this later! Are those settings we fixed, useless?

    this.instance.setFill(this.fill);
    this.instance.setFill(this.doFill); // Are we supposed to do a fill? 

    pushMatrix();
    this.form.applyMatrix();
    shape(this.instance);
    popMatrix();
  }
}

PShape nerdCreateShape(int p_type) {
  return nerdCreateShape(p_type, null);
}

PShape nerdCreateShape(int p_type, PImage p_texture) {
  PShape ret;

  switch(p_type) {
  case QUAD:
    ret = createShape();
    nerdGiveVertices(ret, QUAD, p_texture);
    ret.endShape(CLOSE);
    break;

  case BOX:
    ret = createShape();
    nerdGiveVertices(ret, BOX, p_texture);
    ret.endShape();
    break;

  case SPHERE:
    ret = createShape(GROUP);
    nerdGiveVertices(ret, SPHERE, p_texture);
    break;

    // [https://stackoverflow.com/a/24843626/13951505]
    // Only used as a reference! I understand the Math, only forgot the expression :joy:
    // Fun fact, even *that* code was borrowed from: [http://slabode.exofire.net/circle_draw.shtml]

  case ELLIPSE:
    ret = createShape();
    ret.beginShape(POLYGON);
    nerdGiveVertices(ret, ELLIPSE, p_texture);
    ret.endShape(CLOSE);
    break;

  default:
    return null;
  }

  return ret;
}

void nerdGiveVertices(PShape p_shape, int p_type, PImage p_texture) {
  switch(p_type) {
  case QUAD:
    p_shape.textureMode(NORMAL);
    //p_shape.textureWrap(p_texMode);
    p_shape.texture(p_texture);
    // Yes. You bind a texture AFTER `glBegin()`. 
    p_shape.vertex(-0.5f, -0.5f, 0, 0);
    p_shape.vertex(0.5f, -0.5f, 1, 0);
    p_shape.vertex(0.5f, 0.5f, 1, 1);
    p_shape.vertex(-0.5f, 0.5f, 0, 1);
    break;

  case BOX:
    // Coordinate data from:
    // [https://www.wikihow.com/Make-a-Cube-in-OpenGL]
    // ...and that's how you get work done faster. Pfft.
    p_shape.beginShape(QUADS);
    p_shape.textureMode(NORMAL);
    //p_shape.textureWrap(p_texMode);
    p_shape.texture(p_texture);

    // Frontside:
    p_shape.vertex(0.5f, -0.5f, -0.5f, 0, 0);
    p_shape.vertex(0.5f, 0.5f, -0.5f, 1, 0);
    p_shape.vertex(-0.5f, 0.5f, -0.5f, 1, 1);     
    p_shape.vertex(-0.5f, -0.5f, -0.5f, 0, 1);

    // Backside:
    p_shape.vertex(0.5f, -0.5f, 0.5f, 0, 0);
    p_shape.vertex(0.5f, 0.5f, 0.5f, 1, 0);
    p_shape.vertex(-0.5f, 0.5f, 0.5f, 1, 1);
    p_shape.vertex(-0.5f, -0.5f, 0.5f, 0, 1);

    // Right:
    p_shape.vertex(0.5f, -0.5f, -0.5f, 0, 0);
    p_shape.vertex(0.5f, 0.5f, -0.5f, 1, 0);
    p_shape.vertex(0.5f, 0.5f, 0.5f, 1, 1);
    p_shape.vertex(0.5f, -0.5f, 0.5f, 0, 1);

    // Left:
    p_shape.vertex(-0.5f, -0.5f, 0.5f, 0, 0);
    p_shape.vertex(-0.5f, 0.5f, 0.5f, 1, 0);
    p_shape.vertex(-0.5f, 0.5f, -0.5f, 1, 1);
    p_shape.vertex(-0.5f, -0.5f, -0.5f, 0, 1);

    // Top:
    p_shape.vertex( 0.5f, 0.5f, 0.5f, 0, 0);
    p_shape.vertex( 0.5f, 0.5f, -0.5f, 1, 0);
    p_shape.vertex(-0.5f, 0.5f, -0.5f, 1, 1);
    p_shape.vertex(-0.5f, 0.5f, 0.5f, 0, 1);

    // Bottom:
    p_shape.vertex(0.5f, -0.5f, -0.5f, 0, 0);
    p_shape.vertex(0.5f, -0.5f, 0.5f, 1, 0);
    p_shape.vertex(-0.5f, -0.5f, 0.5f, 1, 1);
    p_shape.vertex(-0.5f, -0.5f, -0.5f, 0, 1);
    break;

  case SPHERE:
    //if (p_texture == null)
    //return null;

    // Thanks, Processing Community! :D
    int v1, v11, v2, i = 0;

    PShape sphereMain = createShape();
    sphereMain.beginShape(TRIANGLE_STRIP);
    //p_shape.textureWrap(p_texMode);
    sphereMain.texture(p_texture);
    sphereMain.textureMode(IMAGE);

    float iu = p_texture == null? 0 : (float) (p_texture.width - 1) / SPHERE_DETAIL;
    float iv = p_texture == null? 0 : (float) (p_texture.height - 1) / SPHERE_DETAIL;
    float u = 0, v = iv;

    for (i = 0; i < SPHERE_DETAIL; i++) {
      sphereMain.vertex(0, -1, 0, u, 0);
      sphereMain.vertex(sphereX[i], sphereY[i], sphereZ[i], u, v);
      u += iu;
    }
    sphereMain.vertex(0, -1, 0, u, 0);
    sphereMain.vertex(sphereX[0], sphereY[0], sphereZ[0], u, v);
    sphereMain.endShape();

    p_shape.addChild(sphereMain);

    // Middle rings:

    int voff = 0, j;
    for (i = 2; i < SPHERE_DETAIL; i++) {
      v1 = v11 = voff;
      voff += SPHERE_DETAIL;
      v2 = voff;
      u = 0;

      PShape sphereMidRing = createShape();
      sphereMidRing.beginShape(TRIANGLE_STRIP);
      //p_shape.textureWrap(p_texMode);
      sphereMidRing.texture(p_texture);
      sphereMidRing.textureMode(IMAGE);

      for (j = 0; j < SPHERE_DETAIL; j++) {
        sphereMidRing.vertex(sphereX[v1], sphereY[v1], sphereZ[v1++], u, v);
        sphereMidRing.vertex(sphereX[v2], sphereY[v2], sphereZ[v2++], u, v + iv);
        u += iu;
      }

      // Close each ring:

      v1 = v11;
      v2 = voff;
      sphereMidRing.vertex(sphereX[v1], sphereY[v1], sphereZ[v1], u, v);
      sphereMidRing.vertex(sphereX[v2], sphereY[v2], sphereZ[v2], u, v + iv);
      sphereMidRing.endShape();

      p_shape.addChild(sphereMidRing);
      v += iv;
    }

    u = 0;

    // Add the northern cap:

    PShape sphereNorthCap = createShape();
    sphereNorthCap.beginShape(TRIANGLE_STRIP);
    //p_shape.textureWrap(p_texMode);
    sphereNorthCap.texture(p_texture);
    sphereNorthCap.textureMode(IMAGE);

    for (i = 0; i < SPHERE_DETAIL; i++) {
      v2 = voff + i;
      sphereNorthCap.vertex(sphereX[v2], sphereY[v2], sphereZ[v2], u, v);
      sphereNorthCap.vertex(0, 1, 0, u, v + iv);
      u += iu;
    }
    sphereNorthCap.vertex(sphereX[voff], sphereY[voff], sphereZ[voff], u, v);
    sphereNorthCap.endShape();

    p_shape.addChild(sphereNorthCap);
    break;

    // [https://stackoverflow.com/a/24843626/13951505]
    // Only used as a reference! I understand the Math, only forgot the expression :joy:
    // Fun fact, even *that* code was borrowed from: [http://slabode.exofire.net/circle_draw.shtml]

  case ELLIPSE:
    p_shape.beginShape(POLYGON);
    p_shape.textureMode(NORMAL);
    //p_shape.textureWrap(p_texMode);
    p_shape.texture(p_texture);

    float ex, ey, eTauFract; // STACK ALLOC!!!11
    for (int k = 0; k < 36; k++) {
      eTauFract = k * TAU / 36;
      p_shape.vertex(ex = cos(eTauFract), ey = sin(eTauFract), // Wish I had a LUT! 
        // The addition translates in the texture,
        // The multiplication *inversely* scales it.
        0.5f + ex * 0.5f, 
        0.5f + ey * 0.5f);
    }
    break;
  }
}
