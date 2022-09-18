class Entity extends EventReceiver {
  //String name = null;
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
    for (Component c : this.components)
      if (c.getClass().equals(p_class))
        return (T)c;
    return null;
  }

  public <T extends Component> T getComponentSubbing(Class p_class) {
    for (Component c : this.components)
      if (c.getClass().isAssignableFrom(p_class))
        return (T)c;
    return null;
  }

  public ArrayList<Component> getComponents(Class p_class) {
    ArrayList<Component> ret = new ArrayList<Component>();

    for (Component c : this.components)
      if (c.getClass().equals(p_class))
        ret.add(c);

    if (ret.isEmpty())
      return null;
    return ret;
  }

  public ArrayList<? extends Component> getComponentsSubbing(Class p_class) {
    ArrayList<Component> ret = new ArrayList<Component>();

    for (Component c : this.components)
      if (c.getClass().isAssignableFrom(p_class))
        ret.add(c);

    if (ret.isEmpty())
      return null;
    return ret;
  }

  // These should NOT be used...:
  // How are you going to handle `null` components as the user...?
  public void removeComponent(Component p_component) {
    this.components.remove(p_component);
    currentScene.components.remove(p_component);
  }

  public void removeComponentTyped(Class p_class) {
    Component component = null;

    for (Component c : this.components)
      if (c.getClass().equals(p_class))
        component = c;

    if (component != null) {
      this.components.remove(component);
      currentScene.components.remove(component);
    }
  }

  public void removeComponentSubbing(Class p_class) {
    Component component = null;

    for (Component c : this.components)
      if (c.getClass().isAssignableFrom(p_class))
        component = c;

    if (component != null) {
      this.components.remove(component);
      currentScene.components.remove(component);
    }
  }

  public void removeAllComponentsTyped(Class p_class) {
    ArrayList<Component> components = new ArrayList<Component>();

    for (Component c : this.components)
      if (c.getClass().equals(p_class))
        components.add(c);

    if (!components.isEmpty())
      for (Component c : components) {
        this.components.remove(c);
        currentScene.components.remove(c);
        //System.gc(); }
      }
  }

  public void removeAllComponentsSubbing(Class p_class) {
    ArrayList<Component> components = new ArrayList<Component>();

    for (Component c : this.components)
      if (c.getClass().isAssignableFrom(p_class))
        components.add(c);

    if (!components.isEmpty())
      for (Component c : components) {
        this.components.remove(c);
        currentScene.components.remove(c);
      }
    //System.gc(); }
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
