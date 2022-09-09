class Entity extends EventReceiver {
  String name = null;
  int tag;
  boolean enabled = true;
  ArrayList<Component> components;

  Entity() {
    this.components = new ArrayList<Component>();

    if (currentScene != null)
      currentScene.addEntity(this);
  }

  public void addComponent(Component p_component) {
    this.components.add(p_component);
  }

  // Remember: ONLY call `getComponent()` in `setup()`!
  public <T extends Component> T getComponent(Class p_class) {
    for (Component c : this.components) {
      if (c.getClass() == p_class)
        return (T)c;
    }
    return null;
  }

  public void setup() {
  }

  public void update() {
  }

  // No need to fill with instructions if unused:
  public void render() {
  }

  public void postRender() {
  }

  public Entity addToScene(Scene p_scene) {
    p_scene.addEntity(this);
    return this;
  }
}

class Component extends EventReceiver {
  public boolean enabled = true;
  public Entity parent; // Components are never nested. Not even in Unity. (Godot does this...)
  //public boolean penabled; // Unity has an `onAwake()`.

  Component(Entity p_entity) {
    this.parent = p_entity;

    if (this.parent != null)
      this.parent.addComponent(this);

    if (currentScene != null)
      currentScene.components.add(this);
  }

  // Format:
  //Component(Entity p_entity, Component... p_componentsNeeded) { this.parent = p_entity; }
  //public void update() { }
  //public void disabledUpdate() { }

  public void update() {
  }

  public void disabledUpdate() {
  }
}

class SerializableComponent extends Component {
  SerializableComponent(Entity p_entity) {
    super(p_entity);
  }

  // Complete Format:
  //Component(Entity p_entity, Component... p_componentsNeeded) { this.parent = p_entity; }
  //public void update() { }
  //public void read(String p_fname) { }
  //public void read(String p_fname, OnCatch p_catcher) { }
  //public void write(String p_fname) { }

  @SuppressWarnings("unused")
    public void read(String p_fname) {
  }

  @SuppressWarnings("unused")
    void read(String p_fname, OnCatch p_catcher) {
  }

  @SuppressWarnings("unused")
    public void write(String p_fname) {
  }
}

ArrayList<EventReceiver> eventReceivers = new ArrayList<EventReceiver>();
class EventReceiver {
  // Input Events:

  void mousePressed() {
  }

  void mouseMoved() {
  }

  @SuppressWarnings("unused")
    void mouseWheel(MouseEvent p_event) {
  }

  void mouseClicked() {
  }

  void mouseDragged() {
  }

  void mouseReleased() {
  }

  void keyPressed() {
  }

  void keyTyped() {
  }

  void keyReleased() {
  }

  // Window events:

  void fullscreenGained() {
  }

  void fullscreenLost() {
  }

  void windowResized() {
  }

  void focusLost() {
  }

  void focusGained() {
  }
}
