/*
// Expected workflow - now possible!:
 ```java
 
 // `Setup.pde`:
 
 static {
 PJOGL.setIcon("sunglass_nerd.png");
 }
 
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

static {
  PJOGL.setIcon("sunglass_nerd.png");
}

void engineSetup() {
  // Bullet `PhysicsRigidBody`s have a `.activate()` method.

  //com.jme3.math.Transform f = new com.jme3.math.Transform();
  //body.getTransform(f);

  // Get a `Matrix4f` out of a `com.jme3.math.Transform`:
  //f.toTransformMatrix(b);

  // The Engine won't load any scenes automatically to avoid allocating too much memory:
  setScene(testScene);
}


Scene testScene = new Scene() {
  @SuppressWarnings("unused")
    Asset audio, boxTexture, circleTexture, cursorImage, svgImage;
  //Pass bloomPass;
  Camera cam = new Camera(), rev = new Camera(); // A 'normal' and a 'revolving' camera.

  @SuppressWarnings("unused")
    Entity circle, quad, light, groundBox;
  SineWave wave = new SineWave(0.001f);

  public void setup() {
    //bloomPass = new BloomPass(SKETCH, 0.5f, 20, 30);
    cursorImage = new Asset("Unnamed_RPG_cursor.png", AssetType.PICTURE, new Runnable() {
      public void run() {
        cursor(cursorImage.asPicture(), -4, -4);
      }
    }
    ).beginAsyncLoad();

    audio = new Asset("UnicycleGirrafe.mp3", AssetType.SOUND, new Runnable() {
      public void run() {
        audio.asSound().loop();
      }
    }
    ).beginAsyncLoad();

    boxTexture = new Asset("LearnOpenGL_container2.png", AssetType.PICTURE).beginAsyncLoad();
    circleTexture = new Asset("PFP.jpg", AssetType.PICTURE).beginAsyncLoad();
    svgImage = new Asset("bot1.svg", AssetType.SHAPE).beginAsyncLoad();

    circle = new Entity() {
      Transformation form = new Transformation(this);
      ShapeRenderer display;

      public void setup() {
        this.display = new ShapeRenderer(this, ELLIPSE, circleTexture);
        this.display.fill = color(230);
        this.display.stroke = color(0);
        this.display.strokeWeight = 0.05f;

        // Simply prints an error message to the console on failure:
        this.form.read("circle_transform");

        // A try-catch would be better here...?
        // `OnCatch` exists! ":D!
        //this.form.read("circle_transform", new OnCatch() {
        //public void run(Exception p_except) {
        //nerdLogInfo(p_except instanceof FileNotFoundException);
        //}
        //}
        //);

        this.form.scale.set(32, 32, 32);
      }

      public void update() {
        if (keyIsPressed(87)) // `W`.
          this.form.pos.y--;
        if (keyIsPressed(65)) // `A`.
          this.form.pos.x++;
        if (keyIsPressed(83)) // `S`.
          this.form.pos.y++;
        if (keyIsPressed(68)) // `D`.
          this.form.pos.x--;
      }

      public void keyPressed() {
        // Saving a state :D
        if (keyIsPressed(KeyEvent.VK_SPACE)) {
          this.form.write("circle_transform");
          logInfo("I wrote you a save file! :D");
        }
        // ^^^ This works in `update()` without any problems (O_O")

        // Works in both `update()` and this method!
        //if (keysPressed(65, 68))
        //println("YOLO!", frameCount);
      }
    };

    quad = new Entity() {
      Transformation form;
      SvgRenderer display;

      public void setup() {
        this.form = new Transformation(this);
        this.form.scale.mult(15);
        this.display = new SvgRenderer(this, QUAD, svgImage);
        this.display.strokeWeight = 0.05f;
        //this.display.textureWrap = REPEAT;
        this.display.doAutoRaster = false;
      }

      public void update() {
        this.form.pos.set(mouse);
        float a = sin(millis() * 0.001f) * 15;
        this.form.scale.set(a, a, a);
      }
    };

    light = new Entity() {
      Transformation form = new Transformation(this), quadForm;
      Light light = new Light(this);

      public void setup() {
        this.quadForm = quad.getComponent(Transformation.class);
        this.light.col.set(255, 255, 255);
        this.light.off.z = 1.5f;
      }

      public void update() {
        this.form.set(quadForm);
      }
    };

    groundBox = new Entity() {
      Transformation form = new Transformation(this);
      ShapeRenderer display = new ShapeRenderer(this, BOX, boxTexture);

      public void setup() {
        this.display.fill = color(255);
        this.display.strokeWeight = 0.1f;
        this.form.pos.set(0, 50);
        this.form.scale.set(255, 255, 255); // In the box we go!
      }
    };

    cam.clearColor = color(0); 
    rev.clearColor = color(30, 120, 170, 1); //80);
    //rev.doAutoClear = false;
    setCam(rev);

    cam.script = new CamScript() {
      public void run(Camera p_cam) {
        p_cam.pos.x = 0;
        p_cam.pos.y = 0;
      }
    };

    rev.script = new CamScript() {
      public void run(Camera p_cam) {
        p_cam.pos.x = cos(millis() * 0.001f) * 100;
        p_cam.pos.z = sin(millis() * 0.001f) * 100;
      }
    };

    doCamera = false;
    wave.start(0);
    wave.endIn(3600);
    wave.extendEndBy(10000);
  }

  public void draw() {
    doCamera = !mouseLeft;
    if (mouseLeft)
      camLerpUpdate(cam, rev, (float)mouseX / (float)width);
    else currentCam.applyMatrix();

    //rev.pos.z += mouseScrollDelta;
    //println(rev.pos.z, mouseScrollDelta);

    //doPostProcessing = true;
    //applyPass(bloomPass);

    //gl.enable(PGL.CULL_FACE);
    //gl.cullFace(PGL.FRONT);
    //gl.frontFace(PGL.CCW);
    //flush();
  }

  public void drawUI() {
    //gl.disable(PGL.CULL_FACE);
    image(boxTexture, cx + wave.get() * cx, mouseY, 160, 160);

    fill(255, 0, 0, 60); // The alpha used to be `80`.
    circle(mouseX, mouseY, 60);

    translate(0.5f * textWidth(Integer.toString((int)frameRate)), 
      textAscent() - textDescent());
    fill(255);
    text((int)frameRate, 0, 0);

    doLights = false;
  }  

  boolean isLightDimmed;
  public void mousePressed() {
    if (mouseButton == RIGHT)
      setCam(currentCam == rev? cam : rev);
    else if (mouseButton == CENTER) {
      //light.enabled = !light.enabled; // Causes COMPLETE darkness!
      isLightDimmed = !isLightDimmed;
      Light l = light.getComponent(Light.class);
      if (isLightDimmed) {
        //doLights = false;
        l.col.set(65, 50, 50);
      } else {
        //doLights = true;
        l.col.set(255, 255, 255);
      }
    }
  } // End of `mousePressed()`.
};
