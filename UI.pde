class PC_Button {
  PVector transform;
  float size;
  boolean ppressed, pressed, hovered, phovered;
  SineWave wave = new SineWave();
  Runnable renderMethod, hoverMethod, clickMethod;

  PC_Button(float _x, float _y, float _size) {
    this.transform = new PVector(_x, _y);
    this.size = _size;
  }

  // Constructor overloading may exist, but I like this:
  PC_Button(float _x, float _y, float _size, float _rot) {
    this.transform = new PVector(_x, _y, _rot);
    this.size = _size;
  }

  void setPos(float _x, float _y) {
    this.transform.set(_x, _y);
  }

  void setRot(float _rot) {
    this.transform.z = _rot;
  }

  void setTransform(float _x, float _y, float _rot) {
    this.transform.set(_x, _y, _rot);
  }

  void update() {
    // Store the previous state:
    // (Need this to make sure callbacks are called 'eventually' and not every frame!)
    this.phovered = this.hovered;
    this.ppressed = this.pressed;

    // Hit test:
    this.hovered = 
      mouse.x < this.transform.x + this.size && 
      mouse.x > this.transform.x - this.size && 
      mouse.y < this.transform.y + this.size &&
      mouse.y > this.transform.y - this.size;

    if (this.hovered && !(this.phovered || this.hoverMethod == null)) 
      this.hoverMethod.run();

    this.pressed = this.hovered;
    this.pressed &= mouseLeft;

    if (!this.pressed && 
      (this.hovered && 
      this.ppressed && 
      this.clickMethod != null))
      this.clickMethod.run();
  }

  void render() {
    pushMatrix();
    pushStyle();

    translate(this.transform.x, this.transform.y);
    scale(this.size);
    rotateZ(this.transform.z);

    noStroke();
    fill(230, this.pressed? 100 : 30);

    if (this.renderMethod != null) 
      this.renderMethod.run();

    popStyle();
    popMatrix();
  }
}


/*

 // Android Button stuff!:
 ButtonHandlerClassObject Buttons
 = new ButtonHandlerClassObject();
 Button[] dpad = new Button[4];
 Button A_BUTTON, B_BUTTON, 
 L_BUTTON, R_BUTTON, 
 X_BUTTON, Y_BUTTON, 
 START_BUTTON, SELECT_BUTTON, 
 DPAD_CANCEL;
 
 PVector DPAD_MID 
 = new PVector(200, 500), 
 ABXY_MID;
 
 class ButtonHandlerClassObject {
 int nPresses;
 // ^^^ Only for the DPAD.
 int totalBtnPressed;
 ArrayList<Button> all 
 = new ArrayList<Button>(); 
 boolean anyBtnPressed;
 
 void init() {
 // "Up-right, left-down":
 dpad[0] = new Button(new PVector(
 DPAD_MID.x, DPAD_MID.y - 85), 80);
 dpad[1] = new Button(new PVector(
 DPAD_MID.x + 85, DPAD_MID.y, HALF_PI), 80);
 dpad[2] = new Button(new PVector(
 DPAD_MID.x - 85, DPAD_MID.y, -HALF_PI), 80);
 dpad[3] = new Button(new PVector(
 DPAD_MID.x, DPAD_MID.y + 85, PI), 80);
 
 Runnable dpadShape 
 = new Runnable() {
 public void run() {
 beginShape(POLYGON);
 vertex(-0.5f, 0.35f);
 vertex(0.5f, 0.35f);
 vertex(0.5f, -0.35f);
 //edge(true);
 vertex(0, -0.85f);
 //edge(false);
 vertex(-0.5f, -0.35f);
 endShape(CLOSE);
 }
 };
 
 for (Button b : dpad) {
 b.renderMethod = dpadShape;
 b.extended = true;
 }
 
 ABXY_MID = new PVector(
 width - 236.25f, height - 270);
 
 A_BUTTON = new Button(new PVector(
 ABXY_MID.x + 90, ABXY_MID.y + 90), 100);
 A_BUTTON.renderMethod
 = new Runnable() {
 public void run() {
 ellipse(0, 0, 1, 1);
 textSize(0.4f);
 //textAlign(CENTER, CENTER);
 text("A", 0, 0);
 }
 };
 
 B_BUTTON = new Button(new PVector(
 ABXY_MID.x, ABXY_MID.y + 180), 100);
 B_BUTTON.renderMethod
 = new Runnable() {
 public void run() {
 ellipse(0, 0, 1, 1);
 textSize(0.4f);
 //textAlign(CENTER, CENTER);
 text("B", 0, 0);
 }
 };
 
 X_BUTTON = new Button(new PVector(
 ABXY_MID.x - 90, ABXY_MID.y + 90), 100);
 X_BUTTON.renderMethod
 = new Runnable() {
 public void run() {
 ellipse(0, 0, 1, 1);
 textSize(0.4f);
 //textAlign(CENTER, CENTER);
 text("X", 0, 0);
 }
 };
 
 Y_BUTTON = new Button(new PVector(
 ABXY_MID.x, ABXY_MID.y), 100);
 Y_BUTTON.renderMethod
 = new Runnable() {
 public void run() {
 ellipse(0, 0, 1, 1);
 textSize(0.4f);
 //textAlign(CENTER, CENTER);
 text("Y", 0, 0);
 }
 };
 
 L_BUTTON = new Button(new PVector(
 150, 250), 120);
 L_BUTTON.renderMethod
 = new Runnable() {
 public void run() {
 //rectMode(CENTER);
 rect(0, 0, 1.2f, 0.55f, 
 0.1f, 0.1f, 0.1f, 0.1f);
 textSize(0.4f);
 //textAlign(CENTER, CENTER);
 text("L", 0, 0);
 }
 };
 
 R_BUTTON = new Button(
 new PVector(
 width - 150, 250), 120);
 R_BUTTON.renderMethod
 = new Runnable() {
 public void run() {
 //rectMode(CENTER);
 rect(0, 0, 1.2f, 0.55f, 
 0.1f, 0.1f, 0.1f, 0.1f);
 textSize(0.4f);
 //textAlign(CENTER, CENTER);
 text("R", 0, 0);
 }
 };
 
 START_BUTTON = new Button(new PVector(
 cx - 180, height - 80), 120);
 START_BUTTON.renderMethod
 = new Runnable() {
 public void run() {
 //rectMode(CENTER);
 rect(0, 0, 1.2f, 0.55f, 
 0.1f, 0.1f, 0.1f, 0.1f);
 textSize(0.3f);
 //textAlign(CENTER, CENTER);
 text("START", 0, 0);
 }
 };
 
 SELECT_BUTTON = new Button(new PVector(
 cx + 180, height - 80), 120);
 SELECT_BUTTON.renderMethod
 = new Runnable() {
 public void run() {
 //rectMode(CENTER);
 rect(0, 0, 1.2f, 0.55f, 
 0.1f, 0.1f, 0.1f, 0.1f);
 textSize(0.3f);
 //textAlign(CENTER, CENTER);
 text("SELECT", 0, 0);
 }
 };
 
 DPAD_CANCEL = new Button(new PVector(
 DPAD_MID.x, DPAD_MID.y), 60);
 DPAD_CANCEL.renderMethod
 = new Runnable() {
 public void run() {
 //rectMode(CENTER);
 fill(230, 10);
 rect(0, 0, 1, 1);
 }
 };
 }
 
 
 
 
 
 
 
 
 
 void input() {
 Buttons.nPresses = 0;
 for (int i = 0; i < 4; i++) {
 Button b = dpad[i];
 b.update();
 // Again, the order is:
 // "Up-Right, Left-Down".
 if (b.pressed)
 Buttons.nPresses++;
 
 
 // I know `2` sounds weird!:
 if (Buttons
 .nPresses == 2)
 b.pressed = false;
 }
 
 
 DPAD_CANCEL.update();
 if (DPAD_CANCEL.pressed)
 for (Button b : dpad)
 b.pressed = false;
 
 A_BUTTON.update();
 B_BUTTON.update();
 
 X_BUTTON.update();
 Y_BUTTON.update();
 
 L_BUTTON.update();
 R_BUTTON.update();
 
 START_BUTTON.update();
 SELECT_BUTTON.update();
 
 for (Button b : Buttons.all)
 if (b != DPAD_CANCEL && b.pressed) {
 Buttons.anyBtnPressed = true;
 Buttons.totalBtnPressed++;
 break;
 }
 
 Buttons.anyBtnPressed 
 &= nTouches != 0;
 }
 }
 
 class Button {
 PVector transform;
 float size;
 int touchId, pressDelay = 100;
 boolean pressed, ppressed, 
 timePressed, extended;
 Runnable renderMethod;
 
 Button() {
 this.transform 
 = new PVector();
 this.size = 40;
 Buttons.all
 .add(this);
 }
 
 Button(PVector _transform, 
 float _size) {
 this.transform = _transform;
 this.size = _size;
 Buttons.all.add(this);
 }
 
 void update() {
 if (this.pressed) {
 if (millis() > touchStartTimers[
 this.touchId] + this.pressDelay)
 this.timePressed = true;
 } else this.timePressed = false;
 
 // ..will probably just let 
 // it calculate all of this 
 // each frame.
 
 // Optimization is awesome, 
 // but I don"t want getters 
 // and setters!
 
 this.ppressed = this.pressed;
 this.pressed = false;
 
 for (int i = 0; 
 i < nTouches; i++) {
 if (this.extended)
 // Why an `|=`?
 // It works with just `=`, 
 // too...
 this.pressed |= 
 projectedTouches[i].x < 
 this.transform.x 
 + this.size 
 - this.size / 8 &&
 projectedTouches[i].x > 
 this.transform.x
 - this.size 
 + this.size / 8 &&
 projectedTouches[i].y < 
 this.transform.y
 + this.size 
 - this.size / 8 &&
 projectedTouches[i].y > 
 this.transform.y
 - this.size
 + this.size / 8;
 
 //                 //
 // Shorter bounds: //
 //                 //
 
 else this.pressed |= 
 projectedTouches[i].x < 
 this.transform.x 
 + this.size 
 - this.size / 3 &&
 projectedTouches[i].x > 
 this.transform.x
 - this.size 
 + this.size / 3 &&
 projectedTouches[i].y < 
 this.transform.y
 + this.size 
 - this.size / 3 &&
 projectedTouches[i].y > 
 this.transform.y
 - this.size
 + this.size / 3;
 
 if (this.pressed) {
 this.touchId = i;
 break;
 }
 }
 
 // The `touches` array has 
 // data only when touches 
 // actually exist on the 
 // screen, so, 
 
 // ..do I actually need this?!:
 this.pressed &= mouseLeft;
 
 // Answer? Yes.
 // Apparently I needed to do 
 // this once I started to 
 // use projection and needed 
 // to un-project coordinates.
 } 
 
 // Not used inside `update()`
 // to reduce function calls:
 boolean hitTest(float _x, float _y) {
 return this.extended?
 // Why an `|=`?
 // It works with just `=`, 
 // too...
 _x < 
 this.transform.x 
 + this.size 
 - this.size / 8 &&
 _x > 
 this.transform.x
 - this.size 
 + this.size / 8 &&
 _y < 
 this.transform.y
 + this.size 
 - this.size / 8 &&
 _y > 
 this.transform.y
 - this.size
 + this.size / 8
 
 // Second part of ternary:
 :
 //
 
 //                 //
 // Shorter bounds: //
 //                 // 
 _x < 
 this.transform.x 
 + this.size 
 - this.size / 3 &&
 _x > 
 this.transform.x
 - this.size 
 + this.size / 3 &&
 _y < 
 this.transform.y
 + this.size 
 - this.size / 3 &&
 _y > 
 this.transform.y
 - this.size
 + this.size / 3;
 }
 
 void render() {
 pushMatrix();
 pushStyle();
 
 translate(this.transform.x, 
 this.transform.y);
 scale(this.size);
 rotate(this.transform.z);
 
 fill(120, 
 this.pressed? 200 : 100);
 
 // This failed to work:
 ///<asterisk> strokeCap(//SQUARE
 //PROJECT //ROUND); <asterisk>/
 
 // No stroke? Modern, sleek.
 // Stroked? Good hand-drawn look.
 noStroke(); // Need this.
 //stroke(120, 160);
 //strokeWeight(0.075f);
 
 this.renderMethod.run();
 
 popMatrix();
 popStyle();
 }
 }
 */
