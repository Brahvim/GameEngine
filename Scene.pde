final ArrayList<Scene> SCENES = new ArrayList<Scene>(3); // Contains all scenes!
Scene currentScene = null; // Reference to the current scene.

void addScene(Scene p_scene) {
  SCENES.add(p_scene);
}

void setScene(Scene p_scene) {
  if (currentScene != null && currentScene.deleteOnUnload)
    currentScene.deleteScene();

  p_scene.timesReloaded++;
  currentScene = p_scene;

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

  p_scene.setup(); // Calling this later so that entities inside the scene
  // ...can add themselves into the scene's `ArrayList<Entity> entities`.

  for (Entity e : p_scene.entities)
    e.setup();

  // This was such a joke LOL:
  /*
  // DO NOT use `getFields()`! That will scan for ones from `super` classes as well!
   String sceneName = null;
   for (Field f : this.getClass().getDeclaredFields())
   try {
   Scene a = null;
   if (f.get(a) == p_scene)
   println(f.getName());
   }
   catch(Exception iae) {
   //logEx(iae);
   }
   
   logInfo("Scene ", sceneName, " was set in place perfectly! Yay!");
   */
}

class Scene extends EventReceiver {
  HashMap<Integer, Entity> namedEntities;
  ArrayList<Entity> entities;
  ArrayList<Component> components;
  ArrayList<Renderer> renderers;
  ArrayList<FBody> B2D_BODIES;
  ArrayList<PhysicsBody> BT_BODIES;

  boolean deleteOnUnload = true;
  int timesReloaded = 0;

  Scene() {
    SCENES.add(this);

    this.namedEntities = new HashMap<Integer, Entity>();
    this.entities = new ArrayList<Entity>();
    this.components = new ArrayList<Component>();
    this.renderers = new ArrayList<Renderer>();
    this.B2D_BODIES = new ArrayList<FBody>();
    this.BT_BODIES = new ArrayList<PhysicsBody>();
  }

  Scene(int p_entCount) {
    this.namedEntities = new HashMap<Integer, Entity>(p_entCount);
    this.entities = new ArrayList<Entity>(p_entCount);
    this.components = new ArrayList<Component>(2 * p_entCount);
    this.renderers = new ArrayList<Renderer>(p_entCount);
    this.B2D_BODIES = new ArrayList<FBody>(p_entCount);
    this.BT_BODIES = new ArrayList<PhysicsBody>(p_entCount);
  }

  Scene addEntity(Entity p_entity) {
    /* 
     // *String ID bab:*
     Class entClass = p_entity.getClass();
     String entName = entClass.getSimpleName(); // Only a pointer, no allocations ..:D!
     int howMany = 1;
     
     for (Map.Entry<Integer, Entity> e : namedEntities.entrySet())
     if (e.getKey().getClass() == entClass)
     howMany++;
     
     this.namedEntities.put(entName.concat(Integer.toString(howMany)), p_entity);
     */

    this.namedEntities.put(this.entities.size(), p_entity);
    this.entities.add(p_entity); // Nah, I don't wanna get an iterator for my map, :P
    return this;
  }

  Scene addEntity(String p_name, Entity p_entity) {
    p_entity.name = p_name;
    this.namedEntities.put(this.entities.size(), p_entity);
    this.entities.add(p_entity); // Nah, I don't wanna get an iterator for my map, :P
    return this;
  }

  // ..back in the simpler days:
  /*
  Scene addEntity(Entity p_entity) {
   this.entities.add(p_entity);
   return this;
   }
   */

  Entity getEntityOfType(Class p_entClass) {
    for (Entity e : this.entities)
      if (e.getClass() == p_entClass) 
        return e;
    return null;
  }

  Entity[] getEntitiesOfType(Class p_entClass) {
    ArrayList<Entity> ret = new ArrayList<Entity>();
    for (Entity e : this.entities)
      if (e.getClass() == p_entClass) {
        ret.add(e);
      }
    return (Entity[])ret.toArray();
  }

  Entity getEntityNamed(String p_name) {
    for (Entity e : this.entities)
      if (e.name == p_name)
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
  /*
  void update() {
   // Components are updated first:
   for (Component c : this.components)
   if (c.enabled)
   c.update();
   
   for (Entity e : this.entities)
   e.update();
   }
   */

  void draw() {
    for (Entity e : this.entities)
      e.render();

    for (Renderer r : this.renderers)
      r.update();
  }

  // Convention: use what is easier to type (..and see)!
  // `drawUI()` is easy to type since there are parenthesis right after it, and you need to hold
  // `Shift` to type them.
  // `XmlDocParser` may not be *all that easy* to type, but is more readable than `XMLDOCParser`.
  void drawUI() {
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
    System.gc();
  }

  // ...useless! The Scene will still run `.setup()` and load new objects.
  // Should have a way to initialize Scenes without object creation (now called `.reset()`).
  // That should be done with a method, since certain objects' constructors might rely on others'.
  // Cannot expect user to do it when declaring variables in the class that extends `Scene`...
}
