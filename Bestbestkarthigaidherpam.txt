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
// 11. Real-time 3D Airflow Vector Field toggle & speed slider + flame coupling
// 12. Side-by-side HUD sliders including SIDE DEPTH (-Z) & FRONT WALL LEN (X)
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

// ---------------- LAMP, TRACER & STAR CLASSES -----------

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
ArrayList<SkyStar> stars = new ArrayList<SkyStar>();

// Reusable vectors to avoid per-frame GC allocation on APDE
PVector airVec = new PVector();
PVector dirVec = new PVector();
PVector side1  = new PVector();
PVector side2  = new PVector();
PVector upRef  = new PVector();

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

// New interactive dimension sliders (black-marked side depth & front wall length)
float towerRearZ     = -185.0; // Rear Z of left tower (-260 to -140)
float leftWallStartX = -480.0; // Left end X of front compound wall (-540 to -340)

boolean[] zones = {true, true, true, true};
String[] zoneNames = {
  "ROOF", "BALCONY", "COMPOUND", "GROUND"
};

boolean nightMode    = true;
boolean showAirflow  = false;
boolean backsideView = false;
boolean showHUD      = true;

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
    // Subtle cool moonlight fill from the backside (-Z)
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

  if (showAirflow) {
    noLights();
    drawAirflowField();
  }

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

  // Main property soil (top at y = 0)
  boxAt(soilCX, 10, 30, soilW, 20, 860, SOIL);

  // Paved road in front (top at y = 8)
  boxAt(soilCX, 13, 475, soilW + 180, 10, 180, ROAD);

  // Front garden curb strip dynamically matching front wall length
  float curbLeftX = leftWallStartX - 40;
  float curbRightX = 540;
  boxAt((curbLeftX + curbRightX) * 0.5, 4, 342, curbRightX - curbLeftX, 8, 66, CREAM_DARK);

  // Main vehicle entrance courtyard (tiled)
  boxAt(110, 0, 248, 355, 4, 235, TILE);

  // Left pedestrian entrance path (tiled)
  boxAt(-40, 0, 230, 78, 4, 210, TILE);

  // Tiled entrance walkway leading from the left tower door steps
  boxAt(-300, 0, 196, 92, 4, 152, TILE);

  // Rear backyard paved apron for Backside View
  boxAt(110, 0, -210, 420, 4, 110, CREAM_DARK);

  // Courtyard tile joints
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

// ============================================================
// MAIN GROUND-FLOOR BUILDING (RIGHT WING)
// ============================================================

void drawMainGroundBuilding() {
  // Main lower-storey core (x = -40..340, y = -136..0, z = -159..115)
  boxAt(150, -68, -22, 380, 136, 274, CREAM);

  // Right ground-floor dark teal architectural block
  boxAt(258, -68, 117, 164, 136, 8, TEAL);

  // Lower ground plinth
  boxAt(150, 2, -22, 396, 8, 290, CREAM_DARK);

  // Right side teal return trim
  boxAt(342, -68, 45, 5, 136, 150, TEAL);
}

// ============================================================
// LEFT DECORATIVE TOWER (ADJUSTABLE SIDE DEPTH + 3 STEPS)
// ============================================================

void drawLeftTower() {
  float frontZ = 79.0;
  float depthZ = frontZ - towerRearZ;
  float centerZ = (frontZ + towerRearZ) * 0.5;

  // Narrow tower mass: x = [-350, -250], y = [-270, 0], z = [towerRearZ, +79]
  boxAt(-300, -135, centerZ, 100, 270, depthZ, CREAM);

  // Bottom plinth & mid horizontal cornice
  boxAt(-300, -4,   centerZ, 108, 8, depthZ + 8,  CREAM_DARK);
  boxAt(-300, -124, centerZ, 110, 8, depthZ + 10, CREAM_LIGHT);

  // Top cornice (top surface y = -277, front edge z = +85)
  boxAt(-300, -272, centerZ, 112, 10, depthZ + 12, CREAM_LIGHT);

  // Ground-floor dark teal/green tower door (bottom at y = -18, z = +80)
  drawDoor(-300, -64, 80, 48, 92, TEAL_DARK);

  // Three crisp steps below the left tower door (y = -18 down to 0, stepping forward +Z)
  boxAt(-300, -15, 86,  60, 6, 14, CREAM_LIGHT);
  boxAt(-300, -9,  93,  68, 6, 28, CREAM_DARK);
  boxAt(-300, -3,  100, 76, 6, 42, CREAM_LIGHT);

  // Upper decorative teal panel framing the two lattice bays
  boxAt(-300, -197, 80, 90, 132, 6, TEAL);

  // Two stacked ornamental square compartments (4 cream blocks + central 3x3 lattice)
  drawTowerLatticeBay(-300, -229, 84);
  drawTowerLatticeBay(-300, -165, 84);

  // Left tower side cornice band
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

// ============================================================
// UPPER FLOOR, DARK TEAL FACADE & RAISED ROOF PARAPET
// ============================================================

void drawUpperBuilding() {
  // Upper-floor cream main mass (x = -30..340, y = -295..-135, z = -153..117)
  boxAt(155, -215, -18, 370, 160, 270, CREAM);

  // Upper recessed terrace back wall behind left canopy (x = -250..-30, z = 10)
  boxAt(-140, -210, 10, 220, 120, 14, CREAM);

  // Upper terrace dark door at left end beside the tower
  drawDoor(-222, -198, 18, 38, 86, TEAL_DARK);

  // Large upper dark teal front block on right side
  boxAt(250, -215, 119, 180, 158, 10, TEAL);

  // Raised dark teal roof parapet box (x = 136..340, y = -366..-298)
  boxAt(238, -333, -10, 204, 66, 266, TEAL);

  // Front face & cream coping of raised parapet (top at y = -372)
  boxAt(238, -368, -10, 212, 8, 276, CREAM_LIGHT);

  // Left cream side return of roof parapet
  boxAt(134, -333, -10, 8, 66, 266, CREAM);

  // Large glowing peaked-cap diamond lattice centered on upper parapet
  drawPeakedDiamond(238, -333, 126, 33, CREAM_LIGHT, TEAL_DARK, true);
}

// ============================================================
// CORRUGATED METAL TERRACE CANOPY
// ============================================================

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

// ============================================================
// EXTERNAL STAIRCASE ON LEFT (SLOPING DOWN-RIGHT)
// ============================================================

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

// ============================================================
// GROUND-FLOOR VERANDA, COLUMNS & UTILITY DETAILS
// ============================================================

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

  // Main house entrance door inside veranda + 3 steps
  drawDoor(95, -64, 117, 52, 92, TEAL_DARK);
  boxAt(95, -15, 122, 62, 6, 14, CREAM_LIGHT);
  boxAt(95, -9,  129, 70, 6, 28, CREAM_DARK);
  boxAt(95, -3,  136, 78, 6, 42, CREAM_LIGHT);

  // White electrical utility meter box on right dark-teal facade
  boxAt(205, -62, 122, 34, 48, 5, CREAM_LIGHT);
  boxAt(205, -62, 125, 28, 42, 2, CREAM_DARK);

  // Large 6-pane white-framed window on right dark-teal facade
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

// ============================================================
// CHAMFERED BALCONY WITH PEAKED-CAP DIAMOND GRILLES
// ============================================================

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

// ============================================================
// PEAKED-CAP DIAMOND LATTICE GRILLE
// ============================================================

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

// ============================================================
// ROOF OVERHANG & SIDE / REAR ELEVATION DETAILS
// ============================================================

void drawRoofDetails() {
  boxAt(165, -296, -10, 396, 10, 296, CREAM_LIGHT);
  boxAt(165, -289, -10, 392, 5, 292, TEAL_DARK);
  boxAt(342, -215, 45, 5, 160, 150, CREAM_LIGHT);
}

void drawRearAndSideDetails() {
  float towerMidZ = (79.0 + towerRearZ) * 0.5;

  // Left wing side window centered along adjustable tower side depth (-X face)
  pushMatrix();
  translate(-351, -68, towerMidZ - 15);
  rotateY(-HALF_PI);
  drawWindow(0, 0, 0, 52, 58, GLASS, false);
  popMatrix();

  // Right side windows (ground & upper)
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

  // ---- REAR ELEVATION DETAILS (-Z face for Backside View) ----
  boxAt(250, -215, -155, 160, 158, 6, TEAL);
  boxAt(250, -68, -161, 160, 136, 6, TEAL);

  // Rear ground-floor back door + 3 steps stepping backward (-Z)
  pushMatrix();
  translate(115, -64, -161);
  rotateY(PI);
  drawDoor(0, 0, 0, 48, 92, TEAL_DARK);
  popMatrix();
  boxAt(115, -15, -166, 62, 6, 14, CREAM_LIGHT);
  boxAt(115, -9,  -173, 70, 6, 28, CREAM_DARK);
  boxAt(115, -3,  -180, 78, 6, 42, CREAM_LIGHT);

  // Rear ground-floor windows
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

  // Rear upper windows
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

  // Rear upper terrace open parapet overlooking backyard
  boxAt(-140, -174, -142, 210, 38, 8, CREAM);
  boxAt(-140, -195, -142, 214, 5, 12, CREAM_LIGHT);

  // Rear AC outdoor condenser unit mounted on upper rear wall
  boxAt(-52, -225, -162, 34, 24, 14, CREAM_LIGHT);
  boxAt(-58, -225, -170, 16, 16, 3, ROOF);

  // Rear left tower ventilation window (tracks adjustable towerRearZ)
  pushMatrix();
  translate(-300, -195, towerRearZ - 2);
  rotateY(PI);
  drawWindow(0, 0, 0, 34, 42, GLASS_GREEN, false);
  popMatrix();
}

// ============================================================
// CURVED COMPOUND WALLS (ADJUSTABLE FRONT WALL LENGTH), PILLARS & GATES
// ============================================================

void drawCompoundWalls() {
  // Left double-wave curved compound wall spanning [leftWallStartX .. -65]
  float midPillarX = (leftWallStartX - 65.0) * 0.5;
  drawCurvedWall(leftWallStartX, midPillarX, 285, 0, 62, 18);
  boxAt(midPillarX, -36, 285, 16, 72, 20, CREAM_LIGHT);
  drawCurvedWall(midPillarX, -65, 285, 0, 62, 18);

  // Short middle wall between pedestrian & vehicle gates (x = -15..60)
  drawCurvedWall(-15, 60, 285, 0, 62, 11);
  // Wall-mounted gate lamp / letterbox
  boxAt(22, -46, 296, 10, 12, 6, BLACK);

  // Right curved wall (x = 195..480)
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
  // Left flowering bougainvillea shrubs along adjustable front compound wall
  int idx = 0;
  for (float x = leftWallStartX + 25; x <= -85; x += 44) {
    drawShrub(x, 0, 260, 0.85 + (idx % 3) * 0.12);
    drawFlower(x - 10, -14, 268, idx);
    drawFlower(x + 12, -10, 266, idx + 1);
    idx++;
  }

  // Right garden shrubs
  for (int i = 0; i < 6; i++) {
    float x = 225 + i * 45;
    drawShrub(x, 0, 260, 0.90 + (i % 2) * 0.15);
    drawFlower(x, -12, 268, i + 2);
  }

  // Rear yard shrubs for Backside View
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

  // ZONE 0: ROOF, MOVED-BACK TOWER CORNICE, CANOPY & UPPER PARAPET
  for (float x = -345; x <= -255; x += 22) {
    addLamp(x, -277, 82, 0);
  }
  for (float x = -235; x <= 50; x += 24) {
    addLamp(x, -276, 87, 0);
  }
  for (float x = -25; x <= 355; x += 24) {
    addLamp(x, -301, 134, 0);
  }
  for (float z = -140; z <= 120; z += 26) {
    addLamp(-28, -301, z, 0);
  }
  for (float x = 140; x <= 335; x += 24) {
    addLamp(x, -372, 125, 0);
  }
  for (float z = -125; z <= 115; z += 26) {
    addLamp(136, -372, z, 0);
  }

  // ZONE 1: BALCONY (UPPER COPING + LOWER LEDGE + STAIRCASE COPING)
  for (float x = 14; x <= 340; x += 22) {
    if (abs(x - 72) < 12 || abs(x - 178) < 12 || abs(x - 284) < 12) continue;
    addLamp(x, -196, 212, 1);
  }
  for (int i = 0; i <= 3; i++) {
    float t = i / 3.0;
    addLamp(lerp(-42, 6, t), -196, lerp(160, 208, t), 1);
  }
  for (float x = 12; x <= 342; x += 22) {
    addLamp(x, -135, 214, 1);
  }
  for (int i = 0; i <= 3; i++) {
    float t = i / 3.0;
    addLamp(lerp(-44, 6, t), -135, lerp(160, 210, t), 1);
  }
  for (float x = -245; x <= -160; x += 21) {
    addLamp(x, -186.5, 100, 1);
  }
  for (int i = 1; i <= 8; i++) {
    float t = i / 8.5;
    addLamp(lerp(-155, -20, t), lerp(-186, -12, t), 100, 1);
  }

  // ZONE 2: COMPOUND WALLS & ENTRANCE PILLARS (DYNAMIC WITH FRONT WALL LENGTH)
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

  // ZONE 3: GROUND CURB, KOLAM ENTRANCE & REAR BACKYARD
  for (float x = leftWallStartX + 20; x <= -75; x += 46) {
    addLamp(x, 0, 322, 3);
  }
  for (float x = 205; x <= 455; x += 46) {
    addLamp(x, 0, 322, 3);
  }
  float kx = 128;
  float kz = 365;
  for (float a = 0; a < TWO_PI; a += PI / 6.0) {
    addLamp(kx + cos(a) * 62, 0, kz + sin(a) * 38, 3);
  }
  for (float a = 0; a < TWO_PI; a += PI / 4.0) {
    addLamp(kx + cos(a) * 34, 0, kz + sin(a) * 21, 3);
  }
  addLamp(kx, 0, kz, 3);

  for (float x = -80; x <= 290; x += 46) {
    addLamp(x, -2, -250, 3);
  }
}

void addLamp(float x, float y, float z, int zone) {
  lamps.add(new Lamp(x, y, z, zone));
}

// ============================================================
// DRAW LAMPS WITH WIND-COUPLED FLAME LEAN
// ============================================================

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
// 3D AIRFLOW VECTOR FIELD SIMULATION
// ============================================================

void createAirTracers() {
  tracers.clear();
  for (int i = 0; i < 28; i++) {
    tracers.add(new AirTracer());
  }
}

void computeAirVelocity(float x, float y, float z, float t) {
  float vx = 1.00 + 0.14 * sin(t * 0.7 + z * 0.005);
  float vy = 0.04 * sin(t * 0.9 + x * 0.006);
  float vz = -0.45 + 0.10 * cos(t * 0.6 + x * 0.004);

  deflectAroundBody(x, y, z, 145, -170, 10, 220, 210, 185, 1.0, vx, vy, vz);
  vx = airVec.x; vy = airVec.y; vz = airVec.z;

  float towerMidZ = (79.0 + towerRearZ) * 0.5;
  float towerRadZ = max(130.0, (79.0 - towerRearZ) * 0.65);
  deflectAroundBody(x, y, z, -200, -145, towerMidZ, 165, 155, towerRadZ, 0.92, vx, vy, vz);
  vx = airVec.x; vy = airVec.y; vz = airVec.z;

  if (abs(z - 285) < 85 && y > -120 && x > leftWallStartX && x < 480) {
    float dz = (z - 285) / 52.0;
    float wallW = exp(-dz * dz) * max(0.0, 1.0 - abs(y) / 120.0);
    vy -= 0.55 * wallW;
    vz *= (1.0 - 0.30 * wallW);
  }

  if (x > -340 && x < 340 && y > -385 && y < -30 && z > towerRearZ && z < 230) {
    vy -= 0.11;
  }

  if (y > -32 && vy > 0) {
    vy = -0.06;
  }

  airVec.set(vx, vy, vz);
}

void deflectAroundBody(
  float x, float y, float z,
  float cx, float cy, float cz,
  float rx, float ry, float rz,
  float strength,
  float vx, float vy, float vz
) {
  float dx = (x - cx) / rx;
  float dy = (y - cy) / ry;
  float dz = (z - cz) / rz;
  float r = sqrt(max(0.05, dx * dx + dy * dy + dz * dz));

  if (r < 2.3) {
    float w = strength * exp(-1.15 * max(0.0, r - 0.85));
    float nx = dx / r;
    float ny = dy / r;
    float nz = dz / r;
    float dot = vx * nx + vy * ny + vz * nz;
    if (dot < 0) {
      vx -= (1.15 * w) * dot * nx;
      vy -= (1.15 * w) * dot * ny;
      vz -= (1.15 * w) * dot * nz;
    }
    float speedup = 0.24 * w * (1.0 - abs(dot));
    vx += speedup * 1.0;
    vz += speedup * -0.45;
  }
  airVec.set(vx, vy, vz);
}

boolean insideHouseCore(float x, float y, float z) {
  boolean inRightWing = (x > -35 && x < 340 && y > -295 && y < -5 && z > -155 && z < 130);
  boolean inTower     = (x > -350 && x < -248 && y > -272 && y < -5 && z > towerRearZ && z < 82);
  return inRightWing || inTower;
}

void drawAirflowField() {
  float t = frameNumber * 0.045 * max(0.1, airflowSpeed);

  for (float x = -440; x <= 440; x += 110) {
    for (float y = -380; y <= -50; y += 110) {
      for (float z = -260; z <= 360; z += 155) {
        if (insideHouseCore(x, y, z)) continue;

        computeAirVelocity(x, y, z, t);
        float mag = airVec.mag();
        if (mag < 0.05) continue;

        float arrowLen = constrain(24 + mag * 18 * (0.4 + airflowSpeed * 0.6), 16, 62);
        dirVec.set(airVec.x / mag, airVec.y / mag, airVec.z / mag);

        float ex = x + dirVec.x * arrowLen;
        float ey = y + dirVec.y * arrowLen;
        float ez = z + dirVec.z * arrowLen;

        float spdNorm = constrain((mag - 0.65) / 0.85, 0, 1);
        int col = lerpColor(0xFF34B8FF, 0xFF8CFFDF, spdNorm);
        if (spdNorm > 0.72) {
          col = lerpColor(0xFF8CFFDF, GOLD, (spdNorm - 0.72) / 0.28);
        }

        stroke(red(col), green(col), blue(col), 195);
        strokeWeight(1.9);
        line(x, y, z, ex, ey, ez);

        if (abs(dirVec.y) > 0.92) {
          upRef.set(1, 0, 0);
        } else {
          upRef.set(0, 1, 0);
        }
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

  float dt = 5.5 * airflowSpeed;
  for (int i = 0; i < tracers.size(); i++) {
    AirTracer tr = tracers.get(i);
    tr.px = tr.x;
    tr.py = tr.y;
    tr.pz = tr.z;

    if (airflowSpeed > 0.01) {
      computeAirVelocity(tr.x, tr.y, tr.z, t);
      tr.x += airVec.x * dt;
      tr.y += airVec.y * dt;
      tr.z += airVec.z * dt;
      tr.life -= 0.008 * max(0.4, airflowSpeed);
    }

    if (tr.x > 510 || tr.z < -340 || tr.y < -450 || tr.life <= 0 || insideHouseCore(tr.x, tr.y, tr.z)) {
      tr.respawn(false);
    }

    stroke(150, 240, 255, 185 * tr.life);
    strokeWeight(2.4);
    line(tr.px, tr.py, tr.pz, tr.x, tr.y, tr.z);
  }

  noStroke();
}

// ============================================================
// HUD & SIDE-BY-SIDE INTERACTIVE CONTROLS
// ============================================================

float panelW() {
  return min(318, width * 0.48);
}

float panelH() {
  return min(350, height - 24);
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
  fill(12, 22, 36, 234);
  rect(x, y, w, h, 12);

  stroke(GOLD);
  strokeWeight(1.5);
  noFill();
  rect(x, y, w, h, 12);
  noStroke();

  // Header
  fill(255, 221, 157);
  textAlign(LEFT, TOP);
  textSize(13);
  text("TAMIL HOUSE 3D", x + 12, y + 9);

  fill(215, 222, 232);
  textSize(8.5);
  text("KARTHIGAI DEEPAM | APDE P3D", x + 12, y + 25);

  // Small touch Hide HUD pill
  fill(35, 50, 68);
  stroke(130, 155, 175);
  strokeWeight(1);
  rect(x + w - 48, y + 9, 36, 18, 5);
  noStroke();
  fill(WHITE);
  textAlign(CENTER, CENTER);
  textSize(8.5);
  text("HIDE", x + w - 30, y + 18);

  // Side-by-side slider columns (3 rows x 2 columns)
  float sw = (w - 34) / 2.0;
  float col1X = x + 12;
  float col2X = x + 22 + sw;

  // Row 1: Brightness & Density
  drawSlider("BRIGHTNESS", lampBrightness, 0.0, 1.2, col1X, y + 44, sw);
  drawSlider("DENSITY",    lampDensity,    0.1, 1.0, col2X, y + 44, sw);

  // Row 2: Flame Speed & Airflow Speed
  drawSlider("FLAME SPD",  flameSpeed,     0.0, 0.4, col1X, y + 84, sw);
  drawSlider("AIRFLOW",    airflowSpeed,   0.0, 2.0, col2X, y + 84, sw);

  // Row 3 (Side-by-side black-marked length controls): Side Depth & Front Wall Length
  float sideDepthLen = 79.0 - towerRearZ;       // 219 .. 339
  float frontWallLen = -65.0 - leftWallStartX;  // 275 .. 475
  drawSlider("SIDE DEPTH", sideDepthLen, 219.0, 339.0, col1X, y + 124, sw);
  drawSlider("FRONT WALL", frontWallLen, 275.0, 475.0, col2X, y + 124, sw);

  // Lamp zone buttons (2x2)
  fill(255, 220, 150);
  textAlign(LEFT, TOP);
  textSize(9);
  text("LAMP ZONES", x + 12, y + 166);

  float bw = (w - 30) / 2.0;
  float bh = 25;

  for (int i = 0; i < 4; i++) {
    float bx = x + 12 + (i % 2) * (bw + 6);
    float by = y + 181 + (i / 2) * 30;

    if (zones[i]) {
      fill(204, 139, 57);
      stroke(255, 220, 150);
    } else {
      fill(48, 58, 73);
      stroke(100, 115, 130);
    }
    strokeWeight(1.2);
    rect(bx, by, bw, bh, 6);

    noStroke();
    fill(WHITE);
    textAlign(CENTER, CENTER);
    textSize(9.5);
    text(zoneNames[i], bx + bw * 0.5, by + bh * 0.5);
  }

  // Row 1 feature toggles: Airflow Vector Field & Day/Night
  float row1Y = y + 246;
  float rbh = 27;

  if (showAirflow) {
    fill(32, 135, 155);
    stroke(135, 240, 255);
  } else {
    fill(42, 62, 78);
    stroke(120, 145, 165);
  }
  rect(x + 12, row1Y, bw, rbh, 6);
  noStroke();
  fill(WHITE);
  textAlign(CENTER, CENTER);
  textSize(9.5);
  text(showAirflow ? "AIRFLOW: ON" : "AIRFLOW: OFF", x + 12 + bw * 0.5, row1Y + rbh * 0.5);

  fill(42, 70, 87);
  stroke(155, 185, 200);
  rect(x + 18 + bw, row1Y, bw, rbh, 6);
  noStroke();
  fill(WHITE);
  text(nightMode ? "DAY VIEW" : "NIGHT VIEW", x + 18 + bw * 1.5, row1Y + rbh * 0.5);

  // Row 2 camera buttons: Backside of Home & Reset Camera
  float row2Y = y + 279;

  if (backsideView) {
    fill(175, 110, 48);
    stroke(255, 220, 150);
  } else {
    fill(52, 74, 96);
    stroke(155, 185, 210);
  }
  rect(x + 12, row2Y, bw, rbh, 6);
  noStroke();
  fill(WHITE);
  text(backsideView ? "FRONT VIEW" : "BACKSIDE VIEW", x + 12 + bw * 0.5, row2Y + rbh * 0.5);

  fill(55, 70, 82);
  stroke(140, 165, 180);
  rect(x + 18 + bw, row2Y, bw, rbh, 6);
  noStroke();
  fill(WHITE);
  text("RESET CAMERA", x + 18 + bw * 1.5, row2Y + rbh * 0.5);

  // Footer tips
  fill(190, 205, 222);
  textAlign(LEFT, TOP);
  textSize(8.2);
  text("Drag outside HUD to orbit | +/-: Zoom", x + 12, y + 314);
  text("Keys: V=Airflow, B=Backside, N=Night, H=HUD", x + 12, y + 327);

  hint(ENABLE_DEPTH_TEST);
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
  textSize(8.5);
  text(label + " " + nf(n * 100, 0, 0) + "%", x, y);

  float ty = y + 19;

  stroke(80, 100, 120);
  strokeWeight(4.2);
  line(x, ty, x + w, ty);

  stroke(GOLD);
  line(x, ty, x + w * n, ty);

  noStroke();
  fill(255, 226, 151);
  ellipse(x + w * n, ty, 11, 11);
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
      mouseY >= y + 9 && mouseY <= y + 27) {
    showHUD = false;
    return;
  }

  // Six side-by-side slider tracks (3 rows x 2 columns)
  float sw = (w - 34) / 2.0;
  float col1X = x + 12;
  float col2X = x + 22 + sw;
  float[] rowTracks = { y + 63, y + 103, y + 143 };

  for (int row = 0; row < 3; row++) {
    if (abs(mouseY - rowTracks[row]) < 15) {
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
  float bh = 25;
  for (int i = 0; i < 4; i++) {
    float bx = x + 12 + (i % 2) * (bw + 6);
    float by = y + 181 + (i / 2) * 30;
    if (mouseX >= bx && mouseX <= bx + bw &&
        mouseY >= by && mouseY <= by + bh) {
      zones[i] = !zones[i];
      return;
    }
  }

  // Row 1 toggles: Airflow & Day/Night
  float row1Y = y + 246;
  float rbh = 27;
  if (mouseY >= row1Y && mouseY <= row1Y + rbh) {
    if (mouseX >= x + 12 && mouseX <= x + 12 + bw) {
      showAirflow = !showAirflow;
      return;
    }
    if (mouseX >= x + 18 + bw && mouseX <= x + 18 + bw * 2) {
      nightMode = !nightMode;
      return;
    }
  }

  // Row 2 camera buttons: Backside View & Reset Camera
  float row2Y = y + 279;
  if (mouseY >= row2Y && mouseY <= row2Y + rbh) {
    if (mouseX >= x + 12 && mouseX <= x + 12 + bw) {
      toggleBacksideView();
      return;
    }
    if (mouseX >= x + 18 + bw && mouseX <= x + 18 + bw * 2) {
      resetCamera();
      return;
    }
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
  targetYaw   = -0.08;
  targetPitch = 0.10;
  targetZoom  = 1.0;
}

// ============================================================
// MOUSE WHEEL COMPATIBILITY FIX FOR APDE
// ============================================================

void mouseWheel(processing.event.MouseEvent event) {
  // Intentionally empty for APDE compatibility.
}

// ============================================================
// KEYBOARD CONTROLS
// ============================================================

void keyPressed() {
  if (key == 'h' || key == 'H') showHUD = !showHUD;
  if (key == 'r' || key == 'R') resetCamera();
  if (key == 'n' || key == 'N') nightMode = !nightMode;
  if (key == 'v' || key == 'V') showAirflow = !showAirflow;
  if (key == 'b' || key == 'B') toggleBacksideView();
  if (key == '+' || key == '=') targetZoom = min(1.80, targetZoom + 0.1);
  if (key == '-')                targetZoom = max(0.55, targetZoom - 0.1);
}

// ============================================================
// END OF COMPLETE REFERENCE HOUSE SKETCH
// ============================================================
