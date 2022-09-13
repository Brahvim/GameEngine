class Button {
  PVector transform;
  float size;
  int fill, stroke;
  boolean ppressed, pressed, hovered, phovered;
  SineWave wave = new SineWave();
  Runnable renderMethod, hoverMethod, clickMethod;

  Button(float p_x, float p_y, float p_size) {
    this.transform = new PVector(p_x, p_y);
    this.size = p_size;
  }

  // Constructor overloading may exist, but I like this:
  Button(float p_x, float p_y, float p_size, float p_rot) {
    this.transform = new PVector(p_x, p_y, p_rot);
    this.size = p_size;
  }

  void setPos(float p_x, float p_y) {
    this.transform.set(p_x, p_y);
  }

  void setRot(float p_rot) {
    this.transform.z = p_rot;
  }

  void setTransform(float p_x, float p_y, float p_rot) {
    this.transform.set(p_x, p_y, p_rot);
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
