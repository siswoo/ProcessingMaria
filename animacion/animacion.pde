PShape[] frames;
int[] DUR_MS = {
  700, 900, 800, 1500, 1100, 700, 1300, 2500, 1300, 1300, 1300,
  500, 1600, 1600, 1600, 1300, 1500, 700
};
String[] SVG_FILES = {
  "frames-01.svg",
  "frames-02.svg",
  "frames-03.svg",
  "frames-04.svg",
  "frames-05.svg",
  "frames-6.svg",
  "frames-7.svg",
  "frames-8.svg",
  "frames-9.svg",
  "frames-10.svg",
  "frames-11.svg",
  "frames-12.svg",
  "frames-13.svg",
  "frames-14.svg",
  "frames-15.svg",
  "frames-16.svg",
  "frames-17.svg",
  "frames-18.svg"
};

int f14CreatureCount = 0;
int f15CreatureCount = 0;
int f16CreatureCount = 0;

// --- frames-18 interactivo ---
final int F18_FRAME_INDEX = 17;
final int F18_SPORE_LIFE_MS = 3000;
int f18TimeOffset = 0;
boolean f18HabitatSaved = false;
boolean f18Dragging = false;
ArrayList<PVector> f18CorridorPts;
ArrayList<F18Spore> f18Spores;

class F18Spore {
  float x, y;
  int bornMs;
  float r;
  F18Spore(float x, float y, int bornMs) {
    this.x = x;
    this.y = y;
    this.bornMs = bornMs;
    this.r = random(5, 11);
  }
}

// --- frames-11 ---
final int F11_RED = 575;
final int F11_PURPLE = 12;

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

  String[] need911 = { "f09_bg", "f09_pieces", "f10_bg", "f10_pieces", "f11_bg" };
  for (String id : need911) {
    int fi = id.startsWith("f09") ? 8 : (id.startsWith("f10") ? 9 : 10);
    if (findShapeById(frames[fi], id) == null) {
      println("falta grupo/id \"" + id + "\".");
    }
  }
  PShape f09p = findShapeById(frames[8], "f09_pieces");
  PShape f10p = findShapeById(frames[9], "f10_pieces");
  if (f09p != null) {
    println("frames-09: piezas=" + f09p.getChildCount());
  }
  if (f10p != null) {
    println("frames-10: piezas=" + f10p.getChildCount());
  }

  String[] need1213 = {
    "f12_bg", "f12_bug_right_body", "f12_bug_right_legs",
    "f12_bug_left_body", "f12_bug_left_legs",
    "f13_bg", "f13_leaves", "f13_bug_left_body", "f13_bug_left_legs",
    "f13_bug_right_body", "f13_bug_right_legs", "f13_dots"
  };
  for (String id : need1213) {
    int fi = id.startsWith("f12") ? 11 : 12;
    if (findShapeById(frames[fi], id) == null) {
      println("falta grupo/id \"" + id + "\".");
    }
  }
  PShape f13d = findShapeById(frames[12], "f13_dots");
  if (f13d != null) {
    println("frames-13: puntos=" + f13d.getChildCount());
  }

  String[] need14 = {
    "f14_bg", "f14_leaves", "f14_bug_left_body", "f14_bug_left_legs",
    "f14_bug_right_body", "f14_bug_right_legs"
  };
  for (String id : need14) {
    if (findShapeById(frames[13], id) == null) {
      println("falta grupo/id \"" + id + "\".");
    }
  }
  f14CreatureCount = 0;
  while (findShapeById(frames[13], "f14_creature_" + f14CreatureCount) != null) {
    f14CreatureCount++;
  }
  println("frames-14: criaturas=" + f14CreatureCount);

  String[] need15 = {
    "f15_bg", "f15_leaves", "f15_bug_left_body", "f15_bug_left_legs",
    "f15_bug_right_body", "f15_bug_right_legs"
  };
  for (String id : need15) {
    if (findShapeById(frames[14], id) == null) {
      println("falta grupo/id \"" + id + "\".");
    }
  }
  f15CreatureCount = 0;
  while (findShapeById(frames[14], "f15_creature_" + f15CreatureCount) != null) {
    f15CreatureCount++;
  }
  println("frames-15: criaturas=" + f15CreatureCount);

  String[] need16 = {
    "f16_bg", "f16_leaves", "f16_bug_body", "f16_bug_legs"
  };
  for (String id : need16) {
    if (findShapeById(frames[15], id) == null) {
      println("falta grupo/id \"" + id + "\".");
    }
  }
  f16CreatureCount = 0;
  while (findShapeById(frames[15], "f16_creature_" + f16CreatureCount) != null) {
    f16CreatureCount++;
  }
  println("frames-16: criaturas=" + f16CreatureCount);

  String[] need17 = {
    "f17_bg", "f17_leaf_a", "f17_leaf_b", "f17_bug_body", "f17_bug_legs"
  };
  for (String id : need17) {
    if (findShapeById(frames[16], id) == null) {
      println("falta grupo/id \"" + id + "\".");
    }
  }

  String[] need18 = {
    "f18_bg", "f18_leaf_a", "f18_leaf_b", "f18_bug_body", "f18_bug_legs"
  };
  for (String id : need18) {
    if (findShapeById(frames[17], id) == null) {
      println("falta grupo/id \"" + id + "\".");
    }
  }

  f18CorridorPts = new ArrayList<PVector>();
  f18Spores = new ArrayList<F18Spore>();
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
  } else if (t < frameStartMs(8)) {
    drawFrame08(t - frameStartMs(7));
  } else if (t < frameStartMs(9)) {
    drawFrame09(t - frameStartMs(8));
  } else if (t < frameStartMs(10)) {
    drawFrame10(t - frameStartMs(9));
  } else if (t < frameStartMs(11)) {
    drawFrame11(t - frameStartMs(10));
  } else if (t < frameStartMs(12)) {
    drawFrame12(t - frameStartMs(11));
  } else if (t < frameStartMs(13)) {
    drawFrame13(t - frameStartMs(12));
  } else if (t < frameStartMs(14)) {
    drawFrame14(t - frameStartMs(13));
  } else if (t < frameStartMs(15)) {
    drawFrame15(t - frameStartMs(14));
  } else if (t < frameStartMs(16)) {
    drawFrame16(t - frameStartMs(15));
  } else if (t < frameStartMs(17)) {
    drawFrame17(t - frameStartMs(16));
  } else {
    drawFrame18(getFrame18TRel());
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

void drawF17Leaf(PShape doc, float u, float sx, float sy, String gid,
                   float pivotX, float pivotY, float phase) {
  drawF17Leaf(doc, u, sx, sy, gid, pivotX, pivotY, phase, 1f);
}

void drawF17Leaf(PShape doc, float u, float sx, float sy, String gid,
                   float pivotX, float pivotY, float phase, float motion) {
  PShape g = findShapeById(doc, gid);
  if (g == null) return;
  pushMatrix();
  applyUndulationScreen(u, pivotX, pivotY, 5.5f * motion, 3.5f * motion,
                        radians(0.9f) * motion, phase, sx, sy);
  scale(sx, sy);
  drawShapeLeaves(g);
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

void drawRevealAlphaGroup(PShape g, int tRel, float startMs, float fadeMs,
                          float sx, float sy) {
  if (g == null || tRel < startMs) return;
  float alpha = 255;
  if (fadeMs > 0 && tRel < startMs + fadeMs) {
    alpha = map(tRel, startMs, startMs + fadeMs, 0, 255);
  }
  pushMatrix();
  scale(sx, sy);
  if (alpha < 255) tint(255, alpha);
  drawShapeLeaves(g);
  if (alpha < 255) noTint();
  popMatrix();
}

float[] shapePivot(PShape part) {
  if (part == null) return new float[] { 0, 0 };
  int nv = part.getVertexCount();
  if (nv > 0) {
    float sx = 0, sy = 0;
    for (int i = 0; i < nv; i++) {
      sx += part.getVertexX(i);
      sy += part.getVertexY(i);
    }
    return new float[] { sx / nv, sy / nv };
  }
  float pw = part.getWidth();
  float ph = part.getHeight();
  if (pw > 0 && ph > 0) {
    return new float[] { pw * 0.5f, ph * 0.5f };
  }
  return new float[] { 0, 0 };
}

void drawLegsWiggleAuto(PShape legs, float u, float sx, float sy,
                        float maxRot, float phase) {
  if (legs == null) return;
  int nc = legs.getChildCount();
  for (int k = 0; k < nc; k++) {
    PShape part = legs.getChild(k);
    float[] piv = shapePivot(part);
    float px = piv[0];
    float py = piv[1];
    float phk = phase + k * 0.41f;
    float wav = sin(u + phk) + 0.18f * sin(2.05f * u + phk * 1.15f);
    float rot = maxRot * wav;
    if (k % 2 == 1) rot *= -0.9f;
    pushMatrix();
    translate(px * sx, py * sy);
    rotate(rot);
    translate(-px * sx, -py * sy);
    scale(sx, sy);
    shape(part, 0, 0);
    popMatrix();
  }
}

void drawBugWithLegs(PShape doc, String side, int tRel, float u,
                     float sx, float sy, float bodyStart, float legsStart,
                     float fadeMs, float legPhase) {
  drawRevealAlphaGroup(findShapeById(doc, side + "_body"), tRel, bodyStart, fadeMs, sx, sy);
  PShape legs = findShapeById(doc, side + "_legs");
  drawRevealAlphaGroup(legs, tRel, legsStart, fadeMs, sx, sy);
  if (legs != null && tRel >= legsStart + fadeMs * 0.35f) {
    drawLegsWiggleAuto(legs, u, sx, sy, radians(2.0), legPhase);
  }
}

/** Insecto completo (cuerpo + patas) encima de las hojas, con fade y wiggle de patas. */
void drawBugRevealFull(PShape doc, String side, int tRel, float u,
                       float sx, float sy, float startMs, float fadeMs,
                       float legPhase, boolean wiggleLegs) {
  PShape body = findShapeById(doc, side + "_body");
  PShape legs = findShapeById(doc, side + "_legs");
  drawRevealAlphaGroup(body, tRel, startMs, fadeMs, sx, sy);
  drawRevealAlphaGroup(legs, tRel, startMs, fadeMs, sx, sy);
  if (wiggleLegs && legs != null && tRel >= startMs + fadeMs * 0.4f) {
    drawLegsWiggleAuto(legs, u, sx, sy, radians(1.6), legPhase);
  }
}

void drawFrame12(int tRel) {
  tRel = constrain(tRel, 0, max(1, DUR_MS[11] - 1));
  float u = map(tRel, 0, DUR_MS[11], 0, TWO_PI);
  float sx = width / 1440f;
  float sy = height / 900f;
  PShape doc = frames[11];

  drawScaledBg(doc, "f12_bg", sx, sy);
  drawStaticGroupLeaves(findShapeById(doc, "f12_bg_shapes"), sx, sy);

  float fade = 520f;
  drawBugWithLegs(doc, "f12_bug_right", tRel, u, sx, sy, 0, 180, fade, 0.0f);
  drawBugWithLegs(doc, "f12_bug_left", tRel, u, sx, sy, 280, 460, fade, 0.55f);
}

void drawFrame13(int tRel) {
  tRel = constrain(tRel, 0, max(1, DUR_MS[12] - 1));
  float u = map(tRel, 0, DUR_MS[12], 0, TWO_PI);
  float sx = width / 1440f;
  float sy = height / 900f;
  PShape doc = frames[12];
  int dur = DUR_MS[12];

  drawScaledBg(doc, "f13_bg", sx, sy);
  drawStaticGroupLeaves(findShapeById(doc, "f13_bg_layers"), sx, sy);
  drawStaticGroupLeaves(findShapeById(doc, "f13_leaves"), sx, sy);

  noTint();
  drawStaticGroupLeaves(findShapeById(doc, "f13_bug_left_body"), sx, sy);
  drawLegsWiggleAuto(findShapeById(doc, "f13_bug_left_legs"), u, sx, sy, radians(1.5), 0.2f);

  PShape rightBody = findShapeById(doc, "f13_bug_right_body");
  if (rightBody != null) {
    pushMatrix();
    applyUndulationScreen(u, 1020, 420, 4, 3, radians(0.9), 0.65f, sx, sy);
    scale(sx, sy);
    drawShapeLeaves(rightBody);
    popMatrix();
  }
  drawLegsWiggleAuto(findShapeById(doc, "f13_bug_right_legs"), u, sx, sy, radians(1.5), 0.65f);

  PShape dots = findShapeById(doc, "f13_dots");
  if (dots != null && dots.getChildCount() > 0) {
    float slice = dur / (float) dots.getChildCount();
    drawRevealChildren(dots, tRel, slice, sx, sy, 0);
  }
}

void drawFrame14(int tRel) {
  tRel = constrain(tRel, 0, max(1, DUR_MS[13] - 1));
  float u = map(tRel, 0, DUR_MS[13], 0, TWO_PI);
  float sx = width / 1440f;
  float sy = height / 900f;
  PShape doc = frames[13];
  int dur = DUR_MS[13];

  drawScaledBg(doc, "f14_bg", sx, sy);
  drawStaticGroupLeaves(findShapeById(doc, "f14_bg_layers"), sx, sy);
  drawStaticGroupLeaves(findShapeById(doc, "f14_leaves"), sx, sy);

  noTint();
  drawStaticGroupLeaves(findShapeById(doc, "f14_bug_left_body"), sx, sy);
  drawLegsWiggleAuto(findShapeById(doc, "f14_bug_left_legs"), u, sx, sy, radians(1.5), 0.2f);

  PShape rightBody = findShapeById(doc, "f14_bug_right_body");
  if (rightBody != null) {
    pushMatrix();
    applyUndulationScreen(u, 1020, 420, 4, 3, radians(0.9), 0.65f, sx, sy);
    scale(sx, sy);
    drawShapeLeaves(rightBody);
    popMatrix();
  }
  drawLegsWiggleAuto(findShapeById(doc, "f14_bug_right_legs"), u, sx, sy, radians(1.5), 0.65f);

  if (f14CreatureCount > 0) {
    float slice = dur / (float) f14CreatureCount;
    float fadeMs = min(520f, slice * 0.4f);
    for (int i = 0; i < f14CreatureCount; i++) {
      PShape cre = findShapeById(doc, "f14_creature_" + i);
      if (cre == null) continue;
      float start = i * slice;
      if (tRel < start) continue;
      float alpha = 255;
      if (tRel < start + fadeMs) {
        alpha = map(tRel, start, start + fadeMs, 0, 255);
      }
      pushMatrix();
      scale(sx, sy);
      if (alpha < 255) tint(255, alpha);
      drawShapeLeaves(cre);
      if (alpha < 255) noTint();
      popMatrix();
    }
  }
}

void drawFrame15(int tRel) {
  tRel = constrain(tRel, 0, max(1, DUR_MS[14] - 1));
  float u = map(tRel, 0, DUR_MS[14], 0, TWO_PI);
  float sx = width / 1440f;
  float sy = height / 900f;
  PShape doc = frames[14];
  int dur = DUR_MS[14];

  drawScaledBg(doc, "f15_bg", sx, sy);
  drawStaticGroupLeaves(findShapeById(doc, "f15_bg_layers"), sx, sy);
  drawStaticGroupLeaves(findShapeById(doc, "f15_leaves"), sx, sy);

  noTint();
  drawStaticGroupLeaves(findShapeById(doc, "f15_bug_left_body"), sx, sy);
  drawLegsWiggleAuto(findShapeById(doc, "f15_bug_left_legs"), u, sx, sy, radians(1.5), 0.2f);

  PShape rightBody = findShapeById(doc, "f15_bug_right_body");
  if (rightBody != null) {
    pushMatrix();
    applyUndulationScreen(u, 1020, 420, 4, 3, radians(0.9), 0.65f, sx, sy);
    scale(sx, sy);
    drawShapeLeaves(rightBody);
    popMatrix();
  }
  drawLegsWiggleAuto(findShapeById(doc, "f15_bug_right_legs"), u, sx, sy, radians(1.5), 0.65f);

  if (f15CreatureCount > 0) {
    float slice = dur / (float) f15CreatureCount;
    float fadeMs = min(520f, slice * 0.4f);
    for (int i = 0; i < f15CreatureCount; i++) {
      PShape cre = findShapeById(doc, "f15_creature_" + i);
      if (cre == null) continue;
      float start = i * slice;
      if (tRel < start) continue;
      float alpha = 255;
      if (tRel < start + fadeMs) {
        alpha = map(tRel, start, start + fadeMs, 0, 255);
      }
      pushMatrix();
      scale(sx, sy);
      if (alpha < 255) tint(255, alpha);
      drawShapeLeaves(cre);
      if (alpha < 255) noTint();
      popMatrix();
    }
  }
}

void drawFrame16(int tRel) {
  tRel = constrain(tRel, 0, max(1, DUR_MS[15] - 1));
  float u = map(tRel, 0, DUR_MS[15], 0, TWO_PI);
  float sx = width / 1440f;
  float sy = height / 900f;
  PShape doc = frames[15];

  drawScaledBg(doc, "f16_bg", sx, sy);
  drawStaticGroupLeaves(findShapeById(doc, "f16_bg_layers"), sx, sy);
  drawStaticGroupLeaves(findShapeById(doc, "f16_leaves"), sx, sy);

  float[] crePivX = { 540, 660 };
  float[] crePivY = { 730, 800 };
  for (int i = 0; i < f16CreatureCount; i++) {
    PShape cre = findShapeById(doc, "f16_creature_" + i);
    if (cre == null) continue;
    float px = i < crePivX.length ? crePivX[i] : 600;
    float py = i < crePivY.length ? crePivY[i] : 750;
    drawAnimGroup(cre, u, sx, sy, px, py, 3.5f, 3f, radians(0.4f), 0.25f + i * 0.55f);
  }

  PShape bugBody = findShapeById(doc, "f16_bug_body");
  if (bugBody != null) {
    pushMatrix();
    applyUndulationScreen(u, 430, 380, 5, 4, radians(1.0), 0.15f, sx, sy);
    scale(sx, sy);
    drawShapeLeaves(bugBody);
    popMatrix();
  }
  drawLegsWiggleAuto(findShapeById(doc, "f16_bug_legs"), u, sx, sy, radians(1.6), 0.2f);
}

void drawFrame17(int tRel) {
  tRel = constrain(tRel, 0, max(1, DUR_MS[16] - 1));
  float u = map(tRel, 0, DUR_MS[16], 0, TWO_PI);
  float sx = width / 1440f;
  float sy = height / 900f;
  PShape doc = frames[16];

  drawScaledBg(doc, "f17_bg", sx, sy);

  drawF17Leaf(doc, u, sx, sy, "f17_leaf_a", 400, 340, 0.08f);
  drawF17Leaf(doc, u, sx, sy, "f17_leaf_b", 1120, 520, 0.62f);

  PShape bugBody = findShapeById(doc, "f17_bug_body");
  if (bugBody != null) {
    pushMatrix();
    applyUndulationScreen(u, 430, 380, 4, 3, radians(0.75), 0.12f, sx, sy);
    scale(sx, sy);
    drawShapeLeaves(bugBody);
    popMatrix();
  }
  drawLegsWiggleAuto(findShapeById(doc, "f17_bug_legs"), u, sx, sy, radians(1.2), 0.18f);
}

boolean isFrame18Active() {
  return millis() >= frameStartMs(F18_FRAME_INDEX);
}

int getFrame18TRel() {
  return millis() - frameStartMs(F18_FRAME_INDEX) - f18TimeOffset;
}

void resetFrame18() {
  f18TimeOffset = millis() - frameStartMs(F18_FRAME_INDEX);
  f18HabitatSaved = false;
  f18Dragging = false;
  f18CorridorPts.clear();
  f18Spores.clear();
}

boolean f18HitResetButton(float mx, float my) {
  return mx >= width - 128 && mx <= width - 12 && my >= 12 && my <= 46;
}

boolean f18HitBrownHabitat(float sx, float sy, float mx, float my) {
  float cx = 420 * sx;
  float cy = 380 * sy;
  float r = 250 * (sx + sy) * 0.5f;
  return dist(mx, my, cx, cy) < r;
}

boolean f18HitGreenHabitat(float sx, float sy, float mx, float my) {
  float cx = 1080 * sx;
  float cy = 480 * sy;
  float r = 280 * (sx + sy) * 0.5f;
  return dist(mx, my, cx, cy) < r;
}

void updateF18HabitatConnection(float sx, float sy) {
  if (f18HabitatSaved || f18CorridorPts.size() < 2) return;
  boolean brown = false;
  boolean green = false;
  for (PVector p : f18CorridorPts) {
    if (f18HitBrownHabitat(sx, sy, p.x, p.y)) brown = true;
    if (f18HitGreenHabitat(sx, sy, p.x, p.y)) green = true;
  }
  if (brown && green) f18HabitatSaved = true;
}

void spawnF18Spores() {
  int n = (int) random(6, 12);
  int now = millis();
  for (int i = 0; i < n; i++) {
    f18Spores.add(new F18Spore(random(width), random(height), now));
  }
}

void drawF18Corridor() {
  if (f18CorridorPts.size() < 2) return;
  stroke(109, 175, 92);
  strokeWeight(16);
  strokeCap(ROUND);
  strokeJoin(ROUND);
  noFill();
  beginShape();
  PVector p0 = f18CorridorPts.get(0);
  curveVertex(p0.x, p0.y);
  for (int i = 0; i < f18CorridorPts.size(); i++) {
    PVector p = f18CorridorPts.get(i);
    curveVertex(p.x, p.y);
  }
  PVector pl = f18CorridorPts.get(f18CorridorPts.size() - 1);
  curveVertex(pl.x, pl.y);
  endShape();
}

void drawF18Spores() {
  int now = millis();
  for (int i = f18Spores.size() - 1; i >= 0; i--) {
    F18Spore s = f18Spores.get(i);
    int age = now - s.bornMs;
    if (age >= F18_SPORE_LIFE_MS) {
      f18Spores.remove(i);
      continue;
    }
    float alpha = map(age, 0, F18_SPORE_LIFE_MS, 220, 0);
    float bob = sin((age / 1000f) * TWO_PI + s.x * 0.01f) * 6;
    noStroke();
    fill(128, 41, 64, alpha);
    ellipse(s.x, s.y + bob, s.r * 2, s.r * 2);
    fill(244, 233, 212, alpha * 0.35f);
    ellipse(s.x - s.r * 0.25f, s.y + bob - s.r * 0.2f, s.r, s.r);
  }
}

void drawF18ResetButton() {
  float bx = width - 128;
  float by = 12;
  float bw = 116;
  float bh = 34;
  noStroke();
  fill(60, 45, 35, 210);
  rect(bx, by, bw, bh, 6);
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(14);
  text("Reiniciar", bx + bw * 0.5f, by + bh * 0.5f);
}

void drawFrame18(int tRel) {
  float sx = width / 1440f;
  float sy = height / 900f;
  float motion = f18HabitatSaved ? 0.04f : 1f;
  float u = (tRel / 1000f) * (TWO_PI / 7f);
  PShape doc = frames[17];

  drawScaledBg(doc, "f18_bg", sx, sy);

  drawF17Leaf(doc, u, sx, sy, "f18_leaf_a", 400, 340, 0.08f, motion);
  drawF17Leaf(doc, u, sx, sy, "f18_leaf_b", 1120, 520, 0.62f, motion);

  PShape bugBody = findShapeById(doc, "f18_bug_body");
  if (bugBody != null) {
    pushMatrix();
    applyUndulationScreen(u, 430, 380, 4 * motion, 3 * motion,
                          radians(0.75f) * motion, 0.12f, sx, sy);
    scale(sx, sy);
    drawShapeLeaves(bugBody);
    popMatrix();
  }
  drawLegsWiggleAuto(findShapeById(doc, "f18_bug_legs"), u, sx, sy,
                     radians(1.2f) * motion, 0.18f);

  drawF18Corridor();
  drawF18Spores();
  drawF18ResetButton();

  if (f18HabitatSaved) {
    fill(180, 220, 160, 200);
    textAlign(CENTER, TOP);
    textSize(15);
    text("Habitat conectado — movimiento estabilizado", width * 0.5f, 8);
  }
}

void keyPressed() {
  if (key == ' ' && isFrame18Active()) {
    spawnF18Spores();
  }
}

void mousePressed() {
  if (!isFrame18Active()) return;
  if (f18HitResetButton(mouseX, mouseY)) {
    resetFrame18();
    return;
  }
  f18Dragging = true;
  f18CorridorPts.clear();
  f18CorridorPts.add(new PVector(mouseX, mouseY));
}

void mouseDragged() {
  if (!isFrame18Active() || !f18Dragging) return;
  PVector last = f18CorridorPts.get(f18CorridorPts.size() - 1);
  if (dist(last.x, last.y, mouseX, mouseY) > 4) {
    f18CorridorPts.add(new PVector(mouseX, mouseY));
    float sx = width / 1440f;
    float sy = height / 900f;
    updateF18HabitatConnection(sx, sy);
  }
}

void mouseReleased() {
  if (!isFrame18Active()) return;
  f18Dragging = false;
  float sx = width / 1440f;
  float sy = height / 900f;
  updateF18HabitatConnection(sx, sy);
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

void drawFrame09(int tRel) {
  drawRedRevealFrame(frames[8], "f09_bg", "f09_pieces", tRel, DUR_MS[8]);
}

void drawFrame10(int tRel) {
  drawRedRevealFrame(frames[9], "f10_bg", "f10_pieces", tRel, DUR_MS[9]);
}

void drawRedRevealFrame(PShape doc, String bgId, String piecesId, int tRel, int durMs) {
  tRel = constrain(tRel, 0, max(1, durMs - 1));
  float sx = width / 1440f;
  float sy = height / 900f;
  drawScaledBg(doc, bgId, sx, sy);
  PShape pieces = findShapeById(doc, piecesId);
  if (pieces == null || pieces.getChildCount() == 0) return;
  float slice = durMs / (float) pieces.getChildCount();
  drawRevealChildren(pieces, tRel, slice, sx, sy, 0);
}

void drawFrame11(int tRel) {
  tRel = constrain(tRel, 0, max(1, DUR_MS[10] - 1));
  float sx = width / 1440f;
  float sy = height / 900f;
  PShape doc = frames[10];
  float slice = DUR_MS[10] / (float) (F11_RED + F11_PURPLE);

  drawScaledBg(doc, "f11_bg", sx, sy);

  int redSlot = 0;
  redSlot = drawRevealChildren(findShapeById(doc, "f11_row0_red"), tRel, slice, sx, sy, redSlot);

  int pur0 = F11_RED;
  drawRevealChildren(findShapeById(doc, "f11_row1_purple_behind"), tRel, slice, sx, sy, F11_RED + 4);

  redSlot = drawRevealChildren(findShapeById(doc, "f11_row1_red_front"), tRel, slice, sx, sy, redSlot);
  redSlot = drawRevealChildren(findShapeById(doc, "f11_row2_red"), tRel, slice, sx, sy, redSlot);

  drawRevealChildren(findShapeById(doc, "f11_row0_purple_front"), tRel, slice, sx, sy, pur0);
  drawRevealChildren(findShapeById(doc, "f11_row2_purple_front"), tRel, slice, sx, sy, F11_RED + 8);
}

int drawRevealChildren(PShape parent, int tRel, float slice, float sx, float sy, int slotStart) {
  if (parent == null) return slotStart;
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
    if (alpha < 255) tint(255, alpha);
    drawShapeLeaves(parent.getChild(i));
    if (alpha < 255) noTint();
    popMatrix();
  }
  return slotStart + parent.getChildCount();
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
