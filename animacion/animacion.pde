PShape[] frames;
int[] DUR_MS = { 7000, 9000, 8000 };
String[] SVG_FILES = { "frames-01.svg", "frames-03.svg", "frames-07.svg" };

// Índices en recorrido en profundidad del frames-01.svg actual (hoja + pliegues, ojos, antenas).
final int[] F01_HOJA = { 0, 45, 46 };
// Ojos: 3–13 salvo 8 (triángulo #F4957E = nariz, fija con el cuerpo).
final int F01_OJOS_LO = 3, F01_OJOS_HI = 13;
final int F01_NARIZ = 8;
final int[] F01_ANTENAS = { 33, 35, 36, 41 };

// frames-03.svg: orden de aparición (arriba → abajo); índices = hojas en DFS = orden del archivo.
final int F03_NUM = 7;
final int[] F03_REVEAL_ORDER = { 0, 5, 2, 3, 4, 1, 6 };
int[] f03RevealSlot;

// frames-07.svg: aparición arriba → abajo; duración DUR_MS[2] (8 s).
final int F07_NUM = 13;
final int[] F07_REVEAL_ORDER = { 0, 9, 6, 2, 12, 3, 4, 7, 8, 5, 1, 10, 11 };
int[] f07RevealSlot;

void setup() {
  size(1440, 900);
  frames = new PShape[SVG_FILES.length];
  for (int i = 0; i < SVG_FILES.length; i++) {
    frames[i] = loadShape(SVG_FILES[i]);
  }
  int n = countSvgLeaves(frames[0]);
  if (n != 63) {
    println("frames-01: hojas del árbol SVG = " + n + " (esperado 63). Ajusta F01_HOJA / F01_OJOS / F01_ANTENAS si hace falta.");
  }
  f03RevealSlot = new int[F03_NUM];
  for (int k = 0; k < F03_NUM; k++) {
    f03RevealSlot[F03_REVEAL_ORDER[k]] = k;
  }
  int n3 = countSvgLeaves(frames[1]);
  if (n3 != F03_NUM) {
    println("frames-03: hojas = " + n3 + " (esperado " + F03_NUM + "). Revisa F03_REVEAL_ORDER.");
  }
  f07RevealSlot = new int[F07_NUM];
  for (int k = 0; k < F07_NUM; k++) {
    f07RevealSlot[F07_REVEAL_ORDER[k]] = k;
  }
  int n7 = countSvgLeaves(frames[2]);
  if (n7 != F07_NUM) {
    println("frames-07: hojas = " + n7 + " (esperado " + F07_NUM + "). Revisa F07_REVEAL_ORDER.");
  }
}

void draw() {
  background(255);
  int t = millis();

  int idx;
  if (t < DUR_MS[0]) {
    idx = 0;
  } else if (t < DUR_MS[0] + DUR_MS[1]) {
    idx = 1;
  } else {
    idx = 2;
  }

  if (idx == 0) {
    drawFrame01(t);
  } else if (idx == 1) {
    drawFrame03(t - DUR_MS[0]);
  } else if (idx == 2) {
    drawFrame07(t - DUR_MS[0] - DUR_MS[1]);
  }
}

void drawFrame03(int tRel) {
  tRel = constrain(tRel, 0, DUR_MS[1] - 1);
  float sx = width / 1440f;
  float sy = height / 900f;
  float slice = DUR_MS[1] / (float) F03_NUM;
  int[] counter = new int[] { 0 };
  drawRevealWalk(frames[1], tRel, slice, sx, sy, counter, f03RevealSlot);
}

void drawFrame07(int tRel) {
  tRel = constrain(tRel, 0, DUR_MS[2] - 1);
  float sx = width / 1440f;
  float sy = height / 900f;
  float slice = DUR_MS[2] / (float) F07_NUM;
  int[] counter = new int[] { 0 };
  drawRevealWalk(frames[2], tRel, slice, sx, sy, counter, f07RevealSlot);
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

/**
 * Ondulación lenta (ampX/ampY en píxeles de pantalla; pivotes en coords SVG del viewBox).
 * Un periodo 2π = duración del frame 1 (7 s).
 */
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

/**
 * Solo rotación suave alrededor del punto de enganche al cuerpo (las puntas se mueven, la base no).
 */
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
  float w = 0.88f * sin(0.91f * u + ph) + 0.12f * sin(2.08f * u + ph * 1.2f);
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
