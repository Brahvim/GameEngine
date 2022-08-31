class Entity extends EventReceiver {
  String name = null;
  boolean enabled = true;

  Entity() {
    this.components = new ArrayList<Component>();

    // Filter out the various other Entity types!:
    //String gotName = this.getClass().getSimpleName();
    //if (gotName != "Entity")
    //this.name = gotName;

    if (currentScene != null)
      currentScene.addEntity(this);
  }

  // In the case I need this mess ever again:

  ArrayList<Component> components;

  public void addComponent(Component p_component) {
    this.components.add(p_component);
  }

  // Remember: ONLY call `getComponent()` in `setup()`!
  public <T extends Component> T getComponent(Class p_class) {
    for (Component c : this.components) {
      //println("Found component", c, "in Entity", this.name);
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

// Removed these for the sake of Entity name checking :joy:.
// The deep hierarchy tree could still cause issues, though.
/*
// Deep hierarchy tree, bad idea?
 class EntityWithTransform extends Entity {
 // Remember: ONLY call `getComponent()` in `setup()`!
 Transform form = new Transform(this); // Saves us typing, thus this is a good idea.
 }
 class EntityWithRenderer extends EntityWithTransform {
 Renderer display;
 EntityWithRenderer(RendererType p_type) {
 this.display = new Renderer(this, this.form, p_type);
 }
 
 EntityWithRenderer(RendererType p_type, Asset p_textureLoader) {
 this.display = new Renderer(this, this.form, p_type, p_textureLoader);
 }
 
 EntityWithRenderer(RendererType p_type, PImage p_texture) {
 this.display = new Renderer(this, this.form, p_type, p_texture);
 }
 }
 
 class EntityWithMaterialAndRenderer extends EntityWithRenderer {
 Renderer display;
 EntityWithMaterialAndRenderer(RendererType p_type) {
 super(p_type);
 }
 
 EntityWithMaterialAndRenderer(RendererType p_type, Asset p_textureLoader) {
 super(p_type, p_textureLoader);
 }
 
 EntityWithMaterialAndRenderer(RendererType p_type, PImage p_texture) {
 super(p_type, p_texture);
 }
 }
 
 class EntityWithLight extends Entity {
 Transform form;
 Light light;
 
 EntityWithLight() {
 this.form = new Transform(this);
 this.light = new Light(this, this.form, POINT);
 }
 
 EntityWithLight(int p_lightType) {
 this.form = new Transform(this);
 this.light = new Light(this, this.form, p_lightType);
 }
 }
 */
// The reason why we don't have:
// `EntityWith2DPhysics`
// `EntityWith3DPhysics`
// ...etcetera, is because:
// ...I have no idea what Physics object you would store in your entity!


class Component {
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

  public void update() {
  }
}
