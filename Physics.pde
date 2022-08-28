import fisica.*;
import com.jme3.bounding.*;
import com.jme3.bullet.collision.*;
import com.jme3.bullet.collision.shapes.*;
import com.jme3.bullet.collision.shapes.infos.*;
import com.jme3.bullet.*;
import com.jme3.bullet.joints.*;
import com.jme3.bullet.joints.motors.*;
import com.jme3.bullet.objects.infos.*;
import com.jme3.bullet.objects.*;
import com.jme3.bullet.util.*;
import com.jme3.math.*;
import com.jme3.system.*;
import com.jme3.util.*;
import com.simsilica.mathd.*;
import jme3utilities.lbj.*;
import jme3utilities.math.*;
import jme3utilities.minie.*;
import jme3utilities.*;
import vhacd.*;
import vhacd4.*;

FWorld b2d;
PhysicsSpace bt;

boolean b2dShouldUpdate, btShouldUpdate;

void destroyB2DBody(FBody p_body) {
  b2d.remove(p_body);
  currentScene.B2D_BODIES.remove(p_body);
}

void removeFromB2D(FBody p_body) {
  b2d.remove(p_body);
}

void addToB2D(FBody p_body) {
  b2d.add(p_body);
}

FBox createFBox(float p_width, float p_height) {
  FBox ret = new FBox(p_width, p_height);
  currentScene.B2D_BODIES.add(ret);
  return ret;
}

FCircle createFCircle(float p_radius) {
  FCircle ret = new FCircle(p_radius);
  currentScene.B2D_BODIES.add(ret);
  return ret;
}

FCompound createFCompound() {
  FCompound ret = new FCompound();
  currentScene.B2D_BODIES.add(ret);
  return ret;
}

PhysicsSpace createBTWorld() {
  PhysicsSpace ret = new PhysicsSpace(
    new Vector3f(-1.5 * INIT_WIDTH, -1.5 * INIT_HEIGHT, -1.5 * INIT_DEPTH), 
    new Vector3f(1.5 * INIT_WIDTH, 1.5 * INIT_HEIGHT, 1.5 * INIT_DEPTH), 
    PhysicsSpace.BroadphaseType.AXIS_SWEEP_3);
  btShouldUpdate = true;
  return ret;
}

PhysicsSpace createBTWorld(float p_width, float p_height, float p_depth) {
  // ...opTIMIZATIONNNNN:
  float w = p_width * 0.5f, h = p_height * 0.5f, d = p_depth * 0.5f;
  PhysicsSpace ret = new PhysicsSpace(new Vector3f(-w, -h, -d), new Vector3f(w, h, d), 
    PhysicsSpace.BroadphaseType.AXIS_SWEEP_3);
  btShouldUpdate = true;
  return ret;
}

PhysicsSpace createBTWorld(PVector p_min, PVector p_max) {
  PhysicsSpace ret = new PhysicsSpace(toVector3f(p_min), toVector3f(p_max), 
    PhysicsSpace.BroadphaseType.AXIS_SWEEP_3);
  btShouldUpdate = true;
  return ret;
}

PhysicsSpace createBTWorld(Vector3f p_min, Vector3f p_max) {
  PhysicsSpace ret = new PhysicsSpace(p_min, p_max, 
    PhysicsSpace.BroadphaseType.AXIS_SWEEP_3);
  btShouldUpdate = true;
  return ret;
}

// Fisica/Box2D stuff:

FWorld createB2DWorld() {
  // It's fine - this is the world of Computer Graphics! CALCULATE! :(
  FWorld ret = new FWorld(-1.5f * INIT_WIDTH, -1.5f * INIT_HEIGHT, 
    1.5f * INIT_WIDTH, 1.5f * INIT_HEIGHT);
  ret.setGrabbable(false);
  return ret;
}

FWorld createB2DWorld(float p_width, float p_height) {
  // It's fine - this is the world of Computer Graphics! CALCULATE! :(  
  FWorld ret = new FWorld(-p_width * 0.5f, -p_height * 0.5f, 
    p_width * 0.5f, p_height * 0.5f);
  ret.setGrabbable(false);
  return ret;
}

// `PVector` to Java's `Vector3f`: 
void setPVector(PVector p_toSet, Vector3f p_to) {
  p_toSet.set(p_to.x, p_to.y, p_to.z);
}

PVector toPVector(Vector3f p_vec) {
  return new PVector(p_vec.x, p_vec.y, p_vec.z);
}

Vector3f toVector3f(PVector p_vec) {
  return new Vector3f(p_vec.x, p_vec.y, p_vec.z);
}
