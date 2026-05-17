PShape[] frames;
int[] DUR_MS = { 7000, 9000, 8000, 15000, 11000, 7000, 13000, 25000 };
String[] SVG_FILES = {
  "frames-01.svg",
  "frames-02.svg",
  "frames-03.svg",
  "frames-04.svg",
  "frames-05.svg",
  "frames-6.svg",
  "frames-7.svg",
  "frames-8.svg"
};

// --- frames-01 ---
final int[] F01_HOJA = { 0, 45, 46 };
final int F01_OJOS_LO = 3, F01_OJOS_HI = 13;
final int F01_NARIZ = 8;
final int[] F01_ANTENAS = { 33, 35, 36, 41 };

// --- frames-03 reveal ---
final int F03_NUM = 7;
final int[] F03_REVEAL_ORDER = { 0, 5, 2, 3, 4, 1, 6 };
int[] f03RevealSlot;

// --- frames-04 reveal ---
final int F04_NUM = 13;
final int[] F04_REVEAL_ORDER = { 0, 9, 6, 2, 12, 3, 4, 7, 8, 5, 1, 10, 11 };
int[] f04RevealSlot;

// --- frames-05 ---
final int F05_SLOTS = 12;

// --- frames-07: capas que aparecen en secuencia (13 s) ---
final int F07_LAYERS = 7;

void setup() {
  size(1440, 900, P2D);
  frames = new PShape[SVG_FILES.length];
  for (int i = 0; i < SVG_FILES.length; i++) {
    frames[i] = loadShape(SVG_FILES[i]);
  }

  int n = countSvgLeaves(frames[0]);
  if (n != 63) {
    println("frames-01: hojas = " + n + " (esperado 63).");
  }

  f03RevealSlot = buildRevealSlots(F03_NUM, F03_REVEAL_ORDER);
  int n3 = countSvgLeaves(frames[2]);
  if (n3 != F03_NUM) {
    println("frames-03: hojas = " + n3 + " (esperado " + F03_NUM + ").");
  }

  f04RevealSlot = buildRevealSlots(F04_NUM, F04_REVEAL_ORDER);
  int n4 = countSvgLeaves(frames[3]);
  if (n4 != F04_NUM) {
    println("frames-04: hojas = " + n4 + " (esperado " + F04_NUM + ").");
  }

  PShape doc5 = frames[4];
  PShape f05e = findShapeById(doc5, "f05_leaves_early");
  if (f05e != null && f05e.getChildCount() != 7) {
    println("frames-05: f05_leaves_early hijos=" + f05e.getChildCount() + " (esperado 7).");
  }
  String[] need5 = {
    "f05_bg", "f05_leaves_early", "f05_adjunto1", "f05_adjunto2",
    "f05_leaf_st49", "f05_bug_core", "f05_leaves_front"
  };
  for (String id : need5) {
    if (findShapeById(doc5, id) == null) {
      println("frames-05: falta grupo/id \"" + id + "\".");
    }
  }

  String[] need = {
    "f02_bg", "f02_leafA", "f02_leafB",
    "f02_bugA", "f02_bugA_body", "f02_eyesA",
    "f02_bugB", "f02_bugB_body", "f02_eyesB"
  };
  for (String id : need) {
    if (findShapeById(frames[1], id) == null) {
      println("frames-02: no se encontró el grupo/id \"" + id + "\".");
    }
  }

  String[] need678 = {
    "f06_bg", "f06_back", "f06_center", "f06_right_bug",
    "f07_bg", "f07_back", "f07_ground",
    "f08_bg", "f08_back", "f08_bug_left_body", "f08_bug_left_eyes",
    "f08_bug_left_body_tail", "f08_bug_right", "f08_red_overlay", "f08_overlays"
  };
  for (String id : need678) {
    int fi = id.startsWith("f06") ? 5 : (id.startsWith("f07") ? 6 : 7);
    if (findShapeById(frames[fi], id) == null) {
      println("falta grupo/id \"" + id + "\".");
    }
  }

  PShape f08Right = findShapeById(frames[7], "f08_bug_right");
  if (f08Right == null) {
    println("frames-08: falta f08_bug_right.");
  } else {
    println("frames-08: f08_bug_right hojas=" + countSvgLeaves(f08Right));
  }
}

int frameStartMs(int frameIndex) {
  int s = 0;
  for (int i = 0; i < frameIndex; i++) {
    s += DUR_MS[i];
  }
  return s;
}

int[] buildRevealSlots(int num, int[] order) {
  int[] slot = new int[num];
  for (int k = 0; k < num; k++) {
    slot[order[k]] = k;
  }
  return slot;
}

void draw() {
  background(255);
  int t = millis();

  if (t < frameStartMs(1)) {
    drawFrame01(t);
  } else if (t < frameStartMs(2)) {
    drawFrame02(t - frameStartMs(1));
  } else if (t < frameStartMs(3)) {
    drawFrame03(t - frameStartMs(2));
  } else if (t < frameStartMs(4)) {
    drawFrame04(t - frameStartMs(3));
  } else if (t < frameStartMs(5)) {
    drawFrame05(t - frameStartMs(4));
  } else if (t < frameStartMs(6)) {
    drawFrame06(t - frameStartMs(5));
  } else if (t < frameStartMs(7)) {
    drawFrame07(t - frameStartMs(6));
  } else {
    drawFrame08(t - frameStartMs(7));
  }
}

void drawFrame02(int tRel) {
  float u = map(constrain(tRel, 0, DUR_MS[1] - 1), 0, DUR_MS[1], 0, TWO_PI);
  float sx = width / 1440f;
  float sy = height / 900f;
  PShape doc = frames[1];

  pushMatrix();
  scale(sx, sy);
  shape(findShapeById(doc, "f02_bg"), 0, 0);
  popMatrix();

  drawF02Leaf(doc, u, sx, sy, "f02_leafA", 468, 318, 0.06);
  drawF02Leaf(doc, u, sx, sy, "f02_leafB", 1062, 548, 0.74);

  drawF02Bug(doc, u, sx, sy, "f02_bugA", "f02_bugA_body", "f02_eyesA",
             492, 382, 0.22);
  drawF02Bug(doc, u, sx, sy, "f02_bugB", "f02_bugB_body", "f02_eyesB",
             1018, 598, 0.63);
}

void drawF02Leaf(PShape doc, float u, float sx, float sy, String gid,
                 float pivotX, float pivotY, float phase) {
  PShape g = findShapeById(doc, gid);
  if (g == null) return;
  pushMatrix();
  applyUndulationScreen(u, pivotX, pivotY, 9, 5.5, radians(2.0), phase, sx, sy);
  scale(sx, sy);
  shape(g, 0, 0);
  popMatrix();
}

void drawF02Bug(PShape doc, float u, float sx, float sy,
                String bugId, String bodyId, String eyesId,
                float pivotX, float pivotY, float phase) {
  PShape bug = findShapeById(doc, bugId);
  if (bug == null) return;
  PShape body = findShapeById(bug, bodyId);
  PShape eyes = findShapeById(bug, eyesId);

  pushMatrix();
  applyUndulationScreen(u, pivotX, pivotY, 6.5, 4.5, radians(1.35), phase, sx, sy);
  scale(sx, sy);
  if (body != null) {
    shape(body, 0, 0);
  }
  popMatrix();

  pushMatrix();
  applyUndulationScreen(u, pivotX, pivotY, 6.5, 4.5, radians(1.35), phase, sx, sy);
  float eyeDx = 2.6 * (sin(u + phase * 2.3) + 0.18 * sin(2.05 * u + phase));
  translate(eyeDx, 0);
  scale(sx, sy);
  if (eyes != null) {
    shape(eyes, 0, 0);
  }
  popMatrix();
}

PShape findShapeById(PShape node, String id) {
  if (node == null || id == null) return null;
  String nm = node.getName();
  if (nm != null && nm.equals(id)) return node;
  for (int i = 0; i < node.getChildCount(); i++) {
    PShape hit = findShapeById(node.getChild(i), id);
    if (hit != null) return hit;
  }
  return null;
}

void drawScaledBg(PShape doc, String bgId, float sx, float sy) {
  pushMatrix();
  scale(sx, sy);
  PShape bg = findShapeById(doc, bgId);
  if (bg != null) {
    shape(bg, 0, 0);
  }
  popMatrix();
}

void drawAnimGroup(PShape g, float u, float sx, float sy,
                   float pivotX, float pivotY,
                   float ampX, float ampY, float maxRot, float phase) {
  if (g == null) return;
  pushMatrix();
  applyUndulationScreen(u, pivotX, pivotY, ampX, ampY, maxRot, phase, sx, sy);
  scale(sx, sy);
  shape(g, 0, 0);
  popMatrix();
}

void drawStaticGroup(PShape g, float sx, float sy) {
  if (g == null) return;
  pushMatrix();
  scale(sx, sy);
  shape(g, 0, 0);
  popMatrix();
}

/** Processing a veces no pinta <g> con shape(); dibuja cada hoja del SVG. */
void drawShapeLeaves(PShape node) {
  if (node == null) return;
  int n = node.getChildCount();
  if (n == 0) {
    shape(node, 0, 0);
    return;
  }
  for (int i = 0; i < n; i++) {
    drawShapeLeaves(node.getChild(i));
  }
}

void drawStaticGroupLeaves(PShape g, float sx, float sy) {
  if (g == null) return;
  pushMatrix();
  scale(sx, sy);
  drawShapeLeaves(g);
  popMatrix();
}

void drawFrame06(int tRel) {
  tRel = constrain(tRel, 0, max(1, DUR_MS[5] - 1));
  float u = map(tRel, 0, DUR_MS[5], 0, TWO_PI);
  float sx = width / 1440f;
  float sy = height / 900f;
  PShape doc = frames[5];

  drawScaledBg(doc, "f06_bg", sx, sy);
  drawAnimGroup(findShapeById(doc, "f06_back"), u, sx, sy, 720, 420, 7, 4, radians(1.8), 0.0);
  drawAnimGroup(findShapeById(doc, "f06_left_blob"), u, sx, sy, 300, 520, 6, 5, radians(2.0), 0.45);
  drawAnimGroup(findShapeById(doc, "f06_center"), u, sx, sy, 720, 480, 9, 6, radians(2.2), 0.2);
  drawAnimGroup(findShapeById(doc, "f06_mid"), u, sx, sy, 600, 320, 5, 4, radians(1.5), 0.65);
  drawAnimGroup(findShapeById(doc, "f06_right_bug"), u, sx, sy, 1120, 420, 10, 7, radians(2.3), 0.35);
  drawAnimGroup(findShapeById(doc, "f06_towers"), u, sx, sy, 1280, 350, 6, 5, radians(1.6), 0.85);
  drawAnimGroup(findShapeById(doc, "f06_ground"), u, sx, sy, 900, 820, 4, 3, radians(1.0), 1.05);
}

void drawFrame07(int tRel) {
  tRel = constrain(tRel, 0, max(1, DUR_MS[6] - 1));
  float u = map(tRel, 0, DUR_MS[6], 0, TWO_PI);
  float sx = width / 1440f;
  float sy = height / 900f;
  float slice = DUR_MS[6] / (float) F07_LAYERS;
  PShape doc = frames[6];

  drawScaledBg(doc, "f07_bg", sx, sy);

  String[] ids = {
    "f07_back", "f07_left_blob", "f07_center", "f07_mid",
    "f07_right_bug", "f07_towers", "f07_ground"
  };
  float[][] piv = {
    {720, 420}, {300, 520}, {720, 480}, {600, 320},
    {1120, 420}, {1280, 350}, {900, 820}
  };
  float[] ph = {0.0, 0.45, 0.2, 0.65, 0.35, 0.85, 1.05};

  for (int i = 0; i < F07_LAYERS; i++) {
    float start = i * slice;
    if (tRel < start) continue;
    float fadeMs = min(500f, slice * 0.35f);
    float alpha = 255;
    if (tRel < start + fadeMs) {
      alpha = map(tRel, start, start + fadeMs, 0, 255);
    }
    PShape g = findShapeById(doc, ids[i]);
    if (g == null) continue;
    pushMatrix();
    applyUndulationScreen(u, piv[i][0], piv[i][1], 6, 4, radians(1.7), ph[i], sx, sy);
    scale(sx, sy);
    tint(255, alpha);
    shape(g, 0, 0);
    noTint();
    popMatrix();
  }
}

void drawFrame08(int tRel) {
  tRel = constrain(tRel, 0, max(1, DUR_MS[7] - 1));
  float u = map(tRel, 0, DUR_MS[7], 0, TWO_PI);
  float sx = width / 1440f;
  float sy = height / 900f;
  PShape doc = frames[7];

  drawScaledBg(doc, "f08_bg", sx, sy);

  PShape back = findShapeById(doc, "f08_back");
  if (back != null) {
    float backDur = DUR_MS[7] * 0.42f;
    float slice = backDur / max(1, back.getChildCount());
    drawRevealChildren(back, tRel, slice, sx, sy, 0);
  }

  if (tRel >= 500) {
    float px = 420, py = 400;
    drawAnimGroup(findShapeById(doc, "f08_bug_left_body"), u, sx, sy, px, py, 3, 2, radians(0.8), 0.1);
    PShape eyes = findShapeById(doc, "f08_bug_left_eyes");
    if (eyes != null) {
      pushMatrix();
      applyUndulationScreen(u, px + 70, py, 3, 2, radians(0.8), 0.1, sx, sy);
      float eyeDx = 2f * sin(u + 0.4);
      translate(eyeDx, 0);
      scale(sx, sy);
      shape(eyes, 0, 0);
      popMatrix();
    }
    drawAnimGroup(findShapeById(doc, "f08_bug_left_body_tail"), u, sx, sy, px, py, 3, 2, radians(0.8), 0.1);

    PShape right = findShapeById(doc, "f08_bug_right");
    if (right != null) {
      pushMatrix();
      applyUndulationScreen(u, 900, 520, 1.5f, 1.2f, radians(0.4), 0.55, sx, sy);
      scale(sx, sy);
      drawShapeLeaves(right);
      popMatrix();
    }
  }

  if (tRel >= 5000) {
    drawF05WiggleGroup(
      findShapeById(doc, "f08_antenna_branch"), u, sx, sy,
      new float[] {420, 320}, new float[] {380, 280},
      new float[] {0.0, 0.35},
      radians(1.4));
  }

  if (tRel >= 5500) {
    drawStaticGroupLeaves(findShapeById(doc, "f08_red_overlay"), sx, sy);
  }

  float ovStart = DUR_MS[7] * 0.65f;
  if (tRel >= ovStart) {
    drawStaticGroupLeaves(findShapeById(doc, "f08_overlays"), sx, sy);
  }
}

void drawFrame05(int tRel) {
  tRel = constrain(tRel, 0, max(1, DUR_MS[4] - 1));
  float u = map(tRel, 0, DUR_MS[4], 0, TWO_PI);
  float sx = width / 1440f;
  float sy = height / 900f;
  float slice = DUR_MS[4] / (float) F05_SLOTS;

  PShape doc = frames[4];
  pushMatrix();
  scale(sx, sy);
  shape(findShapeById(doc, "f05_bg"), 0, 0);
  popMatrix();

  drawRevealChildren(findShapeById(doc, "f05_leaves_early"), tRel, slice, sx, sy, 0);

  drawF05WiggleGroup(
    findShapeById(doc, "f05_adjunto1"), u, sx, sy,
    new float[] { 552, 694 }, new float[] { 154, 162 },
    new float[] { 0.0, 0.75 },
    radians(2.35));

  drawF05WiggleGroup(
    findShapeById(doc, "f05_adjunto2"), u, sx, sy,
    new float[] { 1185, 1040 }, new float[] { 596, 768 },
    new float[] { -0.2, 0.55 },
    radians(1.9));

  drawRevealChildren(findShapeById(doc, "f05_leaf_st49"), tRel, slice, sx, sy, 7);

  pushMatrix();
  scale(sx, sy);
  shape(findShapeById(doc, "f05_bug_core"), 0, 0);
  popMatrix();

  drawRevealChildren(findShapeById(doc, "f05_leaves_front"), tRel, slice, sx, sy, 8);
}

void drawRevealChildren(PShape parent, int tRel, float slice, float sx, float sy, int slotStart) {
  if (parent == null) return;
  for (int i = 0; i < parent.getChildCount(); i++) {
    int slot = slotStart + i;
    float start = slot * slice;
    if (tRel < start) continue;
    float fadeMs = min(440f, slice * 0.38f);
    float alpha = 255;
    if (tRel < start + fadeMs) {
      alpha = map(tRel, start, start + fadeMs, 0, 255);
    }
    pushMatrix();
    scale(sx, sy);
    tint(255, alpha);
    shape(parent.getChild(i), 0, 0);
    noTint();
    popMatrix();
  }
}

/** Rotación suave como articulación; cada hijo con su pivote en coords del viewBox. */
void drawF05WiggleGroup(PShape grp, float u, float sx, float sy,
                        float[] pivX, float[] pivY, float[] phases, float maxRotRad) {
  if (grp == null) return;
  int nc = grp.getChildCount();
  for (int k = 0; k < nc; k++) {
    float px = pivX[k < pivX.length ? k : pivX.length - 1];
    float py = pivY[k < pivY.length ? k : pivY.length - 1];
    float ph = phases[k < phases.length ? k : phases.length - 1];
    float wav = sin((float)(u + ph)) + 0.2 * sin((float)(2.07 * u + ph * 1.2));
    float rot = maxRotRad * wav;
    if (k % 2 == 1) {
      rot *= -0.92f;
    }
    pushMatrix();
    translate(px * sx, py * sy);
    rotate(rot);
    translate(-px * sx, -py * sy);
    scale(sx, sy);
    shape(grp.getChild(k), 0, 0);
    popMatrix();
  }
}

void drawFrame03(int tRel) {
  tRel = constrain(tRel, 0, DUR_MS[2] - 1);
  float sx = width / 1440f;
  float sy = height / 900f;
  float slice = DUR_MS[2] / (float) F03_NUM;
  int[] counter = new int[] { 0 };
  drawRevealWalk(frames[2], tRel, slice, sx, sy, counter, f03RevealSlot);
}

void drawFrame04(int tRel) {
  tRel = constrain(tRel, 0, DUR_MS[3] - 1);
  float sx = width / 1440f;
  float sy = height / 900f;
  float slice = DUR_MS[3] / (float) F04_NUM;
  int[] counter = new int[] { 0 };
  drawRevealWalk(frames[3], tRel, slice, sx, sy, counter, f04RevealSlot);
}

void drawRevealWalk(PShape node, int tRel, float slice, float sx, float sy, int[] counter, int[] revealSlot) {
  if (node.getChildCount() == 0) {
    int i = counter[0]++;
    float start = revealSlot[i] * slice;
    if (tRel < start) {
      return;
    }
    float fadeMs = min(420f, slice * 0.4f);
    float alpha = 255;
    if (revealSlot[i] > 0 && tRel < start + fadeMs) {
      alpha = map(tRel, start, start + fadeMs, 0, 255);
    }
    pushMatrix();
    scale(sx, sy);
    tint(255, alpha);
    shape(node, 0, 0);
    noTint();
    popMatrix();
    return;
  }
  for (int k = 0; k < node.getChildCount(); k++) {
    drawRevealWalk(node.getChild(k), tRel, slice, sx, sy, counter, revealSlot);
  }
}

void drawFrame01(int tMs) {
  float u = map(tMs, 0, DUR_MS[0], 0, TWO_PI);
  int[] counter = new int[] { 0 };
  float sx = width / 1440f;
  float sy = height / 900f;
  drawFrame01Walk(frames[0], u, counter, sx, sy);
}

void drawFrame01Walk(PShape node, float u, int[] counter, float sx, float sy) {
  if (node.getChildCount() == 0) {
    int i = counter[0]++;
    pushMatrix();
    if (contains(F01_HOJA, i)) {
      applyUndulationScreen(u, 488, 352, 8, 5, radians(2.2), 0.0, sx, sy);
    } else if (i >= F01_OJOS_LO && i <= F01_OJOS_HI && i != F01_NARIZ) {
      applyUndulationScreen(u, 592, 398, 3.2, 2.0, radians(0.9), 0.55, sx, sy);
    } else if (contains(F01_ANTENAS, i)) {
      applyAntennaTipWiggle(u, i, sx, sy);
    }
    scale(sx, sy);
    shape(node, 0, 0);
    popMatrix();
    return;
  }
  for (int k = 0; k < node.getChildCount(); k++) {
    drawFrame01Walk(node.getChild(k), u, counter, sx, sy);
  }
}

int countSvgLeaves(PShape node) {
  if (node.getChildCount() == 0) {
    return 1;
  }
  int sum = 0;
  for (int k = 0; k < node.getChildCount(); k++) {
    sum += countSvgLeaves(node.getChild(k));
  }
  return sum;
}

void applyUndulationScreen(float u, float pivotX, float pivotY,
                           float ampX, float ampY, float maxRot, float phase,
                           float sx, float sy) {
  float wobble = sin(u + phase) + 0.22 * sin(2.02 * u + phase * 1.3);
  float swayY = sin(0.86 * u + phase * 1.1);
  float tx = ampX * wobble;
  float ty = ampY * swayY;
  float rot = maxRot * sin(0.93 * u + phase + 0.35);
  float px = pivotX * sx;
  float py = pivotY * sy;
  translate(tx, ty);
  translate(px, py);
  rotate(rot);
  translate(-px, -py);
}

boolean contains(int[] arr, int v) {
  for (int x : arr) {
    if (x == v) return true;
  }
  return false;
}

void applyAntennaTipWiggle(float u, int leafIndex, float sx, float sy) {
  float px, py, maxRot, ph;
  if (leafIndex == 33) {
    px = 566;
    py = 304;
    maxRot = radians(1.7);
    ph = -0.25;
  } else if (leafIndex == 35) {
    px = 528;
    py = 242;
    maxRot = radians(2.1);
    ph = 0.0;
  } else if (leafIndex == 36) {
    px = 532;
    py = 220;
    maxRot = radians(1.9);
    ph = 0.18;
  } else if (leafIndex == 41) {
    px = 404;
    py = 210;
    maxRot = radians(1.5);
    ph = -0.12;
  } else {
    return;
  }
  float w = 0.88 * sin(0.91 * u + ph) + 0.12 * sin(2.08 * u + ph * 1.2);
  float rot = maxRot * w;
  if (leafIndex == 36) {
    rot *= -1;
  }
  float psx = px * sx;
  float psy = py * sy;
  translate(psx, psy);
  rotate(rot);
  translate(-psx, -psy);
}
