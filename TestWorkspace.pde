/*
// Expected workflow - now possible!:
 
 ```java
 void engineSetup() { // Generally called via reflection.
 functionThatLoadsAssets();
 restOfTheSetup();
 }
 
 // Entity extending type that is needed across scenes:
 class Collectable extends Entity {
 // ...
 }
 
 Scene titleScene = new Scene() {
 Entity player;
 Collectable coin;
 
 public void setup() {
 
 player = new Entity() {
 // Components...
 public void setup() { }
 public void update() { }
 }; // End of Entity definition. This Entity is automatically added to the scene.
 
 } // End of `setup()`.
 
 } // End of Scene.
 
 // For the sake of ease!:
 .addEntity("ground", new Entity() {
 public void setup() { }
 public void update() { }
 })
 .addEntity(new Collectable());
 
 ```
 */

void engineSetup() {
  Assets.init(1, 1, 0);

  //Form settingsForm = uibn.createForm(SKETCH_NAME + ".exe")
  //.addSelection("Graphical Quality", "Fair", "Decent", "Powerful").run();
  //while (!settingsForm.isClosedByUser());

  logInfo("`engineSetup()` called.");
  logWarn("Test warning!");
  logError("Fake error!");

  try {
    logEx(new Exception("Don't worry! This is a test!"));
  }
  catch(Exception e) {
  }

  // Customizeable!:
  //Log.filePath = "C:\\ProcessingSketches\\sketches\\".concat(SKETCH_NAME).concat("\\")
  //.concat(SKETCH_NAME).concat(".txt");
  //Log.logFile = new File(Log.filePath);

  b2d = createB2DWorld(500, 500);
  bt = createBTWorld();

  //PhysicsRigidBody a = null;
  //a.activate(false);

  //com.jme3.math.Transform f = new com.jme3.math.Transform();
  //a.getTransform(f);

  //Matrix4f b = new Matrix4f();
  //f.toTransformMatrix(b);

  // The Engine won't load any scenes automatically to avoid allocating too much memory:
  setScene(testScene);

  //Log.filePath = "C:\\ProcessingSketches\\sketches\\".concat(SKETCH_NAME).concat("\\")
  //.concat(SKETCH_NAME).concat(".txt");
  //Log.logFile = new File(Log.filePath);

  logInfo("Hello, World!");
  logInfo("Another log!");
}


Asset globalBoxTexture;
Scene testScene = new Scene() {
  Asset audio, boxTexture;
  Camera cam = new Camera(), rev = new Camera(); // A 'normal' and a 'revolving' camera.
  Entity circle, quad, light, groundBox;

  public void setup() {
    audio = new Asset("UnicycleGirrafe.mp3", AssetType.SOUND, new Runnable() {
      public void run() {
        SoundFile sound = Assets.getSound(audio);
        sound.loop();
      }
    }
    );//.beginAsyncLoad();

    boxTexture = new Asset("LearnOpenGL_container2.png", AssetType.PICTURE, new Runnable() {
      public void run() {
        //((Renderer)circle.getComponent(Renderer.class)).texture = (PImage)boxTexture.loadedData;
        println("Box texture done loading!");
      }
    }
    ).beginAsyncLoad();

    circle = new Entity() {
      Transform form = new Transform(this);
      Renderer display;

      public void setup() {
        this.display = new Renderer(this, this.form, RendererType.ELLIPSE, boxTexture);
        this.display.fill = color(230);
        this.display.stroke = color(0);
        this.display.strokeWeight = 0.05f;

        this.form.scale.mult(32);
        logInfo("Circle setup.");
      }

      public void update() {
        this.form.pos.set(cx, cy);
      }
    };

    quad = new Entity() {
      Transform form;
      Renderer display;

      public void setup() {
        this.form = new Transform(this);
        this.display = new Renderer(this, this.form, RendererType.QUAD, boxTexture);
        this.display.type = RendererType.QUAD;

        logInfo("Quad setup.");

        logInfo("Quad components:");
        for (Component c : this.components)
          logInfo("\t", c);

        this.display.strokeWeight = 0.05f;
        this.form.scale.mult(15);
      }

      public void update() {
        this.form.pos.set(mouse);
      }
    };

    light = new Entity() {
      Transform form = new Transform(this), quadForm;
      Light light = new Light(this, this.form, POINT);

      public void setup() {
        light.enabled = false;
        quadForm = quad.getComponent(Transform.class);
        this.light.col.set(255, 255, 255);
      }

      public void update() {
        this.form.set((Transform)quadForm);
        //this.form.pos.z += 50;
      }
    };

    groundBox = new Entity() {
      Transform form = new Transform(this);
      Renderer display;

      public void setup() {
        this.display = new Renderer(this, this.form, RendererType.BOX, boxTexture);
        this.display.fill = color(255);
        this.display.strokeWeight = 0.1f;
        //this.form.scale.set(150, 50, 150); // *On* the box.
        this.form.scale.set(255, 255, 255); // In the box we go!
      }

      public void update() {
        //println(boxTexture.ploaded);
        this.form.pos.set(cx, cy + 50, 0);
      }
    };

    println("Scene components:");
    for (Component c : this.components)
      println(c);

    cam.clearColor = rev.clearColor = color(30, 120, 170, 80); //15);
    setCam(rev);

    cam.script = new CamScript() {
      public void run(Camera p_cam) {
        p_cam.pos.x = 0;
        //p_cam.pos.x = noise(millis() * 0.001f) * 5;
        p_cam.pos.y = 0; //p_cam.pos.x;
      }
    };

    rev.script = new CamScript() {
      public void run(Camera p_cam) {
        p_cam.pos.x = cos(millis() * 0.001f) * 100;
        p_cam.pos.y = -50;
        p_cam.pos.z = sin(millis() * 0.001f) * 100;
      }
    };

    rev.doScript = false;

    fxApplier.setResolution(INIT_WIDTH, INIT_HEIGHT);
    bPass = new BloomPass(SKETCH, 0.5f, 20, 30);
  }

  BloomPass bPass;

  public void draw() {
    currentCam.applyMatrix();
    if (mousePressed && mouseButton == LEFT)
      //camLerpUpdate(cam, rev, (float)mouse.x / (float)width, 0.05f, 0.95f);
      camLerpUpdate(cam, rev, (float)mouseX / (float)width, 0, 1);
    else camIsLerp = false;

    fxApplier.pass(bPass);


    //gl.enable(PGL.CULL_FACE);
    //gl.cullFace(PGL.FRONT);
    //gl.frontFace(PGL.CCW);
    //flush();
  }

  public void drawUI() {
    //gl.disable(PGL.CULL_FACE);

    fill(255, 0, 0, 60); // The alpha used to be `80`.
    circle(mouseX, mouseY, 60);

    translate(0.5f * textWidth(Integer.toString((int)frameRate)), 
      textAscent() - textDescent());
    fill(255);
    text((int)frameRate, 0, 0);
  }  

  public void mousePressed() {
    if (mouseButton == RIGHT)
      setCam(currentCam == rev? cam : rev);
    else if (mouseButton == CENTER) {
      light.enabled = !light.enabled;
    }
  }
};
