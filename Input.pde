PVector mouse = new PVector(), pmouse = new PVector();
int mouseScroll, pmouseScroll, mouseScrollDelta;
boolean cursorVisible = true, cursorConfined;

char pkey, pframekey; 
boolean pkeyPressed, pmousePressed;
boolean mouseLeft, mouseMid, mouseRight;
boolean pmouseLeft, pmouseMid, pmouseRight;
int pmouseButton;
int pkeyCode, pframekeyCode;
int lastMousePressTime, lastKeyPressTime;

ArrayList<Integer> keysHeld = new ArrayList<Integer>();

final File DATA_FOLDER = new File(sketchPath("data" + File.separator));
HashMap<String, PImage> cursorImages;

void loadCursorImages() {
  //File data = new File(sketchPath(""));
  cursorImages = new HashMap<String, PImage>();
}

boolean keyIsPressed(int p_keyCode) {
  return keysHeld.contains(p_keyCode);
}

boolean keysPressed(int... p_keyCodes) {
  boolean flag = true;

  for (int i : p_keyCodes)
    flag &= keysHeld.contains(i); // ...yeah, `|=` and not `&=`...

  return flag;
}

void unprojectMouse() {
  //mouse.set(new float[0]);
  mouse.set(mouseX, mouseY);
  //mouse.set((float)mouseX / (float)width, (float)mouseY / (float)height);

  //FloatBuffer modelview = FloatBuffer.allocate(16);
  //modelview.put(glGraphics.modelview.get(null));

  //u.captureViewMatrix((PGraphics3D)g);
  //u.gluUnProject(mouseX, height - mouseY, 0.8f, mouse);


  //float[]f=null;
  //new PMatrix3D().set(f);

  //glu.gluUnProject();

  // The order does not matter:
  mouse = glGraphics.camera.mult(mouse, null);
  mouse = glGraphics.modelviewInv.mult(mouse, null);

  // [https://www.gamedev.net/forums/topic/675595-math-behind-gluunproject/]
  // Multiply the resulting point by the inverse of the `(model * projection)` matrix.
  /*
  PMatrix3D model = glGraphics.modelview.get();
   model.apply(glGraphics.camera);
   //model.apply(glGraphics.projection);
   model.invert();
   
   mouse = model.mult(mouse, null);
   mouse.sub(width, 0);
   mouse.y = Math.abs(mouse.y);
   mouse.y -= height;
   */
  //mouse.z += 25;
  //println(mouse);
}



//  Remember that these (variables) exist!:
//  `mouseButton`,
//  `mouseX`, `mouseY`,
//  `pmouseX` `pmouseY`.
// ----------------------
//  `keyPressed`,
//  `keyCode`, `key`.

final char[] VALID_SYMBOLS = {
  '\'', '\"', '-', '=', '`', '~', '!', '@', '#', '$', 
  '%', '^', '&', '*', '(', ')', '{', '}', '[', 
  ']', ';', ',', '.', '/', '\\', ':', '|', '<', 
  '>', '_', '+', '?'
};


boolean isValidSymbol(char p_char) {
  //boolean is = false;
  for (char ch : VALID_SYMBOLS)
    if (ch == p_char) return true;

  // These used to be in the loop:
  //is = ch == p_char;
  //is |= ch == p_char;
  //return is;

  return false;
}

boolean isTypeable(char p_char) {
  return Character.isDigit(p_char) ||
    Character.isLetter(p_char) ||
    Character.isWhitespace(p_char) ||
    isValidSymbol(p_char);
}

char getTypedKey() {
  if (isTypeable(key))
    return key;

  switch (keyCode) {
  case BACKSPACE:
    return '\b';
  case RETURN:
  case ENTER:
    return '\n';
  default:
    return '\0';
  }


  // """"""""Slow"""""""":
  //if (keyCode == BACKSPACE)
  //  return '\b';
  //else if (keyCode == RETURN || keyCode == ENTER)
  //  return '\n';
  //else if (isTypeable(key))
  //  return key;
  //else return '\0';
}

void addTypedKeyTo(String p_str) {
  char t = getTypedKey();
  int l = p_str.length();

  if (t == '\b' && l > 0)
    p_str.substring(l - 1, l);

  else p_str.concat(Character.toString(t));
}

void addTypedKeyTo(StringBuilder p_str) {
  char t = getTypedKey();
  int l = p_str.length();

  if (t == '\b' && l > 0)
    p_str.substring(l - 1, l);

  else p_str.append(Character.toString(t));
}

// To be used for checking if a certain key can be typed:
boolean isNotSpecialKey(int p_keyCode) {
  // I just didn't want to make an array :joy::
  return !(
    // For all function keys [regardless of whether `Shift`  or `Ctrl` are pressed]:
    p_keyCode > 96 && p_keyCode < 109 || 
    p_keyCode == 0   || // `Fn`, plus a function key.
    p_keyCode == 2   || // `Home`,
    p_keyCode == 3   || // `End`,
    p_keyCode == 8   || // `Backspace`,
    p_keyCode == 10  || // Both `Enter`s/`Return`s.
    p_keyCode == 11  || // `PageDown`,
    p_keyCode == 12  || // Resistered when a button is pressed on the numpad with `NumLock` off.
    p_keyCode == 16  || // `PageUp`,
    p_keyCode == 19  || // "`Alt`-Graph',
    p_keyCode == 20  || // `CapsLock`,
    p_keyCode == 23  || // `ScrollLock`,
    p_keyCode == 26  || // `Insert`,
    p_keyCode == 147 || // Both `Delete` keys,
    p_keyCode == 148 || // `Pause`/`Break` and also `NumLock`,
    p_keyCode == 153 || // `Menu`/`Application` AKA "RightClick" key.
    p_keyCode == 157    // "Meta", AKA the "OS key".
    );
}
