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

/*

 // Scenes!
 
 
 */

final ArrayList<Scene> SCENES = new ArrayList<Scene>(3); // Contains all scenes!
Scene currentScene = null; // Reference to the current scene.

void addScene(Scene p_scene) {
  SCENES.add(p_scene);
}

<T> void addScene(Class p_sceneClass) {
  try {
    Constructor<T> constructor = p_sceneClass.getConstructor();
    SCENES.add((Scene)constructor.newInstance());
  }
  catch (InstantiationException e) {
    nerdLogError("Could not instantiate that class...");
  }
  catch (IllegalAccessException e) {
    nerdLogError("Ayo, no private scene classes >:O");
    nerdLogEx(e);
  }
  catch (NoSuchMethodException e) {
    nerdLogError("No constructor for this `Scene` -_-");
    nerdLogEx(e);
  }
  catch (InvocationTargetException e) {
    nerdLogEx(e);
  }
}

void switchScene(Scene p_scene) {
  if (p_scene == null)
    throw new NullPointerException("`switchScene(null);` won't work.");

  // Delete everything!:
  if (currentScene != null && currentScene.deleteOnUnload)
    currentScene.deleteScene();

  System.gc(); // We just removed a bunch'a stuff, y'know?

  currentScene = null; // This is for the code below, LOL.

  String sceneName = null; // It'll definitely have something in it, right..?
  for (Field f : SKETCH_FIELDS)
  try {
    if (f.get(SKETCH) == p_scene) {
      sceneName = f.getName();
    }
  }
  catch (IllegalAccessException e) {
    nerdLogEx(e); // Shouldn't occur unless `p_scene` is `null`, ...which won't work!
  }

  p_scene.timesReloaded++;
  currentScene = p_scene;

  nerdLogInfo("Switched to scene `", sceneName, "` just in time. Yay!");
}

void setScene(Scene p_scene) {
  if (p_scene == null)
    throw new NullPointerException("`setScene(null);` won't work.");

  // Delete everything!:
  if (currentScene != null && currentScene.deleteOnUnload)
    currentScene.deleteScene();

  System.gc(); // We just removed a bunch'a stuff, y'know?

  currentScene = null; // This is for the code below, LOL.

  String sceneName = null; // It'll definitely have something in it, right..?
  for (Field f : SKETCH_FIELDS)
  try {
    if (f.get(SKETCH) == p_scene) {
      sceneName = f.getName();
    }
  }
  catch (IllegalAccessException e) {
    nerdLogEx(e); // Shouldn't occur unless `p_scene` is `null`, ...which won't work!
  }

  int startt = millis();
  p_scene.timesReloaded++;
  currentScene = p_scene;

  p_scene.setup(); // Calling this later so that entities inside the scene
  // ...can add themselves into `currentScene`'s `ArrayList<Entity> entities`.

  for (Entity e : p_scene.entities)
    e.setup();
  int time = millis() - startt;

  nerdLogInfo("Scene `", sceneName, "` was set in place perfectly in `", time, "`ms. Yay!");
}

class Scene extends EventReceiver {
  HashMap<Integer, Entity> namedEntities;
  ArrayList<Entity> entities;
  ArrayList<Component> components;
  ArrayList<RenderingComponent> renderers;
  ArrayList<FBody> B2D_BODIES;
  ArrayList<PhysicsBody> BT_BODIES;

  boolean deleteOnUnload = true;
  int timesReloaded = 0;

  Scene() {
    SCENES.add(this);

    this.namedEntities = new HashMap<Integer, Entity>();
    this.entities = new ArrayList<Entity>();
    this.components = new ArrayList<Component>();
    this.renderers = new ArrayList<RenderingComponent>();
    this.B2D_BODIES = new ArrayList<FBody>();
    this.BT_BODIES = new ArrayList<PhysicsBody>();
  }

  // This was used to allocate memory that would ALWAYS go unused:
  //Scene(int p_entCount) {
  //this.namedEntities = new HashMap<Integer, Entity>(p_entCount);
  //this.entities = new ArrayList<Entity>(p_entCount);
  //this.components = new ArrayList<Component>(3 * p_entCount);
  //this.renderers = new ArrayList<RenderingComponent>(p_entCount);
  //this.B2D_BODIES = new ArrayList<FBody>(p_entCount);
  //this.BT_BODIES = new ArrayList<PhysicsBody>(p_entCount);
  //}

  Scene addEntity(Entity p_entity) {
    this.namedEntities.put(this.entities.size(), p_entity);
    this.entities.add(p_entity); // Nah, I don't wanna get an iterator for my map everytime, :P
    return this;
  }

  Scene addEntity(Entity p_entity, int p_tag) {
    p_entity.tag = p_tag;
    this.namedEntities.put(this.entities.size(), p_entity);
    this.entities.add(p_entity);
    return this;
  }

  Scene addEntity(Entity p_entity, String p_name) {
    p_entity.name = p_name;
    this.namedEntities.put(this.entities.size(), p_entity);
    this.entities.add(p_entity);
    return this;
  }

  Scene addEntity(Entity p_entity, String p_name, int p_tag) {
    p_entity.name = p_name;
    p_entity.tag = p_tag;
    this.namedEntities.put(this.entities.size(), p_entity);
    this.entities.add(p_entity);
    return this;
  }

  Entity getEntityTyped(Class p_class) {
    for (Entity e : this.entities)
      if (e.getClass().equals(p_class)) 
        return e;
    return null;
  }

  Entity[] getEntitiesTyped(Class p_class) {
    ArrayList<Entity> ret = new ArrayList<Entity>();
    for (Entity e : this.entities)
      if (e.getClass().equals(p_class))
        ret.add(e);
    if (ret.isEmpty()) 
      return null;
    return (Entity[])ret.toArray();
  }

  Entity[] getEntitiesSubbing(Class p_class) {
    ArrayList<Entity> ret = new ArrayList<Entity>();
    for (Entity e : this.entities)
      if (e.getClass().isAssignableFrom(p_class))
        ret.add(e);
    if (ret.isEmpty()) 
      return null;
    return (Entity[])ret.toArray();
  }

  Entity getEntityNamed(String p_name) {
    for (Entity e : this.entities)
      if (e.name.equals(p_name))
        return e;
    return null;
  }

  Entity[] getEntitiesWithTag(int p_tag) {
    ArrayList<Entity> ret = new ArrayList<Entity>();
    for (Entity e : this.entities)
      if (e.tag == p_tag)
        ret.add(e);
    if (ret.isEmpty()) 
      return null;
    return (Entity[])ret.toArray();
  }

  Entity getEntityWithTag(int p_tag) {
    for (Entity e : this.entities)
      if (e.tag == p_tag)
        return e;
    return null;
  }

  // Execution structure:

  void onReload() {
  }

  void setup() {
  }

  void reset() {
  }

  void preUpdate() {
  }

  // Pretty much always unused:

  //void update() {
  // Components are updated first:
  //for (Component c : this.components)
  //if (c.enabled)
  //c.update();
  //
  //for (Entity e : this.entities)
  //e.update();
  //}

  void draw() {
    for (Entity e : this.entities)
      e.render();

    for (RenderingComponent r : this.renderers)
      r.update();
  }

  // Convention: use what is easier to type (..and see)!
  // `drawUI()` is easy to type since there are parenthesis right after it, and you need to hold
  // `Shift` to type them.
  // `XmlDocParser` may not be *all that easy* to type, but is more readable than `XMLDOCParser`.
  void drawUi() {
  }

  // Unity also does this.
  // Can be disabled by setting `deleteOnUnload` to `false`,
  // ...if the scene is loaded up often.
  void deleteScene() {
    this.components.clear();
    this.entities.clear();
    this.renderers.clear();
    this.B2D_BODIES.clear();
    this.BT_BODIES.clear();

    // Reset Physics Engines:
    // TODO: reset gravity?
    if (bt != null) {
      for (PhysicsRigidBody b : bt.getRigidBodyList())
        bt.remove(b);

      for (PhysicsJoint j : bt.getJointList())
        bt.remove(j);

      for (PhysicsVehicle v : bt.getVehicleList())
        bt.remove(v);

      for (PhysicsCharacter c : bt.getCharacterList())
        bt.remove(c);

      for (PhysicsGhostObject o : bt.getGhostObjectList())
        bt.remove(o); // Is this one even necessary...?
    }

    if (b2d != null)
      b2d.clear();
  }

  // ...useless! The Scene will still run `.setup()` and load new objects.
  // Should have a way to initialize Scenes without object creation (now called `.reset()`).
  // That should be done with a method, since certain objects' constructors might rely on others'.
  // Cannot expect user to do it when declaring variables in the class that extends `Scene`...
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