import java.util.ArrayList;

// ============================================================
// REFERENCE TAMIL HOUSE - KARTHIGAI DEEPAM
// COMPLETE APDE / PROCESSING JAVA MODE SKETCH
//
// Features:
// 1. Main two-storey building on RIGHT with dark teal facade
// 2. Left decorative tower moved slightly back (-Z) with 2 stacked jali bays
// 3. Three crisp steps below the left tower door, main door, and rear door
// 4. Corrected external left staircase sloping DOWN-RIGHT
// 5. Corrugated terrace canopy aligned to moved-back tower
// 6. Chamfered left-corner balcony (3 front + 1 chamfer peaked-cap diamonds)
// 7. Dual-row balcony lamps, veranda columns, green grilles & meter box
// 8. Curved compound walls, pedestrian gate, ornate vehicle gate & kolam
// 9. Detailed backside elevation + BACKSIDE VIEW / FRONT VIEW toggle button
// 10. Glowing moon & starfield on the backside sky (-Z) in Night Mode
// 11. 3D Airflow Vector Field + Tangential Boundary Velocity & Pressure-Speed Coloring
// 12. Streamlines (instantaneous), Streaklines (dye emitters), Pathlines (particle trails)
// 13. Divergence Deformation: Transparent 3D Fluid Cuboids compressing & expanding
// 14. Curl Visualization: Tiny 3D Rotating Paddle Wheels driven by local vorticity (curl)
// 15. Interactive HUD with toggles for every fluid visualization mode
//
// Coordinate convention:
//   X = left (-) / right (+)
//   Y = vertical (ground = 0, upward is negative)
//   Z = back (-) / front (+)
// ============================================================

// ---------------- COLOURS -------------------------------

final int CREAM       = 0xFFF0E6D8;
final int CREAM_LIGHT = 0xFFFFF8EC;
final int CREAM_DARK  = 0xFFD7C6AE;

final int TEAL        = 0xFF263F49;
final int TEAL_LIGHT  = 0xFF3D6069;
final int TEAL_DARK   = 0xFF142C35;

final int ROOF        = 0xFF252B30;
final int ROOF_LIGHT  = 0xFF626B70;
final int GLASS       = 0xFF183B3C;
final int GLASS_GREEN = 0xFF5DAB7C;

final int BLACK       = 0xFF17191A;
final int GOLD        = 0xFFFFC34F;
final int GOLD_DARK   = 0xFF98611F;
final int RED         = 0xFFB83229;
final int RED_LIGHT   = 0xFFE0523C;
final int GREEN       = 0xFF16834A;
final int GREEN_LIGHT = 0xFF43B86C;
final int BLUE        = 0xFF285A9B;
final int WHITE       = 0xFFFFFFFF;

final int TILE        = 0xFF985544;
final int ROAD        = 0xFF343638;
final int SOIL        = 0xFF615747;

final int LEAF        = 0xFF397347;
final int LEAF_DARK   = 0xFF204A31;
final int LEAF_LIGHT  = 0xFF66A054;

// ---------------- LAMP, FLUID & STAR CLASSES ------------

class Lamp {
  float x, y, z;
  float phase;
  int zone;
  float size;

  Lamp(float px, float py, float pz, int pzone) {
    x = px;
    y = py;
    z = pz;
    zone = pzone;
    phase = random(TWO_PI);
    size = random(0.88, 1.12);
  }
}

class AirTracer {
  float x, y, z;
  float px, py, pz;
  float life;

  AirTracer() {
    respawn(true);
  }

  void respawn(boolean randomX) {
    x = randomX ? random(-480, 480) : random(-500, -320);
    y = random(-390, -25);
    z = random(-280, 380);
    px = x;
    py = y;
    pz = z;
    life = random(0.4, 1.0);
  }
}

// Pathline particle storing its trajectory history & pressure/speed
class PathParticle {
  float x, y, z;
  float life;
  ArrayList<PVector> trail = new ArrayList<PVector>();
  ArrayList<Float> speeds = new ArrayList<Float>();

  PathParticle() {
    respawn();
  }

  void respawn() {
    x = random(-470, -370);
    y = random(-340, -35);
    z = random(-220, 330);
    life = random(0.6, 1.0);
    trail.clear();
    speeds.clear();
  }
}

// Streakline particle emitted continuously from fixed nozzle points
class StreakParticle {
  float x, y, z;
  float age;
  int nozzleIdx;

  StreakParticle(int nIdx, float nx, float ny, float nz) {
    nozzleIdx = nIdx;
    x = nx;
    y = ny;
    z = nz;
    age = 0;
  }
}

// Deforming transparent fluid cuboid showing Divergence (compression vs expansion)
class FluidParcel {
  float x, y, z;
  float baseW, baseH, baseD;
  float scaleX, scaleY, scaleZ;
  float life;

  FluidParcel() {
    respawn(true);
  }

  void respawn(boolean randomX) {
    x = randomX ? random(-420, 380) : random(-470, -380);
    y = random(-320, -45);
    z = random(-190, 310);
    baseW = 34;
    baseH = 26;
    baseD = 30;
    scaleX = 1.0;
    scaleY = 1.0;
    scaleZ = 1.0;
    life = random(0.65, 1.0);
  }
}

// Tiny rotating paddle wheel driven by local vorticity (Curl = nabla x V)
class CurlPaddle {
  float x, y, z;
  float angle;
  float curlX, curlY, curlZ;
  float curlMag;

  CurlPaddle(float px, float py, float pz) {
    x = px;
    y = py;
    z = pz;
    angle = random(TWO_PI);
  }
}

class SkyStar {
  float x, y, z;
  float size;
  float phase;

  SkyStar(float sx, float sy, float sz) {
    x = sx;
    y = sy;
    z = sz;
    size = random(1.8, 3.8);
    phase = random(TWO_PI);
  }
}

ArrayList<Lamp> lamps = new ArrayList<Lamp>();
ArrayList<AirTracer> tracers = new ArrayList<AirTracer>();
ArrayList<PathParticle> pathParticles = new ArrayList<PathParticle>();
ArrayList<StreakParticle> streakParticles = new ArrayList<StreakParticle>();
ArrayList<FluidParcel> fluidParcels = new ArrayList<FluidParcel>();
ArrayList<CurlPaddle> curlPaddles = new ArrayList<CurlPaddle>();
ArrayList<SkyStar> stars = new ArrayList<SkyStar>();

// Fixed streakline emitter nozzles in front of key architectural features
float[][] streakNozzles = {
  {-440, -240,  75},
  {-440, -145,  85},
  {-440,  -65, 165},
  {-440, -170, 210},
  {-440,  -55, 285},
  {-440, -295, -20},
  {-440, -195, -135}
};

// Reusable vectors to avoid per-frame GC allocation on APDE
PVector airVec   = new PVector();
PVector dirVec   = new PVector();
PVector side1    = new PVector();
PVector side2    = new PVector();
PVector upRef    = new PVector();
PVector tempVel1 = new PVector();
PVector tempVel2 = new PVector();
PVector curlVec  = new PVector();

// ---------------- CAMERA AND CONTROLS --------------------

float cameraYaw   = -0.08;
float cameraPitch =  0.10;
float cameraZoom  =  1.0;

float targetYaw   = -0.08;
float targetPitch =  0.10;
float targetZoom  =  1.0;

float lampBrightness = 1.0;
float lampDensity    = 1.0;
float flameSpeed     = 0.15;
float airflowSpeed   = 1.0;

// Interactive dimension sliders (side depth & front wall length)
float towerRearZ     = -185.0; // Rear Z of left tower (-260 to -140)
float leftWallStartX = -480.0; // Left end X of front compound wall (-540 to -340)

boolean[] zones = {true, true, true, true};
String[] zoneNames = {
  "ROOF", "BALCONY", "COMPOUND", "GROUND"
};

boolean nightMode       = true;
boolean showAirflow     = true;  // Vector field arrows
boolean showStreamlines = true;  // Instantaneous velocity curves
boolean showStreaklines = true;  // Continuous dye streaklines
boolean showPathlines   = true;  // Lagrangian particle pathlines
boolean showDivergence  = true;  // Compressing/expanding transparent cuboids
boolean showCurlPaddles = true;  // Tiny rotating curl paddle wheels
boolean backsideView    = false;
boolean showHUD         = true;

int selectedSlider = -1;
float previousMouseX;
float previousMouseY;
int frameNumber = 0;

// ============================================================
// SETUP
// ============================================================

void setup() {
  fullScreen(P3D);
  frameRate(30);
  smooth(4);

  createLamps();
  createAirTracers();
  createFluidVisualizations();
  createStars();
}

// ============================================================
// MAIN DRAW
// ============================================================

void draw() {

  // Smooth camera transitions for Front/Backside/Reset buttons
  cameraYaw   = lerp(cameraYaw, targetYaw, 0.14);
  cameraPitch = lerp(cameraPitch, targetPitch, 0.14);
  cameraZoom  = lerp(cameraZoom, targetZoom, 0.16);

  if (nightMode) {
    background(10, 22, 46);
  } else {
    background(125, 180, 225);
  }

  pushMatrix();

  translate(width * 0.50, height * 0.68, 0);
  float fit = min(width / 1050.0, height / 850.0);
  scale(fit * cameraZoom);

  rotateX(cameraPitch);
  rotateY(cameraYaw);

  // Draw glowing moon and stars behind everything without halo depth-striping
  if (nightMode) {
    noLights();
    hint(DISABLE_DEPTH_TEST);
    drawMoonAndStars();
    hint(ENABLE_DEPTH_TEST);
  }

  lights();
  if (nightMode) {
    ambientLight(115, 110, 105);
    directionalLight(155, 155, 165, -0.35, 0.70, -0.50);
    directionalLight(45, 62, 95, 0.25, 0.45, 0.85);
  } else {
    ambientLight(165, 160, 155);
    directionalLight(210, 205, 195, -0.40, 0.70, -0.50);
  }

  drawGround();
  drawHouse();

  drawCompoundWalls();
  drawEntrancePillars();
  drawGates();

  drawGarden();
  drawPalmTrees();

  drawLamps();

  // Render Fluid Dynamics Layers
  noLights();
  if (showAirflow)     drawAirflowField();
  if (showStreamlines) drawStreamlines();
  if (showStreaklines) drawStreaklines();
  if (showPathlines)   drawPathlines();
  if (showCurlPaddles) drawCurlPaddles();
  if (showDivergence)  drawDivergenceCuboids();

  popMatrix();

  if (showHUD) {
    drawHUD();
  } else {
    drawMiniHudToggle();
  }

  frameNumber++;
}

// ============================================================
// BASIC 3D HELPERS
// ============================================================

void boxAt(
  float x, float y, float z,
  float w, float h, float d,
  int c
) {
  pushMatrix();
  translate(x, y, z);
  noStroke();
  fill(c);
  box(w, h, d);
  popMatrix();
}

void drawWallSegment(
  float x1, float z1,
  float x2, float z2,
  float yBot, float yTop,
  float thick, int c
) {
  float dx = x2 - x1;
  float dz = z2 - z1;
  float len = sqrt(dx * dx + dz * dz);
  float theta = -atan2(dz, dx);

  pushMatrix();
  translate((x1 + x2) * 0.5, (yBot + yTop) * 0.5, (z1 + z2) * 0.5);
  rotateY(theta);
  noStroke();
  fill(c);
  box(len, abs(yBot - yTop), thick);
  popMatrix();
}

// ============================================================
// NIGHT SKY: STARS AND MOON ON BACKSIDE OF HOUSE (-Z)
// ============================================================

void createStars() {
  stars.clear();
  for (int i = 0; i < 65; i++) {
    float a = random(TWO_PI);
    float r = random(760, 960);
    float sx = cos(a) * r;
    float sz = sin(a) * r;
    float sy = random(-720, -190);
    stars.add(new SkyStar(sx, sy, sz));
  }
}

void drawMoonAndStars() {
  noStroke();
  for (int i = 0; i < stars.size(); i++) {
    SkyStar st = stars.get(i);
    float tw = 160 + 85 * sin(frameNumber * 0.05 + st.phase);
    fill(235, 242, 255, tw);
    pushMatrix();
    translate(st.x, st.y, st.z);
    box(st.size, st.size, st.size);
    popMatrix();
  }

  float mx = -100;
  float my = -560;
  float mz = -420;

  pushMatrix();
  translate(mx, my, mz);
  noStroke();

  fill(175, 205, 255, 32);
  sphereDetail(12);
  sphere(62);

  fill(255, 245, 210, 70);
  sphere(42);

  fill(255, 249, 226);
  sphereDetail(16);
  sphere(28);

  fill(228, 220, 194, 130);
  pushMatrix();
  translate(-8, -5, 20);
  sphereDetail(8);
  sphere(8.5);
  popMatrix();

  pushMatrix();
  translate(9, 6, 19);
  sphereDetail(8);
  sphere(6.0);
  popMatrix();

  popMatrix();
}

// ============================================================
// GROUND, ROAD AND FRONT COURTYARD
// ============================================================

void drawGround() {
  float soilLeftX = min(-580, leftWallStartX - 80);
  float soilRightX = 580;
  float soilW = soilRightX - soilLeftX;
  float soilCX = (soilLeftX + soilRightX) * 0.5;

  boxAt(soilCX, 10, 30, soilW, 20, 860, SOIL);
  boxAt(soilCX, 13, 475, soilW + 180, 10, 180, ROAD);

  float curbLeftX = leftWallStartX - 40;
  float curbRightX = 540;
  boxAt((curbLeftX + curbRightX) * 0.5, 4, 342, curbRightX - curbLeftX, 8, 66, CREAM_DARK);

  boxAt(110, 0, 248, 355, 4, 235, TILE);
  boxAt(-40, 0, 230, 78, 4, 210, TILE);
  boxAt(-300, 0, 196, 92, 4, 152, TILE);
  boxAt(110, 0, -210, 420, 4, 110, CREAM_DARK);

  stroke(120, 72, 57);
  strokeWeight(1);
  for (int i = 0; i <= 12; i++) {
    float x = -65 + i * 29;
    line(x, -2.5, 132, x, -2.5, 362);
  }
  for (int i = 0; i <= 8; i++) {
    float z = 135 + i * 28;
    line(-65, -2.5, z, 285, -2.5, z);
  }
  noStroke();
}

// ============================================================
// COMPLETE HOUSE ASSEMBLY
// ============================================================

void drawHouse() {
  drawMainGroundBuilding();
  drawLeftTower();
  drawUpperBuilding();
  drawTerraceCanopy();
  drawExternalStaircase();

  drawGroundFloorVeranda();
  drawGroundFloorWindows();

  drawUpperWindows();
  drawChamferedBalcony();
  drawRoofDetails();
  drawRearAndSideDetails();
}

void drawMainGroundBuilding() {
  boxAt(150, -68, -22, 380, 136, 274, CREAM);
  boxAt(258, -68, 117, 164, 136, 8, TEAL);
  boxAt(150, 2, -22, 396, 8, 290, CREAM_DARK);
  boxAt(342, -68, 45, 5, 136, 150, TEAL);
}

void drawLeftTower() {
  float frontZ = 79.0;
  float depthZ = frontZ - towerRearZ;
  float centerZ = (frontZ + towerRearZ) * 0.5;

  boxAt(-300, -135, centerZ, 100, 270, depthZ, CREAM);
  boxAt(-300, -4,   centerZ, 108, 8, depthZ + 8,  CREAM_DARK);
  boxAt(-300, -124, centerZ, 110, 8, depthZ + 10, CREAM_LIGHT);
  boxAt(-300, -272, centerZ, 112, 10, depthZ + 12, CREAM_LIGHT);

  drawDoor(-300, -64, 80, 48, 92, TEAL_DARK);

  boxAt(-300, -15, 86,  60, 6, 14, CREAM_LIGHT);
  boxAt(-300, -9,  93,  68, 6, 28, CREAM_DARK);
  boxAt(-300, -3,  100, 76, 6, 42, CREAM_LIGHT);

  boxAt(-300, -197, 80, 90, 132, 6, TEAL);
  drawTowerLatticeBay(-300, -229, 84);
  drawTowerLatticeBay(-300, -165, 84);

  boxAt(-352, -124, centerZ, 6, 8, depthZ + 10, CREAM_LIGHT);
}

void drawTowerLatticeBay(float cx, float cy, float z) {
  float ox = 25;
  float oy = 18;
  boxAt(cx - ox, cy - oy, z, 28, 22, 4, CREAM_LIGHT);
  boxAt(cx + ox, cy - oy, z, 28, 22, 4, CREAM_LIGHT);
  boxAt(cx - ox, cy + oy, z, 28, 22, 4, CREAM_LIGHT);
  boxAt(cx + ox, cy + oy, z, 28, 22, 4, CREAM_LIGHT);

  int glowCol = nightMode ? 0xFFFFDF94 : CREAM_DARK;
  boxAt(cx, cy, z + 1, 22, 22, 4, glowCol);

  stroke(CREAM_LIGHT);
  strokeWeight(2.2);
  noFill();
  pushMatrix();
  translate(cx, cy, z + 4);
  rectMode(CENTER);
  rect(0, 0, 22, 22);
  line(-4, -11, -4, 11);
  line( 4, -11,  4, 11);
  line(-11, -4, 11, -4);
  line(-11,  4, 11,  4);
  rectMode(CORNER);
  popMatrix();
  noStroke();
}

void drawUpperBuilding() {
  boxAt(155, -215, -18, 370, 160, 270, CREAM);
  boxAt(-140, -210, 10, 220, 120, 14, CREAM);
  drawDoor(-222, -198, 18, 38, 86, TEAL_DARK);
  boxAt(250, -215, 119, 180, 158, 10, TEAL);
  boxAt(238, -333, -10, 204, 66, 266, TEAL);
  boxAt(238, -368, -10, 212, 8, 276, CREAM_LIGHT);
  boxAt(134, -333, -10, 8, 66, 266, CREAM);
  drawPeakedDiamond(238, -333, 126, 33, CREAM_LIGHT, TEAL_DARK, true);
}

void drawTerraceCanopy() {
  boxAt(-97.5, -272, -29, 305, 8, 230, ROOF);
  boxAt(-97.5, -272,  86, 312, 8, 8, ROOF_LIGHT);
  boxAt(-97.5, -272, -144, 312, 8, 8, ROOF_LIGHT);

  stroke(95, 104, 110);
  strokeWeight(2);
  for (int i = 0; i <= 30; i++) {
    float x = -248 + i * 10;
    line(x, -277, -143, x, -277, 85);
  }
  noStroke();

  float[] postX = {-242, -135, -35, 50};
  for (int i = 0; i < postX.length; i++) {
    boxAt(postX[i], -214,  80, 5, 116, 5, ROOF);
    boxAt(postX[i], -214, -138, 5, 116, 5, ROOF);
  }
  boxAt(-97.5, -264, 80, 305, 6, 6, ROOF_LIGHT);
}

void drawExternalStaircase() {
  boxAt(-105, -150, -22, 290, 12, 256, CREAM_DARK);
  boxAt(-202.5, -91, 90, 95, 182, 32, CREAM);
  boxAt(-202.5, -184, 90, 96, 5, 36, CREAM_LIGHT);

  float zF = 106;
  float zB = 74;

  noStroke();
  fill(CREAM);

  beginShape(QUADS);
  normal(0, 0, 1);
  vertex(-155, -182, zF);
  vertex(-15,   -6,  zF);
  vertex(-15,    0,  zF);
  vertex(-155,   0,  zF);
  endShape();

  beginShape(QUADS);
  normal(0, 0, -1);
  vertex(-155, -182, zB);
  vertex(-155,   0,  zB);
  vertex(-15,    0,  zB);
  vertex(-15,   -6,  zB);
  endShape();

  beginShape(QUADS);
  normal(1, 0, 0);
  vertex(-15, -6, zF);
  vertex(-15, -6, zB);
  vertex(-15,  0, zB);
  vertex(-15,  0, zF);
  endShape();

  float dx = 140;
  float dy = 176;
  float slopeLen = sqrt(dx * dx + dy * dy);
  float slopeAngle = atan2(dy, dx);

  pushMatrix();
  translate(-85, -94, 90);
  rotateZ(slopeAngle);
  boxAt(0, -2, 0, slopeLen + 4, 6, 36, CREAM_LIGHT);
  boxAt(0,  3, 0, slopeLen + 4, 3, 35, TEAL);
  popMatrix();

  for (int i = 0; i < 12; i++) {
    float t = i / 11.0;
    float sx = lerp(-152, -22, t);
    float sy = lerp(-150, -10, t);
    boxAt(sx, sy + 5, 55, 18, 10, 38, CREAM_DARK);
    boxAt(sx, sy, 55, 19, 3, 39, CREAM_LIGHT);
  }
}

void drawGroundFloorVeranda() {
  boxAt(12, -66, 188, 22, 132, 22, TEAL_DARK);
  boxAt(12, -129, 188, 30, 8, 30, CREAM_LIGHT);
  boxAt(12, -4, 188, 30, 8, 30, CREAM_DARK);
  boxAt(12, -120, 199, 24, 3, 3, GOLD_DARK);

  boxAt(172, -66, 132, 22, 132, 22, TEAL_DARK);
  boxAt(172, -129, 132, 28, 7, 28, CREAM_LIGHT);
  boxAt(172, -4, 132, 28, 7, 28, CREAM_DARK);

  stroke(GLASS_GREEN);
  strokeWeight(2.2);
  for (float gx = 32; gx <= 158; gx += 12) {
    line(gx, -128, 174, gx, -4, 174);
  }
  for (float gy = -110; gy <= -20; gy += 30) {
    line(26, gy, 174, 162, gy, 174);
  }
  noStroke();

  if (nightMode) {
    boxAt(95, -126, 150, 12, 5, 12, 0xFFFFF2B8);
  } else {
    boxAt(95, -126, 150, 12, 5, 12, WHITE);
  }
}

void drawGroundFloorWindows() {
  drawWindow(-12, -62, 117, 52, 64, GLASS_GREEN, true);
  drawDoor(95, -64, 117, 52, 92, TEAL_DARK);
  boxAt(95, -15, 122, 62, 6, 14, CREAM_LIGHT);
  boxAt(95, -9,  129, 70, 6, 28, CREAM_DARK);
  boxAt(95, -3,  136, 78, 6, 42, CREAM_LIGHT);

  boxAt(205, -62, 122, 34, 48, 5, CREAM_LIGHT);
  boxAt(205, -62, 125, 28, 42, 2, CREAM_DARK);
  drawWindow(282, -62, 122, 58, 66, GLASS, true);
}

void drawUpperWindows() {
  drawWindow(252, -218, 125, 52, 66, GLASS, false);
  drawWindow(55, -205, 58, 44, 62, GLASS_GREEN, true);
  drawWindow(118, -205, 118, 34, 62, GLASS_GREEN, false);
}

void drawWindow(
  float x, float y, float z,
  float w, float h, int glassCol,
  boolean threeCols
) {
  int pane = (nightMode && glassCol == GLASS_GREEN) ? 0xFF7AD296 : glassCol;
  boxAt(x, y, z, w, h, 4, pane);

  boxAt(x, y - h / 2, z + 3, w + 8, 5, 6, CREAM_LIGHT);
  boxAt(x, y + h / 2, z + 3, w + 8, 5, 6, CREAM_LIGHT);
  boxAt(x - w / 2, y, z + 3, 5, h + 6, 6, CREAM_LIGHT);
  boxAt(x + w / 2, y, z + 3, 5, h + 6, 6, CREAM_LIGHT);

  if (threeCols) {
    boxAt(x - w / 6, y, z + 5, 3, h, 3, CREAM_DARK);
    boxAt(x + w / 6, y, z + 5, 3, h, 3, CREAM_DARK);
  } else {
    boxAt(x, y, z + 5, 3, h, 3, CREAM_DARK);
  }
  boxAt(x, y, z + 5, w, 3, 3, CREAM_DARK);
}

void drawDoor(
  float x, float y, float z,
  float w, float h, int doorColor
) {
  boxAt(x, y, z, w, h, 6, doorColor);
  boxAt(x, y - h / 2, z + 4, w + 8, 5, 8, CREAM_LIGHT);
  boxAt(x - w / 2, y, z + 4, 5, h + 6, 8, CREAM_LIGHT);
  boxAt(x + w / 2, y, z + 4, 5, h + 6, 8, CREAM_LIGHT);
  boxAt(x, y - h * 0.20, z + 4, w * 0.65, h * 0.34, 3, TEAL_LIGHT);
  boxAt(x, y + h * 0.22, z + 4, w * 0.65, h * 0.34, 3, TEAL);
  boxAt(x + w * 0.28, y, z + 7, 3, 8, 3, GOLD);
}

void drawChamferedBalcony() {
  boxAt(150, -131, 136, 390, 8, 44, CREAM_DARK);
  boxAt(176.5, -131, 184, 337, 8, 52, CREAM_DARK);

  fill(CREAM_DARK);
  noStroke();
  beginShape(TRIANGLES);
  normal(0, -1, 0);
  vertex(-45, -135, 158);
  vertex(  8, -135, 158);
  vertex(  8, -135, 210);

  normal(0, 1, 0);
  vertex(-45, -127, 158);
  vertex(  8, -127, 210);
  vertex(  8, -127, 158);
  endShape();

  drawWallSegment(-45, 158, 8, 210, -127, -135, 6, CREAM_LIGHT);
  drawWallSegment(8, 210, 345, 210, -127, -132, 6, TEAL);
  drawWallSegment(-45, 158, 8, 210, -127, -132, 7, TEAL);

  drawWallSegment(-45, 115, -45, 158, -135, -192, 14, CREAM);
  drawWallSegment(-45, 158,   8, 210, -135, -192, 14, CREAM);
  drawWallSegment(  8, 210, 345, 210, -135, -192, 14, CREAM);
  drawWallSegment(345, 210, 345, 115, -135, -192, 14, CREAM);

  drawWallSegment(-45, 115, -45, 158, -191, -196, 18, CREAM_LIGHT);
  drawWallSegment(-45, 158,   8, 210, -191, -196, 18, CREAM_LIGHT);
  drawWallSegment(  8, 210, 345, 210, -191, -196, 18, CREAM_LIGHT);
  drawWallSegment(345, 210, 345, 115, -191, -196, 18, CREAM_LIGHT);

  drawWallSegment(8, 211, 345, 211, -187, -191, 16, TEAL);
  drawWallSegment(-45, 159, 8, 211, -187, -191, 16, TEAL);

  drawPeakedDiamond( 72, -164, 212, 27, CREAM_LIGHT, TEAL_DARK, false);
  drawPeakedDiamond(178, -164, 212, 27, CREAM_LIGHT, TEAL_DARK, false);
  drawPeakedDiamond(284, -164, 212, 27, CREAM_LIGHT, TEAL_DARK, false);

  float chamferAngle = -atan2(52, 53);
  pushMatrix();
  translate(-18.5, -164, 184);
  rotateY(chamferAngle);
  drawPeakedDiamond(0, 0, 5, 21, CREAM_LIGHT, TEAL_DARK, false);
  popMatrix();
}

void drawPeakedDiamond(
  float x, float y, float z,
  float s, int borderColor, int insideColor, boolean glowing
) {
  pushMatrix();
  translate(x, y, z);

  noStroke();
  fill(TEAL_DARK);
  beginShape(TRIANGLES);
  vertex(-s * 0.88, -s * 0.12, -2);
  vertex(0, -s * 1.32, -2);
  vertex(s * 0.88, -s * 0.12, -2);
  endShape();

  fill(borderColor);
  beginShape();
  vertex(0, -s * 1.15, 0);
  vertex(s * 0.85, 0, 0);
  vertex(0, s * 1.05, 0);
  vertex(-s * 0.85, 0, 0);
  endShape(CLOSE);

  int inner = (glowing && nightMode) ? 0xFFFFD87D : insideColor;
  fill(inner);
  beginShape();
  vertex(0, -s * 0.82, 2);
  vertex(s * 0.62, 0, 2);
  vertex(0, s * 0.82, 2);
  vertex(-s * 0.62, 0, 2);
  endShape(CLOSE);

  stroke(borderColor);
  strokeWeight(3.2);
  noFill();
  beginShape();
  vertex(0, -s * 0.82, 4);
  vertex(s * 0.62, 0, 4);
  vertex(0, s * 0.82, 4);
  vertex(-s * 0.62, 0, 4);
  endShape(CLOSE);

  line(-s * 0.31, -s * 0.41, 4,  s * 0.31,  s * 0.41, 4);
  line(-s * 0.31,  s * 0.41, 4,  s * 0.31, -s * 0.41, 4);
  line(-s * 0.15, -s * 0.61, 4,  s * 0.46,  s * 0.20, 4);
  line(-s * 0.46, -s * 0.20, 4,  s * 0.15,  s * 0.61, 4);
  line(-s * 0.46,  s * 0.20, 4,  s * 0.15, -s * 0.61, 4);
  line(-s * 0.15,  s * 0.61, 4,  s * 0.46, -s * 0.20, 4);

  noStroke();
  popMatrix();
}

void drawRoofDetails() {
  boxAt(165, -296, -10, 396, 10, 296, CREAM_LIGHT);
  boxAt(165, -289, -10, 392, 5, 292, TEAL_DARK);
  boxAt(342, -215, 45, 5, 160, 150, CREAM_LIGHT);
}

void drawRearAndSideDetails() {
  float towerMidZ = (79.0 + towerRearZ) * 0.5;

  pushMatrix();
  translate(-351, -68, towerMidZ - 15);
  rotateY(-HALF_PI);
  drawWindow(0, 0, 0, 52, 58, GLASS, false);
  popMatrix();

  pushMatrix();
  translate(342, -68, -55);
  rotateY(HALF_PI);
  drawWindow(0, 0, 0, 52, 62, GLASS, false);
  popMatrix();

  pushMatrix();
  translate(342, -215, -55);
  rotateY(HALF_PI);
  drawWindow(0, 0, 0, 52, 62, GLASS, false);
  popMatrix();

  boxAt(250, -215, -155, 160, 158, 6, TEAL);
  boxAt(250, -68, -161, 160, 136, 6, TEAL);

  pushMatrix();
  translate(115, -64, -161);
  rotateY(PI);
  drawDoor(0, 0, 0, 48, 92, TEAL_DARK);
  popMatrix();
  boxAt(115, -15, -166, 62, 6, 14, CREAM_LIGHT);
  boxAt(115, -9,  -173, 70, 6, 28, CREAM_DARK);
  boxAt(115, -3,  -180, 78, 6, 42, CREAM_LIGHT);

  pushMatrix();
  translate(15, -66, -161);
  rotateY(PI);
  drawWindow(0, 0, 0, 52, 60, GLASS_GREEN, false);
  popMatrix();

  pushMatrix();
  translate(255, -66, -166);
  rotateY(PI);
  drawWindow(0, 0, 0, 54, 60, GLASS, true);
  popMatrix();

  pushMatrix();
  translate(55, -215, -156);
  rotateY(PI);
  drawWindow(0, 0, 0, 48, 62, GLASS_GREEN, false);
  popMatrix();

  pushMatrix();
  translate(245, -215, -160);
  rotateY(PI);
  drawWindow(0, 0, 0, 52, 64, GLASS, false);
  popMatrix();

  boxAt(-140, -174, -142, 210, 38, 8, CREAM);
  boxAt(-140, -195, -142, 214, 5, 12, CREAM_LIGHT);

  boxAt(-52, -225, -162, 34, 24, 14, CREAM_LIGHT);
  boxAt(-58, -225, -170, 16, 16, 3, ROOF);

  pushMatrix();
  translate(-300, -195, towerRearZ - 2);
  rotateY(PI);
  drawWindow(0, 0, 0, 34, 42, GLASS_GREEN, false);
  popMatrix();
}

// ============================================================
// CURVED COMPOUND WALLS, PILLARS & GATES
// ============================================================

void drawCompoundWalls() {
  float midPillarX = (leftWallStartX - 65.0) * 0.5;
  drawCurvedWall(leftWallStartX, midPillarX, 285, 0, 62, 18);
  boxAt(midPillarX, -36, 285, 16, 72, 20, CREAM_LIGHT);
  drawCurvedWall(midPillarX, -65, 285, 0, 62, 18);

  drawCurvedWall(-15, 60, 285, 0, 62, 11);
  boxAt(22, -46, 296, 10, 12, 6, BLACK);
  drawCurvedWall(195, 480, 285, 0, 62, 18);
}

void drawCurvedWall(
  float x1, float x2, float z,
  float bottomY, float h, float arch
) {
  int steps = 28;
  noStroke();
  fill(CREAM);

  beginShape(QUAD_STRIP);
  for (int i = 0; i <= steps; i++) {
    float t = i / (float)steps;
    float x = lerp(x1, x2, t);
    float top = bottomY - h - sin(t * PI) * arch;
    vertex(x, bottomY, z + 7);
    vertex(x, top, z + 7);
  }
  endShape();

  beginShape(QUAD_STRIP);
  for (int i = 0; i <= steps; i++) {
    float t = i / (float)steps;
    float x = lerp(x1, x2, t);
    float top = bottomY - h - sin(t * PI) * arch;
    vertex(x, top, z - 7);
    vertex(x, bottomY, z - 7);
  }
  endShape();

  stroke(CREAM_LIGHT);
  strokeWeight(5);
  noFill();
  beginShape();
  for (int i = 0; i <= steps; i++) {
    float t = i / (float)steps;
    float x = lerp(x1, x2, t);
    float top = bottomY - h - sin(t * PI) * arch;
    vertex(x, top, z);
  }
  endShape();

  stroke(TEAL);
  strokeWeight(3);
  beginShape();
  for (int i = 0; i <= steps; i++) {
    float t = i / (float)steps;
    float x = lerp(x1, x2, t);
    float top = bottomY - h - sin(t * PI) * arch;
    vertex(x, top + 3, z + 8);
  }
  endShape();
  noStroke();
}

void drawEntrancePillars() {
  drawPillar(leftWallStartX);
  drawPillar(-65);
  drawPillar(-15);
  drawPillar(60);
  drawPillar(195);
}

void drawPillar(float x) {
  boxAt(x, -36, 285, 22, 72, 26, CREAM);
  boxAt(x, -74, 285, 30, 7, 32, CREAM_LIGHT);
  boxAt(x, -2, 285, 28, 6, 30, CREAM_DARK);
  boxAt(x, -36, 299, 10, 28, 3, TEAL);
}

void drawGates() {
  drawGate(-40, -37, 286, 38, 72, true);
  drawGate(127.5, -38, 286, 112, 74, false);
}

void drawGate(
  float x, float y, float z,
  float w, float h, boolean pedestrian
) {
  pushMatrix();
  translate(x, y, z);

  noStroke();
  fill(BLACK);
  box(w, h, 5);

  float panelW = pedestrian ? w * 0.28 : w * 0.30;
  boxAt(-w * 0.24, h * 0.08, 3, panelW, h * 0.44, 3, RED);
  boxAt( w * 0.24, h * 0.08, 3, panelW, h * 0.44, 3, GREEN);
  boxAt(-w * 0.24, -h * 0.20, 4, panelW * 0.7, h * 0.16, 2, BLUE);
  boxAt( w * 0.24, -h * 0.20, 4, panelW * 0.7, h * 0.16, 2, GREEN_LIGHT);

  for (int i = 0; i < 4; i++) {
    float by = -h * 0.38 + i * h * 0.24;
    boxAt(0, by, 5, w - 4, 3, 3, BLACK);
  }
  for (float bx = -w * 0.42; bx <= w * 0.42; bx += 9) {
    boxAt(bx, 0, 6, 2.5, h - 4, 2.5, BLACK);
  }
  for (float bx = -w * 0.36; bx <= w * 0.36; bx += 16) {
    boxAt(bx, -h * 0.38, 7, 4, 4, 2, GOLD);
    boxAt(bx, -h * 0.14, 7, 4, 4, 2, GOLD);
  }

  pushMatrix();
  translate(0, h * 0.26, 7);
  fill(GOLD);
  sphereDetail(8);
  sphere(pedestrian ? 4.5 : 7);
  popMatrix();

  stroke(BLACK);
  strokeWeight(3);
  noFill();
  beginShape();
  for (int i = 0; i <= 12; i++) {
    float t = i / 12.0;
    float gx = lerp(-w * 0.48, w * 0.48, t);
    float gy = -h * 0.48 - sin(t * PI) * 8;
    vertex(gx, gy, 5);
  }
  endShape();
  noStroke();

  for (float bx = -w * 0.40; bx <= w * 0.40; bx += 18) {
    boxAt(bx, -h * 0.54, 5, 3, 5, 3, GOLD);
  }
  popMatrix();
}

// ============================================================
// GARDEN, SHRUBS & PALM TREES
// ============================================================

void drawGarden() {
  int idx = 0;
  for (float x = leftWallStartX + 25; x <= -85; x += 44) {
    drawShrub(x, 0, 260, 0.85 + (idx % 3) * 0.12);
    drawFlower(x - 10, -14, 268, idx);
    drawFlower(x + 12, -10, 266, idx + 1);
    idx++;
  }
  for (int i = 0; i < 6; i++) {
    float x = 225 + i * 45;
    drawShrub(x, 0, 260, 0.90 + (i % 2) * 0.15);
    drawFlower(x, -12, 268, i + 2);
  }
  drawShrub(-220, 0, min(-230, towerRearZ - 45), 1.0);
  drawShrub(330, 0, -210, 1.1);
}

void drawShrub(float x, float y, float z, float s) {
  pushMatrix();
  translate(x, y - 12, z);
  scale(s);
  noStroke();
  fill(LEAF_DARK);
  sphereDetail(6);
  sphere(16);
  translate(14, -5, 0);
  fill(LEAF);
  sphere(14);
  translate(-25, -4, 0);
  fill(LEAF_LIGHT);
  sphere(11);
  popMatrix();
}

void drawFlower(float x, float y, float z, int index) {
  pushMatrix();
  translate(x, y, z);
  int petal = (index % 3 == 0) ? 0xFFFF6CA8 : (index % 3 == 1 ? 0xFFFFD66D : 0xFFE790E7);
  noStroke();
  fill(petal);
  sphereDetail(5);
  sphere(4);
  fill(GOLD);
  sphere(2);
  popMatrix();
}

void drawPalmTrees() {
  drawPalm(-380, 0, min(-245, towerRearZ - 60), 360);
  drawPalm(-40,  0, -240, 385);
  drawPalm(455,  0, -60,  345);
}

void drawPalm(float x, float y, float z, float h) {
  float tx = x + 18;
  float ty = y - h;

  stroke(96, 68, 42);
  strokeWeight(9);
  line(x, y, z, tx, ty, z);

  stroke(LEAF_DARK);
  strokeWeight(4.5);
  for (int i = 0; i < 11; i++) {
    float a = PI + i * PI / 10.0;
    float ex = tx + cos(a) * 140;
    float ey = ty + sin(a) * 82;
    line(tx, ty, z, ex, ey, z);
    for (int k = 1; k <= 5; k++) {
      float t = k / 6.0;
      float mx = lerp(tx, ex, t);
      float my = lerp(ty, ey, t);
      line(mx, my, z, mx + 16, my + 12, z + 3);
      line(mx, my, z, mx - 16, my + 12, z - 3);
    }
  }
  noStroke();
}

// ============================================================
// NEATLY ALIGNED KARTHIGAI DEEPAM LAMP POSITIONS
// ============================================================

void createLamps() {
  lamps.clear();

  for (float x = -345; x <= -255; x += 22) addLamp(x, -277, 82, 0);
  for (float x = -235; x <= 50; x += 24)   addLamp(x, -276, 87, 0);
  for (float x = -25; x <= 355; x += 24)   addLamp(x, -301, 134, 0);
  for (float z = -140; z <= 120; z += 26)  addLamp(-28, -301, z, 0);
  for (float x = 140; x <= 335; x += 24)   addLamp(x, -372, 125, 0);
  for (float z = -125; z <= 115; z += 26)  addLamp(136, -372, z, 0);

  for (float x = 14; x <= 340; x += 22) {
    if (abs(x - 72) < 12 || abs(x - 178) < 12 || abs(x - 284) < 12) continue;
    addLamp(x, -196, 212, 1);
  }
  for (int i = 0; i <= 3; i++) {
    float t = i / 3.0;
    addLamp(lerp(-42, 6, t), -196, lerp(160, 208, t), 1);
  }
  for (float x = 12; x <= 342; x += 22) addLamp(x, -135, 214, 1);
  for (int i = 0; i <= 3; i++) {
    float t = i / 3.0;
    addLamp(lerp(-44, 6, t), -135, lerp(160, 210, t), 1);
  }
  for (float x = -245; x <= -160; x += 21) addLamp(x, -186.5, 100, 1);
  for (int i = 1; i <= 8; i++) {
    float t = i / 8.5;
    addLamp(lerp(-155, -20, t), lerp(-186, -12, t), 100, 1);
  }

  float midPillarX = (leftWallStartX - 65.0) * 0.5;
  for (float x = leftWallStartX + 12; x <= midPillarX - 12; x += 23) {
    float t = map(x, leftWallStartX, midPillarX, 0, 1);
    addLamp(x, -64 - sin(t * PI) * 18, 285, 2);
  }
  for (float x = midPillarX + 12; x <= -78; x += 23) {
    float t = map(x, midPillarX, -65, 0, 1);
    addLamp(x, -64 - sin(t * PI) * 18, 285, 2);
  }
  for (float x = -4; x <= 48; x += 18) {
    float t = map(x, -15, 60, 0, 1);
    addLamp(x, -64 - sin(t * PI) * 11, 285, 2);
  }
  for (float x = 208; x <= 470; x += 23) {
    float t = map(x, 195, 480, 0, 1);
    addLamp(x, -64 - sin(t * PI) * 18, 285, 2);
  }
  addLamp(leftWallStartX, -78, 285, 2);
  addLamp(-65, -78, 285, 2);
  addLamp(-15, -78, 285, 2);
  addLamp(60,  -78, 285, 2);
  addLamp(195, -78, 285, 2);

  for (float x = leftWallStartX + 20; x <= -75; x += 46) addLamp(x, 0, 322, 3);
  for (float x = 205; x <= 455; x += 46) addLamp(x, 0, 322, 3);
  float kx = 128;
  float kz = 365;
  for (float a = 0; a < TWO_PI; a += PI / 6.0) addLamp(kx + cos(a) * 62, 0, kz + sin(a) * 38, 3);
  for (float a = 0; a < TWO_PI; a += PI / 4.0) addLamp(kx + cos(a) * 34, 0, kz + sin(a) * 21, 3);
  addLamp(kx, 0, kz, 3);

  for (float x = -80; x <= 290; x += 46) addLamp(x, -2, -250, 3);
}

void addLamp(float x, float y, float z, int zone) {
  lamps.add(new Lamp(x, y, z, zone));
}

void drawLamps() {
  int step = max(1, round(1.0 / max(0.10, lampDensity)));
  float t = frameNumber * 0.04 * max(0.2, airflowSpeed);

  for (int i = 0; i < lamps.size(); i += step) {
    Lamp l = lamps.get(i);
    if (!zones[l.zone]) continue;

    computeAirVelocity(l.x, l.y - 10, l.z, t);
    float windScale = (l.zone == 1 && l.y > -140) ? 0.45 : 1.0;
    float windLeanX = airVec.x * airflowSpeed * 1.45 * windScale;
    float windLeanZ = airVec.z * airflowSpeed * 1.15 * windScale;

    float flicker = 1.0 + sin(frameNumber * flameSpeed + l.phase) * 0.14;

    pushMatrix();
    translate(l.x, l.y, l.z);
    scale(l.size);
    drawOilLamp(lampBrightness * flicker, l.phase, windLeanX, windLeanZ);
    popMatrix();
  }
}

void drawOilLamp(float power, float phase, float windLeanX, float windLeanZ) {
  pushMatrix();
  translate(0, -2, 0);
  rotateX(HALF_PI);
  noStroke();
  fill(0xFF9B4F2E);
  ellipse(0, 0, 15, 10);
  fill(0xFFD87D40);
  ellipse(0, 0, 10, 6);
  fill(GOLD_DARK);
  ellipse(0, 0, 4, 2.5);
  popMatrix();

  if (lampBrightness > 0.02) {
    drawFlame(power, phase, windLeanX, windLeanZ);
  }
}

void drawFlame(float power, float phase, float windLeanX, float windLeanZ) {
  float s = constrain(power, 0.2, 1.5);
  float flutter = sin(frameNumber * flameSpeed + phase) * 1.4;
  float lx = constrain(windLeanX + flutter, -5.5, 5.5);
  float lz = constrain(windLeanZ, -4.0, 4.0);

  pushMatrix();
  translate(lx * 0.5, -7, lz * 0.5);

  noStroke();
  fill(255, 80, 12, 225);
  triangle(-3.6 * s, 2, 3.6 * s, 2, lx, -14 * s);

  fill(255, 168, 28, 245);
  triangle(-2.3 * s, 1, 2.3 * s, 1, lx * 0.75, -10 * s);

  fill(255, 240, 175, 255);
  ellipse(lx * 0.2, -3, 2.3 * s, 3.8 * s);
  popMatrix();
}

// ============================================================
// 3D AIRFLOW PHYSICS: TANGENTIAL DEFLECTION, PRESSURE/SPEED
// COLORING, STREAMLINES, STREAKLINES, PATHLINES, DIVERGENCE
// CUBOIDS & CURL ROTATING PADDLES
// ============================================================

void createAirTracers() {
  tracers.clear();
  for (int i = 0; i < 24; i++) {
    tracers.add(new AirTracer());
  }
}

void createFluidVisualizations() {
  // 1. Lagrangian Pathline particles
  pathParticles.clear();
  for (int i = 0; i < 22; i++) {
    pathParticles.add(new PathParticle());
  }

  // 2. Streakline particles
  streakParticles.clear();

  // 3. Deforming Transparent Cuboids (Divergence parcels)
  fluidParcels.clear();
  for (int i = 0; i < 16; i++) {
    fluidParcels.add(new FluidParcel());
  }

  // 4. Tiny Rotating Curl Paddle Wheels placed in shear & wake zones
  curlPaddles.clear();
  float[][] paddleCoords = {
    {-300, -295,  50},  // Above left tower roof shear
    {-365, -140,  10},  // Windward left tower stagnation/wrap
    {-235, -150,  95},  // Gap vortex between tower & staircase
    {  -5, -210, 218},  // Chamfered balcony corner edge vortex
    { 175, -165, 225},  // Balcony parapet top shear layer
    { 120, -390,  60},  // Roof parapet wake shear
    { 365, -140,  60},  // Leeward right building wake vortex
    {-120,  -95, 285},  // Compound wall arch upward jet shear
    {  95,  -95, 235}   // Courtyard recirculation eddy
  };
  for (int i = 0; i < paddleCoords.length; i++) {
    curlPaddles.add(new CurlPaddle(paddleCoords[i][0], paddleCoords[i][1], paddleCoords[i][2]));
  }
}

// Bernoulli-coupled color mapping:
// Low speed / High stagnation pressure (Blue/Cyan) -> Medium (Green/Yellow) -> High speed / Low pressure Venturi jet (Orange/Red)
int getVelocityPressureColor(float speedMag) {
  float norm = constrain((speedMag - 0.55) / 1.05, 0, 1);
  if (norm < 0.35) {
    // High Static Pressure / Stagnation Zone -> Deep Blue to Cyan
    return lerpColor(0xFF1E6BFF, 0xFF00E5FF, norm / 0.35);
  } else if (norm < 0.70) {
    // Moderate Velocity / Dynamic Transition -> Cyan to Bright Gold-Yellow
    return lerpColor(0xFF00E5FF, 0xFFFFD600, (norm - 0.35) / 0.35);
  } else {
    // High Velocity / Low Static Pressure Venturi Jet -> Gold-Yellow to Fiery Red-Orange
    return lerpColor(0xFFFFD600, 0xFFFF2A1A, (norm - 0.70) / 0.30);
  }
}

// Computes physically consistent 3D velocity field V(x, y, z, t) with:
// - Proper tangential slip along walls (zero normal penetration: V_n -> 0, V_t amplified)
// - Stagnation high-pressure zones in front of bluff bodies
// - Venturi acceleration over roofs & around corners
// - Compressible divergence zones (compression windward, expansion leeward/upward)
void computeAirVelocity(float x, float y, float z, float t) {
  // Base prevailing unsteady wind from West-Southwest (+X, -Z)
  float vx = 1.00 + 0.16 * sin(t * 0.75 + z * 0.006);
  float vy = 0.05 * sin(t * 0.90 + x * 0.007);
  float vz = -0.42 + 0.12 * cos(t * 0.65 + x * 0.005);

  // 1. Main two-storey house block tangential & stagnation deflection
  deflectAroundBox(x, y, z, -38, 345, -298, -2, -158, 132, 70, 1.05, vx, vy, vz);
  vx = airVec.x; vy = airVec.y; vz = airVec.z;

  // 2. Left decorative tower tangential & stagnation deflection
  deflectAroundBox(x, y, z, -352, -248, -275, -2, towerRearZ - 2, 82, 58, 0.98, vx, vy, vz);
  vx = airVec.x; vy = airVec.y; vz = airVec.z;

  // 3. Chamfered front balcony deflection
  deflectAroundBox(x, y, z, -45, 345, -196, -126, 130, 212, 42, 0.85, vx, vy, vz);
  vx = airVec.x; vy = airVec.y; vz = airVec.z;

  // 4. Curved front compound wall upward tangential deflection
  if (abs(z - 285) < 75 && y > -115 && x > leftWallStartX && x < 480) {
    float dz = (z - 285) / 45.0;
    float wallW = exp(-dz * dz) * max(0.0, 1.0 - abs(y) / 115.0);
    // Normal is Z; redirect normal Z momentum into upward tangential Y flow
    vy -= 0.68 * wallW * max(0.2, abs(vz) + 0.35);
    vz *= (1.0 - 0.75 * wallW);
    vx += 0.18 * wallW;
  }

  // 5. Thermal updraft plume from warm Karthigai Deepam oil lamps
  if (x > -340 && x < 340 && y > -390 && y < -20 && z > towerRearZ && z < 230) {
    vy -= 0.12;
  }

  // 6. Ground boundary layer tangential slip (no flow into ground y = 0)
  if (y > -36) {
    float gFactor = constrain((y + 36) / 36.0, 0, 1);
    if (vy > 0) vy *= (1.0 - gFactor);
    // Slight ground friction + horizontal tangential spread
    vx *= (1.0 - 0.12 * gFactor);
    vz *= (1.0 - 0.12 * gFactor);
  }

  airVec.set(vx, vy, vz);
}

// Smooth Signed-Distance-Field (SDF) box boundary deflection:
// Eliminates normal velocity component V_n = (V . n) n near surface and converts
// pressure gradient into tangential velocity V_t = V - V_n along the wall!
void deflectAroundBox(
  float x, float y, float z,
  float minX, float maxX,
  float minY, float maxY,
  float minZ, float maxZ,
  float influenceDist,
  float strength,
  float vx, float vy, float vz
) {
  float cx = (minX + maxX) * 0.5;
  float cy = (minY + maxY) * 0.5;
  float cz = (minZ + maxZ) * 0.5;
  float hx = (maxX - minX) * 0.5;
  float hy = (maxY - minY) * 0.5;
  float hz = (maxZ - minZ) * 0.5;

  float dx = x - cx;
  float dy = y - cy;
  float dz = z - cz;

  float qx = abs(dx) - hx;
  float qy = abs(dy) - hy;
  float qz = abs(dz) - hz;

  float outX = max(qx, 0.0);
  float outY = max(qy, 0.0);
  float outZ = max(qz, 0.0);
  float outsideDist = sqrt(outX * outX + outY * outY + outZ * outZ);

  if (outsideDist < influenceDist) {
    // Compute outward surface normal n
    float nx = 0, ny = 0, nz = 0;
    if (outsideDist > 0.001) {
      nx = (dx >= 0 ? 1 : -1) * outX / outsideDist;
      ny = (dy >= 0 ? 1 : -1) * outY / outsideDist;
      nz = (dz >= 0 ? 1 : -1) * outZ / outsideDist;
    } else {
      // Inside box: push out along nearest face
      if (qx > qy && qx > qz) nx = (dx >= 0 ? 1 : -1);
      else if (qy > qz)       ny = (dy >= 0 ? 1 : -1);
      else                    nz = (dz >= 0 ? 1 : -1);
    }

    float proximity = 1.0 - (outsideDist / influenceDist);
    float w = strength * proximity * proximity;

    // Decompose V into Normal (Vn) and Tangential (Vt = V - Vn * n)
    float vn = vx * nx + vy * ny + vz * nz;
    float tx = vx - vn * nx;
    float ty = vy - vn * ny;
    float tz = vz - vn * nz;

    if (vn < 0) {
      // Windward stagnation & tangential redirection:
      // Cancel inward normal velocity so flow hugs the surface tangentially
      vx -= (1.08 * w) * vn * nx;
      vy -= (1.08 * w) * vn * ny;
      vz -= (1.08 * w) * vn * nz;

      // Boost tangential velocity along corners/roofs (Venturi conservation of mass)
      float tMag = sqrt(tx * tx + ty * ty + tz * tz);
      if (tMag > 0.02) {
        float venturiBoost = 0.34 * w * (1.0 - proximity * 0.45);
        vx += (tx / tMag) * venturiBoost;
        vy += (ty / tMag) * venturiBoost;
        vz += (tz / tMag) * venturiBoost;
      } else {
        // Direct stagnation point: deflect upward & around edges tangentially
        vy -= 0.42 * w;
        vz += (dz >= 0 ? 0.35 : -0.35) * w;
      }
    } else {
      // Leeward wake entrainment: gentle suction pulling flow tangentially inward
      vx -= 0.14 * w * nx;
      vy -= 0.14 * w * ny;
      vz -= 0.14 * w * nz;
    }
  }

  airVec.set(vx, vy, vz);
}

// Compute 3D Divergence (div V = dVx/dx + dVy/dy + dVz/dz) via central finite differences
// Negative div V => Fluid Compression (high pressure); Positive div V => Fluid Expansion
float computeDivergence(float x, float y, float z, float t) {
  float h = 12.0;

  computeAirVelocity(x + h, y, z, t); float vxp = airVec.x;
  computeAirVelocity(x - h, y, z, t); float vxm = airVec.x;
  float dVxdx = (vxp - vxm) / (2.0 * h);

  computeAirVelocity(x, y + h, z, t); float vyp = airVec.y;
  computeAirVelocity(x, y - h, z, t); float vym = airVec.y;
  float dVydy = (vyp - vym) / (2.0 * h);

  computeAirVelocity(x, y, z + h, t); float vzp = airVec.z;
  computeAirVelocity(x, y, z - h, t); float vzm = airVec.z;
  float dVzdz = (vzp - vzm) / (2.0 * h);

  return (dVxdx + dVydy + dVzdz) * airflowSpeed;
}

// Compute 3D Curl / Vorticity (omega = nabla x V) via central finite differences
void computeCurl(float x, float y, float z, float t) {
  float h = 14.0;

  computeAirVelocity(x, y + h, z, t); tempVel1.set(airVec);
  computeAirVelocity(x, y - h, z, t); tempVel2.set(airVec);
  float dVzdy = (tempVel1.z - tempVel2.z) / (2.0 * h);
  float dVxdy = (tempVel1.x - tempVel2.x) / (2.0 * h);

  computeAirVelocity(x, y, z + h, t); tempVel1.set(airVec);
  computeAirVelocity(x, y, z - h, t); tempVel2.set(airVec);
  float dVydz = (tempVel1.y - tempVel2.y) / (2.0 * h);
  float dVxdz = (tempVel1.x - tempVel2.x) / (2.0 * h);

  computeAirVelocity(x + h, y, z, t); tempVel1.set(airVec);
  computeAirVelocity(x - h, y, z, t); tempVel2.set(airVec);
  float dVzdx = (tempVel1.z - tempVel2.z) / (2.0 * h);
  float dVydx = (tempVel1.y - tempVel2.y) / (2.0 * h);

  // Curl = (dVz/dy - dVy/dz, dVx/dz - dVz/dx, dVy/dx - dVx/dy)
  curlVec.set(
    (dVzdy - dVydz) * airflowSpeed,
    (dVxdz - dVzdx) * airflowSpeed,
    (dVydx - dVxdy) * airflowSpeed
  );
}

boolean insideHouseCore(float x, float y, float z) {
  boolean inRightWing = (x > -35 && x < 340 && y > -295 && y < -5 && z > -155 && z < 130);
  boolean inTower     = (x > -350 && x < -248 && y > -272 && y < -5 && z > towerRearZ && z < 82);
  return inRightWing || inTower;
}

// ------------------------------------------------------------
// 1. VECTOR FIELD ARROWS (COLORED BY VELOCITY & PRESSURE)
// ------------------------------------------------------------

void drawAirflowField() {
  float t = frameNumber * 0.045 * max(0.1, airflowSpeed);

  for (float x = -440; x <= 440; x += 110) {
    for (float y = -370; y <= -50; y += 105) {
      for (float z = -250; z <= 350; z += 150) {
        if (insideHouseCore(x, y, z)) continue;

        computeAirVelocity(x, y, z, t);
        float mag = airVec.mag();
        if (mag < 0.05) continue;

        float arrowLen = constrain(24 + mag * 18 * (0.4 + airflowSpeed * 0.6), 16, 62);
        dirVec.set(airVec.x / mag, airVec.y / mag, airVec.z / mag);

        float ex = x + dirVec.x * arrowLen;
        float ey = y + dirVec.y * arrowLen;
        float ez = z + dirVec.z * arrowLen;

        int col = getVelocityPressureColor(mag);

        stroke(red(col), green(col), blue(col), 210);
        strokeWeight(2.0);
        line(x, y, z, ex, ey, ez);

        if (abs(dirVec.y) > 0.92) upRef.set(1, 0, 0);
        else                       upRef.set(0, 1, 0);

        PVector.cross(dirVec, upRef, side1);
        side1.normalize();
        PVector.cross(dirVec, side1, side2);
        side2.normalize();

        float headLen = 8.5;
        float headR = 3.8;
        float bx = ex - dirVec.x * headLen;
        float by = ey - dirVec.y * headLen;
        float bz = ez - dirVec.z * headLen;

        line(ex, ey, ez, bx + side1.x * headR, by + side1.y * headR, bz + side1.z * headR);
        line(ex, ey, ez, bx - side1.x * headR, by - side1.y * headR, bz - side1.z * headR);
        line(ex, ey, ez, bx + side2.x * headR, by + side2.y * headR, bz + side2.z * headR);
        line(ex, ey, ez, bx - side2.x * headR, by - side2.y * headR, bz - side2.z * headR);
      }
    }
  }
  noStroke();
}

// ------------------------------------------------------------
// 2. INSTANTANEOUS STREAMLINES (TANGENT TO VELOCITY FIELD AT t)
// ------------------------------------------------------------

void drawStreamlines() {
  float t = frameNumber * 0.045 * max(0.1, airflowSpeed);
  float[][] seeds = {
    {-460, -310, -140},
    {-460, -230,  -20},
    {-460, -150,   65},
    {-460,  -85,  145},
    {-460, -165,  215},
    {-460,  -55,  285},
    {-460, -280,   95},
    {-460, -110, -180}
  };

  strokeWeight(2.6);
  noFill();

  for (int s = 0; s < seeds.length; s++) {
    float sx = seeds[s][0];
    float sy = seeds[s][1];
    float sz = seeds[s][2];

    beginShape();
    for (int step = 0; step < 36; step++) {
      if (insideHouseCore(sx, sy, sz) || sx > 490 || sy > -4) break;

      computeAirVelocity(sx, sy, sz, t);
      float mag = airVec.mag();
      int col = getVelocityPressureColor(mag);
      stroke(red(col), green(col), blue(col), 220);
      vertex(sx, sy, sz);

      if (mag > 0.01) {
        sx += (airVec.x / mag) * 26.0;
        sy += (airVec.y / mag) * 26.0;
        sz += (airVec.z / mag) * 26.0;
      }
    }
    endShape();
  }
  noStroke();
}

// ------------------------------------------------------------
// 3. STREAKLINES (CONTINUOUS DYE FILAMENTS FROM FIXED NOZZLES)
// ------------------------------------------------------------

void drawStreaklines() {
  float t = frameNumber * 0.045 * max(0.1, airflowSpeed);

  // Emit a fresh dye particle per nozzle every 2 frames
  if (airflowSpeed > 0.02 && frameNumber % 2 == 0) {
    for (int n = 0; n < streakNozzles.length; n++) {
      streakParticles.add(new StreakParticle(
        n, streakNozzles[n][0], streakNozzles[n][1], streakNozzles[n][2]
      ));
    }
  }

  float dt = 6.2 * airflowSpeed;
  for (int i = streakParticles.size() - 1; i >= 0; i--) {
    StreakParticle sp = streakParticles.get(i);
    if (airflowSpeed > 0.01) {
      computeAirVelocity(sp.x, sp.y, sp.z, t);
      sp.x += airVec.x * dt;
      sp.y += airVec.y * dt;
      sp.z += airVec.z * dt;
      sp.age += 1.0;
    }
    if (sp.age > 95 || sp.x > 500 || insideHouseCore(sp.x, sp.y, sp.z)) {
      streakParticles.remove(i);
    }
  }

  // Draw glowing magenta-violet-gold dye ribbons connecting sequential emissions per nozzle
  strokeWeight(3.0);
  noFill();
  for (int n = 0; n < streakNozzles.length; n++) {
    // Draw small emitter nozzle sphere
    pushMatrix();
    translate(streakNozzles[n][0], streakNozzles[n][1], streakNozzles[n][2]);
    noStroke();
    fill(255, 90, 220);
    sphereDetail(6);
    sphere(4.5);
    popMatrix();

    beginShape();
    for (int i = 0; i < streakParticles.size(); i++) {
      StreakParticle sp = streakParticles.get(i);
      if (sp.nozzleIdx == n) {
        computeAirVelocity(sp.x, sp.y, sp.z, t);
        int speedCol = getVelocityPressureColor(airVec.mag());
        // Blend streakline magenta tint with velocity/pressure color
        int streakCol = lerpColor(0xFFFF40E0, speedCol, 0.55);
        float alpha = map(sp.age, 0, 95, 240, 20);
        stroke(red(streakCol), green(streakCol), blue(streakCol), alpha);
        vertex(sp.x, sp.y, sp.z);
      }
    }
    endShape();
  }
  noStroke();
}

// ------------------------------------------------------------
// 4. PATHLINES (LAGRANGIAN TRAJECTORIES OF INDIVIDUAL PARCELS)
// ------------------------------------------------------------

void drawPathlines() {
  float t = frameNumber * 0.045 * max(0.1, airflowSpeed);
  float dt = 6.0 * airflowSpeed;

  for (int i = 0; i < pathParticles.size(); i++) {
    PathParticle pp = pathParticles.get(i);

    if (airflowSpeed > 0.01) {
      computeAirVelocity(pp.x, pp.y, pp.z, t);
      float mag = airVec.mag();

      pp.trail.add(new PVector(pp.x, pp.y, pp.z));
      pp.speeds.add(mag);
      if (pp.trail.size() > 28) {
        pp.trail.remove(0);
        pp.speeds.remove(0);
      }

      pp.x += airVec.x * dt;
      pp.y += airVec.y * dt;
      pp.z += airVec.z * dt;
      pp.life -= 0.006 * max(0.4, airflowSpeed);
    }

    if (pp.x > 500 || pp.z < -330 || pp.y < -440 || pp.life <= 0 || insideHouseCore(pp.x, pp.y, pp.z)) {
      pp.respawn();
      continue;
    }

    // Draw historical pathline curve
    strokeWeight(2.2);
    noFill();
    beginShape();
    for (int k = 0; k < pp.trail.size(); k++) {
      PVector pt = pp.trail.get(k);
      float spd = pp.speeds.get(k);
      int col = getVelocityPressureColor(spd);
      float fade = map(k, 0, pp.trail.size(), 35, 235);
      stroke(red(col), green(col), blue(col), fade);
      vertex(pt.x, pt.y, pt.z);
    }
    endShape();

    // Draw leading tracer bead
    pushMatrix();
    translate(pp.x, pp.y, pp.z);
    noStroke();
    fill(WHITE);
    sphereDetail(6);
    sphere(3.2);
    popMatrix();
  }
  noStroke();
}

// ------------------------------------------------------------
// 5. DIVERGENCE VISUALIZATION: DEFORMING TRANSPARENT CUBOIDS
//    (Compresses in high-pressure convergence, expands in divergence)
// ------------------------------------------------------------

void drawDivergenceCuboids() {
  float t = frameNumber * 0.045 * max(0.1, airflowSpeed);
  float dt = 4.6 * airflowSpeed;

  for (int i = 0; i < fluidParcels.size(); i++) {
    FluidParcel fp = fluidParcels.get(i);

    computeAirVelocity(fp.x, fp.y, fp.z, t);
    float vx = airVec.x;
    float vy = airVec.y;
    float vz = airVec.z;

    // Directional velocity gradients (dVx/dx, dVy/dy, dVz/dz) deform the cuboid axes
    float h = 14.0;
    computeAirVelocity(fp.x + h, fp.y, fp.z, t); float dVxdx = (airVec.x - vx) / h;
    computeAirVelocity(fp.x, fp.y + h, fp.z, t); float dVydy = (airVec.y - vy) / h;
    computeAirVelocity(fp.x, fp.y, fp.z + h, t); float dVzdz = (airVec.z - vz) / h;

    float div = (dVxdx + dVydy + dVzdz) * airflowSpeed;

    if (airflowSpeed > 0.01) {
      // Integrate strain rate tensor diagonal to compress/expand cuboid dimensions
      fp.scaleX = constrain(fp.scaleX * (1.0 + dVxdx * dt * 1.4), 0.42, 1.95);
      fp.scaleY = constrain(fp.scaleY * (1.0 + dVydy * dt * 1.4), 0.42, 1.95);
      fp.scaleZ = constrain(fp.scaleZ * (1.0 + dVzdz * dt * 1.4), 0.42, 1.95);

      fp.x += vx * dt;
      fp.y += vy * dt;
      fp.z += vz * dt;
      fp.life -= 0.005 * max(0.4, airflowSpeed);
    }

    if (fp.x > 490 || fp.z < -310 || fp.y < -430 || fp.life <= 0 || insideHouseCore(fp.x, fp.y, fp.z)) {
      fp.respawn(false);
      continue;
    }

    // Color by Divergence:
    // div < 0 (Compression / High Pressure Convergence) => Deep Royal Blue / Cyan
    // div ~ 0 (Incompressible Isovolumetric)          => Emerald / Teal
    // div > 0 (Expansion / Rarefaction)               => Warm Orange / Crimson
    float divNorm = constrain(div * 22.0, -1.0, 1.0);
    int fillCol;
    if (divNorm < 0) {
      fillCol = lerpColor(0xFF00D4AA, 0xFF1A5CFF, -divNorm);
    } else {
      fillCol = lerpColor(0xFF00D4AA, 0xFFFF4518, divNorm);
    }

    float w = fp.baseW * fp.scaleX;
    float bh = fp.baseH * fp.scaleY;
    float d = fp.baseD * fp.scaleZ;

    pushMatrix();
    translate(fp.x, fp.y, fp.z);

    // Subtle shear tilt aligned with velocity direction
    float yawTilt = atan2(-vz, max(0.2, vx)) * 0.35;
    float pitchTilt = atan2(vy, max(0.2, vx)) * 0.35;
    rotateY(yawTilt);
    rotateZ(pitchTilt);

    // Semi-transparent cuboid body
    fill(red(fillCol), green(fillCol), blue(fillCol), 72);
    stroke(red(fillCol), green(fillCol), blue(fillCol), 220);
    strokeWeight(1.5);
    box(w, bh, d);

    // Inner core marker dot
    noStroke();
    fill(WHITE, 180);
    sphereDetail(5);
    sphere(2.2);

    popMatrix();
  }
  noStroke();
}

// ------------------------------------------------------------
// 6. CURL VISUALIZATION: TINY ROTATING 3D PADDLE WHEELS
//    Angular velocity omega = 0.5 * (nabla x V)
// ------------------------------------------------------------

void drawCurlPaddles() {
  float t = frameNumber * 0.045 * max(0.1, airflowSpeed);

  for (int i = 0; i < curlPaddles.size(); i++) {
    CurlPaddle cp = curlPaddles.get(i);

    computeCurl(cp.x, cp.y, cp.z, t);
    cp.curlX = curlVec.x;
    cp.curlY = curlVec.y;
    cp.curlZ = curlVec.z;
    cp.curlMag = curlVec.mag();

    // Rotate paddle wheel proportional to local curl magnitude
    float angularVel = cp.curlMag * 16.0 * airflowSpeed;
    cp.angle += constrain(angularVel, 0.02, 0.45) * (airflowSpeed > 0.01 ? 1.0 : 0.0);

    pushMatrix();
    translate(cp.x, cp.y, cp.z);

    // Align paddle axle along the local vorticity (curl) vector!
    if (cp.curlMag > 0.0005) {
      PVector axis = new PVector(cp.curlX, cp.curlY, cp.curlZ);
      axis.normalize();
      // Default axle is Z (0,0,1); rotate Z to align with curl axis
      PVector zAxis = new PVector(0, 0, 1);
      PVector rotAxis = zAxis.cross(axis);
      float dot = constrain(zAxis.dot(axis), -1.0, 1.0);
      float rotAngle = acos(dot);
      if (rotAxis.mag() > 0.001) {
        rotAxis.normalize();
        rotate(rotAngle, rotAxis.x, rotAxis.y, rotAxis.z);
      }
    }

    // Draw vorticity axis spindle (Gold)
    noStroke();
    fill(GOLD);
    box(2.5, 2.5, 28);
    // Arrow tip showing right-hand rule curl vector direction
    pushMatrix();
    translate(0, 0, 16);
    sphereDetail(6);
    sphere(3.5);
    popMatrix();

    // Rotate the 4 paddle blades around the vorticity axis
    rotateZ(cp.angle);

    int bladeCol = lerpColor(0xFF38F2FF, 0xFFFF4D2E, constrain(cp.curlMag * 120.0, 0, 1));
    fill(bladeCol);
    stroke(WHITE, 180);
    strokeWeight(1.0);

    // 4 orthogonal paddle blades
    for (int b = 0; b < 4; b++) {
      pushMatrix();
      rotateZ(b * HALF_PI);
      translate(10, 0, 0);
      box(14, 2.2, 12);
      popMatrix();
    }

    // Central hub
    noStroke();
    fill(WHITE);
    sphereDetail(6);
    sphere(4.0);

    popMatrix();
  }
  noStroke();
}

// ============================================================
// HUD & SIDE-BY-SIDE INTERACTIVE CONTROLS
// ============================================================

float panelW() {
  return min(326, width * 0.49);
}

float panelH() {
  return min(432, height - 20);
}

void drawMiniHudToggle() {
  hint(DISABLE_DEPTH_TEST);
  camera();
  noLights();

  fill(12, 22, 36, 220);
  stroke(GOLD);
  strokeWeight(1.3);
  rect(12, 12, 64, 26, 8);

  noStroke();
  fill(255, 221, 157);
  textAlign(CENTER, CENTER);
  textSize(10);
  text("HUD", 44, 25);

  hint(ENABLE_DEPTH_TEST);
}

void drawHUD() {
  hint(DISABLE_DEPTH_TEST);
  camera();
  noLights();

  float x = 12;
  float y = 12;
  float w = panelW();
  float h = panelH();

  noStroke();
  fill(12, 22, 36, 236);
  rect(x, y, w, h, 12);

  stroke(GOLD);
  strokeWeight(1.5);
  noFill();
  rect(x, y, w, h, 12);
  noStroke();

  // Header
  fill(255, 221, 157);
  textAlign(LEFT, TOP);
  textSize(12.5);
  text("TAMIL HOUSE 3D + CFD AIRFLOW", x + 12, y + 8);

  fill(205, 220, 235);
  textSize(8.0);
  text("PRESSURE/SPEED: BLUE(HIGH P) -> YELLOW -> RED(HIGH V)", x + 12, y + 23);

  // Small touch Hide HUD pill
  fill(35, 50, 68);
  stroke(130, 155, 175);
  strokeWeight(1);
  rect(x + w - 48, y + 8, 36, 17, 5);
  noStroke();
  fill(WHITE);
  textAlign(CENTER, CENTER);
  textSize(8.5);
  text("HIDE", x + w - 30, y + 16.5);

  // Side-by-side slider columns (3 rows x 2 columns)
  float sw = (w - 34) / 2.0;
  float col1X = x + 12;
  float col2X = x + 22 + sw;

  drawSlider("BRIGHTNESS", lampBrightness, 0.0, 1.2, col1X, y + 38, sw);
  drawSlider("DENSITY",    lampDensity,    0.1, 1.0, col2X, y + 38, sw);

  drawSlider("FLAME SPD",  flameSpeed,     0.0, 0.4, col1X, y + 75, sw);
  drawSlider("AIRFLOW",    airflowSpeed,   0.0, 2.0, col2X, y + 75, sw);

  float sideDepthLen = 79.0 - towerRearZ;
  float frontWallLen = -65.0 - leftWallStartX;
  drawSlider("SIDE DEPTH", sideDepthLen, 219.0, 339.0, col1X, y + 112, sw);
  drawSlider("FRONT WALL", frontWallLen, 275.0, 475.0, col2X, y + 112, sw);

  // Lamp zone buttons (2x2)
  fill(255, 220, 150);
  textAlign(LEFT, TOP);
  textSize(8.5);
  text("LAMP ZONES", x + 12, y + 150);

  float bw = (w - 30) / 2.0;
  float bh = 22;

  for (int i = 0; i < 4; i++) {
    float bx = x + 12 + (i % 2) * (bw + 6);
    float by = y + 163 + (i / 2) * 26;

    if (zones[i]) {
      fill(204, 139, 57);
      stroke(255, 220, 150);
    } else {
      fill(48, 58, 73);
      stroke(100, 115, 130);
    }
    strokeWeight(1.1);
    rect(bx, by, bw, bh, 5);

    noStroke();
    fill(WHITE);
    textAlign(CENTER, CENTER);
    textSize(9.0);
    text(zoneNames[i], bx + bw * 0.5, by + bh * 0.5);
  }

  // Fluid Dynamics Visualization Toggles (3 rows x 2 columns)
  fill(135, 240, 255);
  textAlign(LEFT, TOP);
  textSize(8.5);
  text("FLUID DYNAMICS & VORTICITY CONTROLS", x + 12, y + 219);

  float fbh = 23;
  float fy0 = y + 232;

  // Row A: Vector Field | Streamlines
  drawToggleBtn("VECTORS: " + (showAirflow ? "ON" : "OFF"), showAirflow, x + 12, fy0, bw, fbh, 0xFF1F7A8C);
  drawToggleBtn("STREAMLINES: " + (showStreamlines ? "ON" : "OFF"), showStreamlines, x + 18 + bw, fy0, bw, fbh, 0xFF1F7A8C);

  // Row B: Streaklines | Pathlines
  drawToggleBtn("STREAKLINES: " + (showStreaklines ? "ON" : "OFF"), showStreaklines, x + 12, fy0 + 27, bw, fbh, 0xFF7B2CBF);
  drawToggleBtn("PATHLINES: " + (showPathlines ? "ON" : "OFF"), showPathlines, x + 18 + bw, fy0 + 27, bw, fbh, 0xFF2B6CB0);

  // Row C: Divergence Cuboids | Curl Paddles
  drawToggleBtn("DIVERGENCE: " + (showDivergence ? "ON" : "OFF"), showDivergence, x + 12, fy0 + 54, bw, fbh, 0xFF0F766E);
  drawToggleBtn("CURL PADDLES: " + (showCurlPaddles ? "ON" : "OFF"), showCurlPaddles, x + 18 + bw, fy0 + 54, bw, fbh, 0xFFB45309);

  // Scene & Camera Controls
  float cy0 = fy0 + 84;
  drawToggleBtn(nightMode ? "DAY VIEW" : "NIGHT VIEW", !nightMode, x + 12, cy0, bw, fbh, 0xFF334E68);
  drawToggleBtn(backsideView ? "FRONT VIEW" : "BACKSIDE VIEW", backsideView, x + 18 + bw, cy0, bw, fbh, 0xFF9C5A25);

  drawToggleBtn("RESET ALL", false, x + 12, cy0 + 27, w - 24, fbh, 0xFF3B4D5E);

  // Footer tips
  fill(190, 205, 222);
  textAlign(LEFT, TOP);
  textSize(7.8);
  text("Drag outside HUD to orbit | +/-: Zoom | H: Hide HUD", x + 12, y + 399);
  text("Keys: V=Vec S=Stream K=Streak P=Path D=Div C=Curl", x + 12, y + 411);

  hint(ENABLE_DEPTH_TEST);
}

void drawToggleBtn(String label, boolean active, float bx, float by, float bw, float bh, int activeCol) {
  if (active) {
    fill(activeCol);
    stroke(170, 240, 255);
  } else {
    fill(42, 54, 68);
    stroke(105, 125, 145);
  }
  strokeWeight(1.1);
  rect(bx, by, bw, bh, 5);
  noStroke();
  fill(WHITE);
  textAlign(CENTER, CENTER);
  textSize(8.6);
  text(label, bx + bw * 0.5, by + bh * 0.5);
}

void drawSlider(
  String label,
  float value,
  float minValue,
  float maxValue,
  float x, float y, float w
) {
  float n = constrain((value - minValue) / (maxValue - minValue), 0, 1);

  fill(235, 239, 245);
  textAlign(LEFT, TOP);
  textSize(8.2);
  text(label + " " + nf(n * 100, 0, 0) + "%", x, y);

  float ty = y + 17;

  stroke(80, 100, 120);
  strokeWeight(4.0);
  line(x, ty, x + w, ty);

  stroke(GOLD);
  line(x, ty, x + w * n, ty);

  noStroke();
  fill(255, 226, 151);
  ellipse(x + w * n, ty, 10, 10);
}

// ============================================================
// TOUCH AND MOUSE CONTROLS
// ============================================================

void mousePressed() {
  previousMouseX = mouseX;
  previousMouseY = mouseY;
  selectedSlider = -1;

  if (!showHUD) {
    if (mouseX >= 12 && mouseX <= 76 && mouseY >= 12 && mouseY <= 38) {
      showHUD = true;
    }
    return;
  }

  float x = 12;
  float y = 12;
  float w = panelW();
  float h = panelH();

  if (mouseX < x || mouseX > x + w || mouseY < y || mouseY > y + h) {
    return;
  }

  // Hide HUD button
  if (mouseX >= x + w - 48 && mouseX <= x + w - 12 &&
      mouseY >= y + 8 && mouseY <= y + 25) {
    showHUD = false;
    return;
  }

  // Six side-by-side slider tracks (3 rows x 2 columns)
  float sw = (w - 34) / 2.0;
  float col1X = x + 12;
  float col2X = x + 22 + sw;
  float[] rowTracks = { y + 55, y + 92, y + 129 };

  for (int row = 0; row < 3; row++) {
    if (abs(mouseY - rowTracks[row]) < 14) {
      if (mouseX >= col1X - 6 && mouseX <= col1X + sw + 6) {
        selectedSlider = row * 2;
        updateSlider(selectedSlider, col1X, sw);
        return;
      }
      if (mouseX >= col2X - 6 && mouseX <= col2X + sw + 6) {
        selectedSlider = row * 2 + 1;
        updateSlider(selectedSlider, col2X, sw);
        return;
      }
    }
  }

  // Zone buttons
  float bw = (w - 30) / 2.0;
  float bh = 22;
  for (int i = 0; i < 4; i++) {
    float bx = x + 12 + (i % 2) * (bw + 6);
    float by = y + 163 + (i / 2) * 26;
    if (mouseX >= bx && mouseX <= bx + bw &&
        mouseY >= by && mouseY <= by + bh) {
      zones[i] = !zones[i];
      return;
    }
  }

  // Fluid Dynamics Toggles
  float fbh = 23;
  float fy0 = y + 232;

  // Row A: Vectors | Streamlines
  if (mouseY >= fy0 && mouseY <= fy0 + fbh) {
    if (mouseX >= x + 12 && mouseX <= x + 12 + bw) { showAirflow = !showAirflow; return; }
    if (mouseX >= x + 18 + bw && mouseX <= x + 18 + bw * 2) { showStreamlines = !showStreamlines; return; }
  }
  // Row B: Streaklines | Pathlines
  if (mouseY >= fy0 + 27 && mouseY <= fy0 + 27 + fbh) {
    if (mouseX >= x + 12 && mouseX <= x + 12 + bw) { showStreaklines = !showStreaklines; return; }
    if (mouseX >= x + 18 + bw && mouseX <= x + 18 + bw * 2) { showPathlines = !showPathlines; return; }
  }
  // Row C: Divergence Cuboids | Curl Paddles
  if (mouseY >= fy0 + 54 && mouseY <= fy0 + 54 + fbh) {
    if (mouseX >= x + 12 && mouseX <= x + 12 + bw) { showDivergence = !showDivergence; return; }
    if (mouseX >= x + 18 + bw && mouseX <= x + 18 + bw * 2) { showCurlPaddles = !showCurlPaddles; return; }
  }

  // Scene & Camera Controls
  float cy0 = fy0 + 84;
  if (mouseY >= cy0 && mouseY <= cy0 + fbh) {
    if (mouseX >= x + 12 && mouseX <= x + 12 + bw) { nightMode = !nightMode; return; }
    if (mouseX >= x + 18 + bw && mouseX <= x + 18 + bw * 2) { toggleBacksideView(); return; }
  }
  if (mouseY >= cy0 + 27 && mouseY <= cy0 + 27 + fbh) {
    if (mouseX >= x + 12 && mouseX <= x + w - 12) { resetCamera(); return; }
  }
}

void mouseDragged() {
  if (selectedSlider != -1) {
    float w = panelW();
    float sw = (w - 34) / 2.0;
    float sx = (selectedSlider % 2 == 0) ? (12 + 12) : (12 + 22 + sw);
    updateSlider(selectedSlider, sx, sw);
  } else if (!showHUD || mouseX > panelW() + 20 || mouseY > panelH() + 20) {
    targetYaw += (mouseX - previousMouseX) * 0.006;
    targetPitch = constrain(
      targetPitch + (mouseY - previousMouseY) * 0.004,
      -0.12,
      0.55
    );
    cameraYaw = targetYaw;
    cameraPitch = targetPitch;
  }

  previousMouseX = mouseX;
  previousMouseY = mouseY;
}

void mouseReleased() {
  selectedSlider = -1;
}

void updateSlider(int id, float x, float w) {
  float n = constrain((mouseX - x) / w, 0, 1);
  if (id == 0) lampBrightness = lerp(0.0, 1.2, n);
  if (id == 1) lampDensity    = lerp(0.1, 1.0, n);
  if (id == 2) flameSpeed     = lerp(0.0, 0.4, n);
  if (id == 3) airflowSpeed   = lerp(0.0, 2.0, n);
  if (id == 4) {
    towerRearZ = lerp(-140.0, -260.0, n);
  }
  if (id == 5) {
    leftWallStartX = lerp(-340.0, -540.0, n);
    createLamps();
  }
}

void toggleBacksideView() {
  backsideView = !backsideView;
  if (backsideView) {
    targetYaw   = PI - 0.12;
    targetPitch = 0.14;
    targetZoom  = 1.0;
  } else {
    targetYaw   = -0.08;
    targetPitch = 0.10;
    targetZoom  = 1.0;
  }
}

void resetCamera() {
  backsideView   = false;
  towerRearZ     = -185.0;
  leftWallStartX = -480.0;
  createLamps();
  createFluidVisualizations();
  targetYaw   = -0.08;
  targetPitch = 0.10;
  targetZoom  = 1.0;
}

void mouseWheel(processing.event.MouseEvent event) {
  // Intentionally empty for APDE compatibility.
}

void keyPressed() {
  if (key == 'h' || key == 'H') showHUD = !showHUD;
  if (key == 'r' || key == 'R') resetCamera();
  if (key == 'n' || key == 'N') nightMode = !nightMode;
  if (key == 'v' || key == 'V') showAirflow = !showAirflow;
  if (key == 's' || key == 'S') showStreamlines = !showStreamlines;
  if (key == 'k' || key == 'K') showStreaklines = !showStreaklines;
  if (key == 'p' || key == 'P') showPathlines = !showPathlines;
  if (key == 'd' || key == 'D') showDivergence = !showDivergence;
  if (key == 'c' || key == 'C') showCurlPaddles = !showCurlPaddles;
  if (key == 'b' || key == 'B') toggleBacksideView();
  if (key == '+' || key == '=') targetZoom = min(1.80, targetZoom + 0.1);
  if (key == '-')                targetZoom = max(0.55, targetZoom - 0.1);
}

// ============================================================
// END OF COMPLETE REFERENCE HOUSE + 3D CFD SKETCH
// ============================================================
