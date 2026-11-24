/*
====================================================================
        REFERENCE-ACCURATE MODERN HOUSE - 3D FRONT ELEVATION
        APDE ANDROID - PROCESSING JAVA MODE - P3D

  MODELLED FROM THE TWO USER-SUPPLIED FRONT-VIEW PHOTOGRAPHS.

  FRONT ORIENTATION (STREET VIEW, LEFT TO RIGHT):
    LEFT   : tall white tower with 2 x 3 decorative panels
    LEFT   : external staircase and corrugated metal canopy
    CENTRE : recessed green veranda, entrance door and security grills
    CENTRE : projecting white balcony with THREE peaked diamonds
    RIGHT  : slate-blue ground-floor and upper-floor facade
    TOP-RIGHT: slate-blue rooftop parapet with ONE diamond
    FRONT  : curved compound wall, two arched gates and garden

  COORDINATES:
    X negative = LEFT
    X positive = RIGHT
    Y negative = UP
    Z negative = FRONT / STREET
    Z positive = REAR

  No external libraries.
====================================================================
*/

// ------------------------------------------------------------------
// CAMERA
// ------------------------------------------------------------------

float cameraAngle = 0.0;
float cameraTilt = 0.055;
float cameraDistance = 1160.0;
float targetY = -360.0;
int cameraMode = 0;

float previousTouchX = 0;
float previousTouchY = 0;
boolean draggingModel = false;

// ------------------------------------------------------------------
// VISIBILITY CONTROLS
// ------------------------------------------------------------------

boolean showUI = true;
boolean showRoof = true;
boolean showBalcony = true;
boolean showStairs = true;
boolean showCanopy = true;
boolean showWindows = true;
boolean showGrills = true;
boolean showGates = true;
boolean showCompound = true;
boolean showGarden = true;
boolean showLights = true;

// ------------------------------------------------------------------
// COLOURS
// ------------------------------------------------------------------

int whiteWall;
int slateBlue;
int darkWall;
int reliefStone;
int blackMetal;
int glass;
int grillGreen;
int woodBrown;
int concrete;
int paving;
int gold;
int canopyMetal;
int foliage;
int flowerPink;

int uiBackground;
int uiButton;
int uiSelected;
int uiText;

int colourMode = 0;

// ------------------------------------------------------------------
// DISPLAY SETTINGS
// ------------------------------------------------------------------

void settings() {
  fullScreen(P3D);
}

void setup() {
  orientation(LANDSCAPE);
  smooth(4);

  applyPalette(0);

  blackMetal = color(25, 29, 31);
  glass = color(34, 76, 82);
  grillGreen = color(26, 69, 57);
  woodBrown = color(104, 66, 43);
  concrete = color(202, 198, 188);
  paving = color(145, 103, 83);
  gold = color(210, 166, 66);
  canopyMetal = color(57, 56, 53);
  foliage = color(43, 91, 48);
  flowerPink = color(196, 73, 128);

  uiBackground = color(12, 20, 30, 232);
  uiButton = color(48, 63, 78, 245);
  uiSelected = color(21, 133, 122, 248);
  uiText = color(250, 250, 247);

  setView(0);
}

// ------------------------------------------------------------------
// MAIN DRAW LOOP
// ------------------------------------------------------------------

void draw() {
  background(157, 188, 213);

  perspective(
    0.66,
    (float) width / (float) height,
    10.0,
    6500.0
  );

  float horizontalDistance = cos(cameraTilt) * cameraDistance;
  float eyeX = sin(cameraAngle) * horizontalDistance;
  float eyeY = targetY - sin(cameraTilt) * cameraDistance;
  float eyeZ = -cos(cameraAngle) * horizontalDistance;

  // Negative Z is the street/front side of the house.
  if (cameraTilt > 1.25) {
    camera(eyeX, eyeY, eyeZ, 0, targetY, 0, 0, 0, -1);
  } else {
    camera(eyeX, eyeY, eyeZ, 0, targetY, 0, 0, -1, 0);
  }

  ambientLight(150, 150, 150);
  directionalLight(225, 220, 210, -0.35, 0.75, 0.45);
  directionalLight(90, 102, 116, 0.50, -0.35, -0.45);

  drawGroundAndPaving();

  if (showGarden) {
    drawBackgroundTrees();
  }

  drawMainStructure();
  drawLeftTowerDecorations();

  if (showRoof) {
    drawUpperRoofAndRooftopBlock();
  }

  if (showCanopy) {
    drawCorrugatedCanopy();
  }

  if (showStairs) {
    drawExternalStaircase();
  }

  if (showBalcony) {
    drawFrontBalcony();
  }

  if (showWindows) {
    drawAllWindows();
    drawMainEntranceDoor();
  }

  if (showGrills) {
    drawBuildingSecurityGrills();
  }

  if (showLights) {
    drawBuildingLights();
  }

  if (showCompound) {
    drawCompoundWall();
  }

  if (showGates) {
    drawBothGates();
  }

  if (showGarden) {
    drawFrontGarden();
  }

  drawUI();
}

// ==================================================================
// BASIC 3D HELPERS
// ==================================================================

void boxAt(float x, float y, float z,
           float w, float h, float d, int c) {
  pushMatrix();
  translate(x, y, z);
  noStroke();
  fill(c);
  box(w, h, d);
  popMatrix();
}

void line3D(float x1, float y1, float z1,
            float x2, float y2, float z2,
            int c, float weightValue) {
  stroke(c);
  strokeWeight(weightValue);
  line(x1, y1, z1, x2, y2, z2);
  noStroke();
}

// Rectangular beam between two points in the front elevation.
void drawBar3D(float x1, float y1, float z1,
               float x2, float y2, float z2,
               float thickness, float depth, int c) {
  float dx = x2 - x1;
  float dy = y2 - y1;
  float lengthValue = sqrt(dx * dx + dy * dy);
  float angleValue = atan2(dy, dx);

  pushMatrix();
  translate((x1 + x2) * 0.5,
            (y1 + y2) * 0.5,
            (z1 + z2) * 0.5);
  rotateZ(angleValue);
  noStroke();
  fill(c);
  box(lengthValue + thickness * 0.35, thickness, depth);
  popMatrix();
}

// Extruded polygon for staircase and gable geometry.
void drawExtrudedPolygon(float[] px, float[] py, int count,
                         float frontZ, float rearZ, int c) {
  noStroke();
  fill(c);

  beginShape();
  for (int i = 0; i < count; i++) {
    vertex(px[i], py[i], frontZ);
  }
  endShape(CLOSE);

  beginShape();
  for (int i = 0; i < count; i++) {
    vertex(px[i], py[i], rearZ);
  }
  endShape(CLOSE);

  for (int i = 0; i < count; i++) {
    int j = (i + 1) % count;
    beginShape(QUADS);
    vertex(px[i], py[i], frontZ);
    vertex(px[j], py[j], frontZ);
    vertex(px[j], py[j], rearZ);
    vertex(px[i], py[i], rearZ);
    endShape(CLOSE);
  }
}

// ==================================================================
// GROUND, PLOT AND DRIVEWAY
// ==================================================================

void drawGroundAndPaving() {
  boxAt(0, 10, 0, 1500, 20, 1250,
        color(116, 112, 101));

  boxAt(40, 1, -365, 650, 4, 230, paving);

  boxAt(180, -4, -255, 220, 8, 130,
        color(128, 87, 69));

  boxAt(25, -3, -175, 870, 6, 36, concrete);
}

// ==================================================================
// MAIN BUILDING MASSES
// ==================================================================

void drawMainStructure() {

  // Main ground-floor white body.
  boxAt(-20, -125, 0, 660, 250, 390, whiteWall);

  // Slate-blue ground-floor right wing.
  boxAt(410, -125, 0, 280, 250, 390, slateBlue);

  // Tall narrow left tower.
  boxAt(-405, -290, 0, 160, 580, 390, whiteWall);

  // Left/centre upper-floor white mass.
  boxAt(-15, -430, 0, 540, 350, 390, whiteWall);

  // Upper-right structural mass.
  boxAt(370, -440, 0, 330, 370, 390, whiteWall);

  // Slate-blue upper-right front facade.
  boxAt(385, -450, -198, 292, 300, 12, slateBlue);

  // Right-side white vertical return.
  boxAt(535, -445, -198, 12, 300, 14, whiteWall);

  // White moulding bands on the left tower.
  boxAt(-405, -300, -204, 172, 12, 18, whiteWall);
  boxAt(-405, -314, -204, 166, 5, 16, slateBlue);

  // Lower tower ledges.
  boxAt(-405, -35, -204, 172, 12, 18, whiteWall);
  boxAt(-405, -185, -204, 172, 10, 18, whiteWall);
}

// ==================================================================
// LEFT TOWER - SIX DECORATIVE PANELS
// ==================================================================

void drawLeftTowerDecorations() {

  boxAt(-405, -452, -204, 132, 238, 9, slateBlue);

  float[] panelX = {-438, -372};
  float[] panelY = {-525, -452, -379};

  for (int r = 0; r < 3; r++) {
    for (int c = 0; c < 2; c++) {

      float x = panelX[c];
      float y = panelY[r];

      boxAt(x, y, -211, 49, 59, 5,
            color(241, 238, 229));

      boxAt(x, y, -214, 38, 47, 3,
            color(221, 218, 207));

      boxAt(x, y, -217, 28, 30, 4, reliefStone);

      boxAt(x, y, -220, 17, 19, 3,
            color(174, 153, 126));

      boxAt(x, y, -222, 3, 23, 2,
            color(224, 210, 184));

      boxAt(x, y, -222, 21, 3, 2,
            color(224, 210, 184));
    }
  }

  // Outer decorative border.
  drawBar3D(-472, -570, -216,
            -338, -570, -216, 5, 5, whiteWall);

  drawBar3D(-472, -334, -216,
            -338, -334, -216, 5, 5, whiteWall);

  drawBar3D(-472, -570, -216,
            -472, -334, -216, 5, 5, whiteWall);

  drawBar3D(-338, -570, -216,
            -338, -334, -216, 5, 5, whiteWall);
}

// ==================================================================
// UPPER-RIGHT ROOF SLAB AND ROOFTOP PARAPET
// ==================================================================

void drawUpperRoofAndRooftopBlock() {

  boxAt(365, -610, -4, 710, 20, 440, whiteWall);

  boxAt(365, -601, -228, 710, 6, 12, slateBlue);

  float[] gx = {195, 270, 545, 545};
  float[] gy = {-600, -748, -748, -600};

  drawExtrudedPolygon(gx, gy, 4, -218, -190, whiteWall);

  // Raised rooftop parapet.
  boxAt(405, -683, 0, 280, 126, 390, slateBlue);

  // White coping.
  boxAt(405, -748, 0, 294, 10, 404, whiteWall);
  boxAt(405, -748, -205, 294, 7, 10, whiteWall);

  // Rooftop diamond.
  drawPeakedDiamond(405, -681, -207, 31, false);

  boxAt(405, -620, -220, 600, 7, 12, whiteWall);
}

// ==================================================================
// FRONT BALCONY - THREE PEAKED DIAMOND PANELS
// ==================================================================

void drawFrontBalcony() {

  boxAt(255, -276, -225, 610, 16, 112, slateBlue);
  boxAt(255, -286, -226, 616, 7, 116, whiteWall);

  // Front parapet wall.
  boxAt(255, -342, -269, 600, 106, 24, whiteWall);

  // Slate-blue coping.
  boxAt(255, -397, -270, 610, 8, 29, slateBlue);
  boxAt(255, -402, -270, 610, 4, 31, whiteWall);

  // Right return.
  boxAt(557, -342, -235, 18, 106, 88, whiteWall);
  boxAt(557, -397, -235, 24, 8, 92, slateBlue);

  // Chamfered left end.
  pushMatrix();
  translate(-48, 0, -250);
  rotateY(-QUARTER_PI * 0.55);

  boxAt(0, -342, 0, 88, 106, 23, whiteWall);
  boxAt(0, -397, 0, 94, 8, 28, slateBlue);

  popMatrix();

  // Three main diamond panels.
  drawPeakedDiamond(75, -349, -286, 35, true);
  drawPeakedDiamond(255, -349, -286, 35, true);
  drawPeakedDiamond(435, -349, -286, 35, true);

  // Small left return diamond.
  pushMatrix();
  translate(-48, -349, -270);
  rotateY(-QUARTER_PI * 0.55);

  drawPeakedDiamond(0, 0, -18, 21, false);

  popMatrix();

  boxAt(255, -291, -282, 600, 5, 7, whiteWall);
}

// ==================================================================
// DIAMOND LATTICE - 3 x 3 RHOMBUS OPENINGS
// ==================================================================

void drawPeakedDiamond(float cx, float cy, float z,
                       float s, boolean withPeak) {

  noStroke();
  fill(darkWall);

  beginShape();
  vertex(cx, cy - s, z + 3);
  vertex(cx + s, cy, z + 3);
  vertex(cx, cy + s, z + 3);
  vertex(cx - s, cy, z + 3);
  endShape(CLOSE);

  int frameColour = color(247, 244, 236);

  // Outer diamond.
  drawBar3D(cx, cy - s, z,
            cx + s, cy, z, 5.5, 7, frameColour);

  drawBar3D(cx + s, cy, z,
            cx, cy + s, z, 5.5, 7, frameColour);

  drawBar3D(cx, cy + s, z,
            cx - s, cy, z, 5.5, 7, frameColour);

  drawBar3D(cx - s, cy, z,
            cx, cy - s, z, 5.5, 7, frameColour);

  float q1 = -s / 3.0;
  float q2 = s / 3.0;

  // Family A.
  drawBar3D(
    cx + (q1 + s) * 0.5,
    cy + (q1 - s) * 0.5, z,
    cx + (q1 - s) * 0.5,
    cy + (q1 + s) * 0.5, z,
    3.6, 6, frameColour
  );

  drawBar3D(
    cx + (q2 + s) * 0.5,
    cy + (q2 - s) * 0.5, z,
    cx + (q2 - s) * 0.5,
    cy + (q2 + s) * 0.5, z,
    3.6, 6, frameColour
  );

  // Family B.
  drawBar3D(
    cx + (q1 - s) * 0.5,
    cy + (-s - q1) * 0.5, z,
    cx + (q1 + s) * 0.5,
    cy + (s - q1) * 0.5, z,
    3.6, 6, frameColour
  );

  drawBar3D(
    cx + (q2 - s) * 0.5,
    cy + (-s - q2) * 0.5, z,
    cx + (q2 + s) * 0.5,
    cy + (s - q2) * 0.5, z,
    3.6, 6, frameColour
  );

  if (withPeak) {

    float peakY = cy - s - 17;
    float baseY = cy - s + 11;
    float halfWidth = s * 0.72;

    noStroke();
    fill(whiteWall);

    beginShape();
    vertex(cx, peakY, z + 5);
    vertex(cx + halfWidth, baseY, z + 5);
    vertex(cx - halfWidth, baseY, z + 5);
    endShape(CLOSE);

    drawBar3D(
      cx - halfWidth - 2, baseY, z + 4,
      cx, peakY - 2, z + 4,
      4.2, 9, slateBlue
    );

    drawBar3D(
      cx, peakY - 2, z + 4,
      cx + halfWidth + 2, baseY, z + 4,
      4.2, 9, slateBlue
    );

    drawBar3D(
      cx - halfWidth, baseY - 4, z + 7,
      cx, peakY + 2, z + 7,
      2.4, 5, color(250, 247, 239)
    );

    drawBar3D(
      cx, peakY + 2, z + 7,
      cx + halfWidth, baseY - 4, z + 7,
      2.4, 5, color(250, 247, 239)
    );
  }
}

// ==================================================================
// EXTERNAL STAIRCASE - SOLID SLOPING SIDE WALL
// ==================================================================

void drawExternalStaircase() {

  float[] sx = {-300, -95, -95, -300};
  float[] sy = {-365, -160, -95, -300};

  drawExtrudedPolygon(sx, sy, 4, -252, -222, whiteWall);

  // Sloping coping.
  drawBar3D(-300, -365, -256,
            -95, -160, -256,
            6, 34, slateBlue);

  drawBar3D(-95, -160, -256,
            -95, -95, -256,
            5, 34, slateBlue);

  // Concrete stair treads.
  for (int i = 0; i < 9; i++) {
    float stepX = -112 - i * 19.0;
    float stepY = -108 - i * 22.0;

    boxAt(stepX, stepY, -206,
          38, 13, 55, concrete);
  }

  // Upper landing.
  boxAt(-245, -292, -192, 160, 14, 88, concrete);

  // Doorway.
  boxAt(-250, -350, -205, 48, 112, 9, darkWall);
  boxAt(-250, -350, -211, 38, 101, 3, woodBrown);

  // Handrail.
  drawBar3D(-300, -378, -264,
            -95, -173, -264,
            3.5, 5, blackMetal);
}

// ==================================================================
// LEFT TERRACE CORRUGATED METAL CANOPY
// ==================================================================

void drawCorrugatedCanopy() {

  boxAt(-230, -544, -82, 470, 8, 286, canopyMetal);

  // Corrugated ribs.
  for (int i = -450; i <= -10; i += 14) {
    boxAt(i, -549, -82,
          3, 3, 282, color(91, 87, 80));
  }

  // Front and rear beams.
  boxAt(-230, -535, -226, 474, 9, 9, blackMetal);
  boxAt(-230, -535, 62, 474, 9, 9, blackMetal);

  // Cross supports.
  boxAt(-230, -525, -155, 466, 7, 7, blackMetal);
  boxAt(-230, -525, -65, 466, 7, 7, blackMetal);
  boxAt(-230, -525, 25, 466, 7, 7, blackMetal);

  // Front supports.
  boxAt(-420, -450, -220, 7, 170, 7, blackMetal);
  boxAt(-240, -450, -220, 7, 170, 7, blackMetal);
  boxAt(-58, -450, -220, 7, 170, 7, blackMetal);

  // Rear supports.
  boxAt(-420, -450, 45, 7, 170, 7, blackMetal);
  boxAt(-240, -450, 45, 7, 170, 7, blackMetal);
  boxAt(-58, -450, 45, 7, 170, 7, blackMetal);
}

// ==================================================================
// WINDOW HELPER
// ==================================================================

void drawWindowGrid(float x, float y, float wallZ,
                    float w, float h, int columns, int rows) {

  boxAt(x, y, wallZ - 3,
        w + 14, h + 14, 7, whiteWall);

  boxAt(x, y, wallZ - 7,
        w + 3, h + 3, 3, darkWall);

  boxAt(x, y, wallZ - 9,
        w - 5, h - 5, 2, glass);

  // Vertical mullions.
  for (int c = 1; c < columns; c++) {
    float mx = x - w * 0.5 + w * c / columns;

    boxAt(mx, y, wallZ - 12,
          4, h - 4, 3, whiteWall);
  }

  // Horizontal transoms.
  for (int r = 1; r < rows; r++) {
    float my = y - h * 0.5 + h * r / rows;

    boxAt(x, my, wallZ - 12,
          w - 4, 4, 3, whiteWall);
  }

  boxAt(x, y - h * 0.5 - 3, wallZ - 13,
        w + 8, 4, 3, color(250, 247, 239));
}

// ==================================================================
// ALL FRONT WINDOWS AND DOORS
// ==================================================================

void drawAllWindows() {

  // Left tower lower window.
  boxAt(-405, -118, -207, 68, 112, 8, grillGreen);

  drawWindowGrid(
    -405, -118, -213,
    52, 92, 2, 2
  );

  // Centre-left green bay window.
  boxAt(10, -135, -201, 146, 130, 10, grillGreen);

  drawWindowGrid(
    10, -135, -209,
    126, 110, 3, 2
  );

  // Inner veranda window.
  drawWindowGrid(
    105, -132, -208,
    42, 106, 1, 3
  );

  // Upper-right windows.
  drawWindowGrid(
    335, -455, -207,
    112, 112, 2, 2
  );

  drawWindowGrid(
    466, -455, -207,
    42, 116, 1, 2
  );

  // Ground-floor right window.
  drawWindowGrid(
    425, -126, -202,
    110, 116, 2, 2
  );

  // Electrical cabinet.
  boxAt(315, -125, -207, 38, 48, 8,
        color(221, 224, 224));

  boxAt(315, -125, -212, 27, 36, 3,
        color(202, 207, 207));

  // Upper terrace door.
  boxAt(-150, -335, -203, 58, 120, 9, darkWall);
  boxAt(-150, -335, -209, 46, 106, 3, woodBrown);
}

void drawMainEntranceDoor() {

  boxAt(195, -132, -211, 82, 158, 10, darkWall);
  boxAt(195, -132, -218, 68, 144, 5, woodBrown);

  // Glazed upper panel.
  boxAt(195, -101, -222, 43, 62, 3,
        color(174, 202, 190));

  // Lower inset.
  boxAt(195, -174, -222, 45, 40, 3,
        color(89, 57, 39));

  // Brass handle.
  boxAt(220, -132, -225, 4, 17, 3, gold);

  // Porch columns.
  boxAt(112, -129, -218, 24, 248, 30, slateBlue);
  boxAt(278, -129, -218, 24, 248, 30, slateBlue);

  boxAt(112, -252, -218, 34, 8, 38, whiteWall);
  boxAt(278, -252, -218, 34, 8, 38, whiteWall);
}

// ==================================================================
// SECURITY GRILLS ON THE BUILDING
// ==================================================================

void drawBuildingSecurityGrills() {

  // Main veranda grille.
  for (int i = 0; i <= 13; i++) {
    float x = 132 + i * 9.5;

    line3D(x, -228, -239,
           x, -22, -239,
           grillGreen, 3.0);
  }

  // Horizontal rails.
  line3D(130, -222, -239,
         258, -222, -239, blackMetal, 4);

  line3D(130, -130, -239,
         258, -130, -239, grillGreen, 3);

  line3D(130, -48, -239,
         258, -48, -239, grillGreen, 3);

  // Upper terrace railing.
  for (int i = 0; i <= 9; i++) {
    float x = -82 + i * 12;

    line3D(x, -438, -211,
           x, -322, -211,
           grillGreen, 2.8);
  }

  line3D(-84, -432, -211,
         28, -432, -211, blackMetal, 3);

  line3D(-84, -375, -211,
         28, -375, -211, blackMetal, 2.5);

  // Right ground-floor window bars.
  for (int i = 0; i <= 6; i++) {
    float x = 374 + i * 17;

    line3D(x, -180, -220,
           x, -75, -220,
           blackMetal, 2.4);
  }
}

// ==================================================================
// BUILDING LIGHTS
// ==================================================================

void drawLamp(float x, float y, float z,
              float radiusValue, int c) {

  pushMatrix();
  translate(x, y, z);
  noStroke();
  fill(c);
  sphereDetail(8);
  sphere(radiusValue);
  popMatrix();
}

void drawBuildingLights() {

  int warm = color(255, 232, 170);

  drawLamp(195, -252, -245, 7, warm);
  drawLamp(75, -275, -260, 5, warm);
  drawLamp(255, -275, -260, 5, warm);
  drawLamp(435, -275, -260, 5, warm);

  drawLamp(28, -76, -476, 5, warm);
}

// ==================================================================
// COMPOUND WALL - WAVY WHITE WALL WITH SLATE COPING
// ==================================================================

void drawCompoundWall() {

  float z = -470;

  drawWaveWall(-560, -180, z, 112, 22, 1.05);
  drawWaveWall(-42, 92, z, 105, 17, 0.85);
  drawWaveWall(300, 560, z, 112, 22, 1.0);

  // Boundary piers.
  drawGatePillar(-570, z, 34, 145);
  drawGatePillar(-170, z, 31, 126);
  drawGatePillar(-55, z, 29, 122);
  drawGatePillar(105, z, 31, 126);
  drawGatePillar(285, z, 34, 145);
  drawGatePillar(570, z, 34, 145);

  // Side returns.
  boxAt(-570, -58, -285, 18, 116, 360, whiteWall);
  boxAt(-570, -118, -285, 24, 6, 365, slateBlue);

  boxAt(570, -58, -285, 18, 116, 360, whiteWall);
  boxAt(570, -118, -285, 24, 6, 365, slateBlue);
}

void drawGatePillar(float x, float z, float w, float h) {

  boxAt(x, -h * 0.5, z, w, h, w, whiteWall);

  boxAt(x, -h - 4, z,
        w + 9, 9, w + 9, slateBlue);

  boxAt(x, -h - 10, z,
        w + 12, 5, w + 12, whiteWall);
}

void drawWaveWall(float x1, float x2, float z,
                  float baseHeight, float amplitude,
                  float waveCount) {

  int segments = 36;
  float step = (x2 - x1) / segments;

  for (int i = 0; i < segments; i++) {

    float t1 = (float) i / segments;
    float t2 = (float) (i + 1) / segments;

    float xa = x1 + i * step;
    float xb = x1 + (i + 1) * step;

    float h1 = baseHeight +
               sin(t1 * TWO_PI * waveCount) * amplitude;

    float h2 = baseHeight +
               sin(t2 * TWO_PI * waveCount) * amplitude;

    float hMid = (h1 + h2) * 0.5;

    boxAt((xa + xb) * 0.5,
          -hMid * 0.5,
          z,
          abs(step) + 2,
          hMid,
          20,
          whiteWall);

    drawBar3D(
      xa, -h1 - 2, z - 2,
      xb, -h2 - 2, z - 2,
      6, 25, slateBlue
    );
  }
}

// ==================================================================
// TWO ARCHED BLACK/GOLD GATES
// ==================================================================

void drawBothGates() {

  // Narrow pedestrian gate.
  drawArchedGate(-112, -474, 88, 137);

  // Wider main entrance gate.
  drawArchedGate(195, -474, 150, 140);
}

void drawArchedGate(float cx, float z,
                    float w, float h) {

  // Lower solid sheet panel.
  boxAt(cx, -24, z, w, 48, 8, blackMetal);

  // Gold strip and medallion.
  boxAt(cx, -45, z - 5, w - 8, 3, 3, gold);

  drawLamp(cx, -25, z - 7, 8, gold);

  // Vertical bars.
  int bars = 11;

  for (int i = 0; i < bars; i++) {

    float t = (float) i / (bars - 1);

    float bx = cx - w * 0.46 + t * w * 0.92;

    float archHeight = sin(t * PI) * 19;
    float topY = -h - archHeight;

    line3D(
      bx, -48, z - 6,
      bx, topY, z - 6,
      blackMetal, 3.2
    );

    drawLamp(bx, topY - 2, z - 7, 2.6, gold);
  }

  // Curved top rail and middle rail.
  int parts = 20;

  for (int i = 0; i < parts; i++) {

    float t1 = (float) i / parts;
    float t2 = (float) (i + 1) / parts;

    float x1 = cx - w * 0.48 + t1 * w * 0.96;
    float x2 = cx - w * 0.48 + t2 * w * 0.96;

    float y1 = -h - sin(t1 * PI) * 19;
    float y2 = -h - sin(t2 * PI) * 19;

    line3D(
      x1, y1, z - 7,
      x2, y2, z - 7,
      blackMetal, 4
    );

    line3D(
      x1, y1 + 15, z - 7,
      x2, y2 + 15, z - 7,
      gold, 2.2
    );
  }

  // Centre stile.
  line3D(
    cx, -48, z - 8,
    cx, -h - 3, z - 8,
    blackMetal, 4
  );

  // Gold studs.
  for (int i = 0; i < 5; i++) {

    float sx = cx - w * 0.36 + i * w * 0.18;

    drawLamp(sx, -23, z - 7, 2.5, gold);
  }
}

// ==================================================================
// BACKGROUND PALMS AND SIDE TREES
// ==================================================================

void drawBackgroundTrees() {

  drawPalmTree(-475, 245, -855);
  drawPalmTree(-95, 260, -820);
  drawPalmTree(575, 235, -790);

  drawShadeTree(-650, 0, -205, 1.0);
  drawShadeTree(650, 0, -195, 0.92);
}

void drawPalmTree(float x, float z, float topY) {

  int segments = 15;
  float totalHeight = abs(topY);

  for (int i = 0; i < segments; i++) {

    float t = (float) i / segments;
    float t2 = (float) (i + 1) / segments;

    float y1 = -totalHeight * t;
    float y2 = -totalHeight * t2;

    float bend1 = sin(t * PI * 0.65) * 24;
    float bend2 = sin(t2 * PI * 0.65) * 24;

    float xm = x + (bend1 + bend2) * 0.5;

    boxAt(
      xm,
      (y1 + y2) * 0.5,
      z,
      13 - t * 5,
      abs(y2 - y1) + 5,
      13 - t * 5,
      color(116, 91, 67)
    );
  }

  float crownX = x + 24;
  float crownY = topY;

  // Twelve radiating palm fronds.
  for (int f = 0; f < 12; f++) {

    float a = TWO_PI * f / 12.0;

    float dx = cos(a) * 118;
    float dz = sin(a) * 95;
    float dy = 28 + abs(cos(a)) * 23;

    line3D(
      crownX, crownY, z,
      crownX + dx, crownY + dy, z + dz,
      color(42, 105, 49), 5.0
    );

    // Leaflets.
    for (int k = 1; k <= 5; k++) {

      float t = k / 6.0;

      float bx = crownX + dx * t;
      float by = crownY + dy * t;
      float bz = z + dz * t;

      float side = (k % 2 == 0) ? 1 : -1;

      line3D(
        bx, by, bz,
        bx + side * 18,
        by + 15,
        bz + side * 15,
        color(47, 113, 53), 2.0
      );

      line3D(
        bx, by, bz,
        bx - side * 18,
        by + 15,
        bz - side * 15,
        color(47, 113, 53), 2.0
      );
    }
  }
}

void drawShadeTree(float x, float y,
                   float z, float scaleValue) {

  pushMatrix();

  translate(x, y, z);
  scale(scaleValue);

  boxAt(0, -90, 0, 18, 180, 18, woodBrown);

  noStroke();
  fill(43, 91, 48);
  sphereDetail(9);

  pushMatrix();
  translate(0, -205, 0);
  sphere(66);
  popMatrix();

  pushMatrix();
  translate(-42, -174, 12);
  sphere(47);
  popMatrix();

  pushMatrix();
  translate(43, -176, -10);
  sphere(48);
  popMatrix();

  pushMatrix();
  translate(0, -150, 42);
  sphere(42);
  popMatrix();

  popMatrix();
}

// ==================================================================
// FRONT SHRUBS AND FLOWERS
// ==================================================================

void drawFrontGarden() {

  drawFlowerBush(-470, -4, -505, true, 1.0);
  drawFlowerBush(-385, -4, -505, true, 0.9);
  drawFlowerBush(-300, -4, -505, false, 0.88);
  drawFlowerBush(-220, -4, -505, true, 0.78);
  drawFlowerBush(355, -4, -505, false, 0.88);
  drawFlowerBush(440, -4, -505, true, 0.95);
  drawFlowerBush(510, -4, -505, false, 0.86);
}

void drawFlowerBush(float x, float y, float z,
                    boolean hasFlowers, float scaleValue) {

  pushMatrix();

  translate(x, y, z);
  scale(scaleValue);

  noStroke();
  sphereDetail(7);

  fill(37, 83, 43);
  sphere(19);

  pushMatrix();
  translate(-15, -5, 2);
  sphere(14);
  popMatrix();

  pushMatrix();
  translate(15, -6, -3);
  sphere(15);
  popMatrix();

  pushMatrix();
  translate(0, -13, -9);
  sphere(13);
  popMatrix();

  if (hasFlowers) {

    fill(flowerPink);

    pushMatrix();
    translate(-9, -17, -8);
    sphere(5.5);
    popMatrix();

    pushMatrix();
    translate(9, -16, -9);
    sphere(5.5);
    popMatrix();

    pushMatrix();
    translate(0, -21, 2);
    sphere(5);
    popMatrix();

    pushMatrix();
    translate(16, -9, 5);
    sphere(4.5);
    popMatrix();
  }

  popMatrix();
}

// ==================================================================
// EXTERIOR COLOUR PALETTES
// ==================================================================

void applyPalette(int mode) {

  colourMode = mode;

  if (mode == 0) {

    // Reference photo: ivory and slate blue.
    whiteWall = color(239, 235, 226);
    slateBlue = color(52, 76, 88);
    darkWall = color(27, 39, 45);
    reliefStone = color(198, 177, 146);

  } else if (mode == 1) {

    // Sandstone and muted brown.
    whiteWall = color(239, 225, 201);
    slateBlue = color(125, 83, 61);
    darkWall = color(60, 40, 32);
    reliefStone = color(213, 185, 146);

  } else if (mode == 2) {

    // Sage and forest green.
    whiteWall = color(226, 235, 226);
    slateBlue = color(58, 101, 88);
    darkWall = color(28, 53, 47);
    reliefStone = color(187, 202, 184);

  } else {

    // Cool grey and charcoal.
    whiteWall = color(230, 232, 237);
    slateBlue = color(72, 79, 96);
    darkWall = color(35, 39, 48);
    reliefStone = color(194, 198, 209);
  }
}

void nextPalette() {
  applyPalette((colourMode + 1) % 4);
}

// ==================================================================
// CAMERA PRESETS
// ==================================================================

void setView(int viewNumber) {

  cameraMode = viewNumber;
  targetY = -360;

  if (viewNumber == 0) {

    // Main front view.
    cameraAngle = 0;
    cameraTilt = 0.055;
    cameraDistance = 1160;

  } else if (viewNumber == 1) {

    // Elevated front-right.
    cameraAngle = 0.42;
    cameraTilt = 0.48;
    cameraDistance = 1350;

  } else if (viewNumber == 2) {

    // Left side.
    cameraAngle = -HALF_PI;
    cameraTilt = 0.12;
    cameraDistance = 1280;

  } else if (viewNumber == 3) {

    // Right side.
    cameraAngle = HALF_PI;
    cameraTilt = 0.12;
    cameraDistance = 1280;

  } else if (viewNumber == 4) {

    // Rear.
    cameraAngle = PI;
    cameraTilt = 0.12;
    cameraDistance = 1250;

  } else if (viewNumber == 5) {

    // Top.
    cameraAngle = 0;
    cameraTilt = 1.40;
    cameraDistance = 1450;
    targetY = -250;
  }
}

void resetCamera() {
  setView(0);
}

// ==================================================================
// USER INTERFACE - BUTTON DRAWING
// ==================================================================

void drawButton(String label, boolean active,
                float x, float y, float w, float h) {

  noStroke();

  fill(active ? uiSelected : uiButton);
  rect(x, y, w, h, 6);

  fill(uiText);

  textAlign(CENTER, CENTER);
  textSize(10);

  text(
    label,
    x + w * 0.5,
    y + h * 0.5
  );

  textAlign(LEFT, BASELINE);
}

// ==================================================================
// 2D INTERFACE
// ==================================================================

void drawUI() {

  hint(DISABLE_DEPTH_TEST);
  noLights();

  camera();
  ortho();

  noStroke();

  if (!showUI) {

    fill(uiBackground);
    rect(width - 116, 8, 108, 32, 7);

    drawButton(
      "SHOW UI",
      true,
      width - 111,
      11,
      98,
      26
    );

    hint(ENABLE_DEPTH_TEST);
    return;
  }

  // Header.
  fill(uiBackground);
  rect(0, 0, width, 34);

  fill(255);

  textAlign(LEFT, CENTER);
  textSize(12);

  text(
    "REFERENCE-ACCURATE 3D HOUSE",
    12, 17
  );

  textAlign(RIGHT, CENTER);
  textSize(9);

  text(
    "DRAG TO ROTATE  |  TAP CONTROLS",
    width - 12, 17
  );

  textAlign(LEFT, BASELINE);

  // Left panel.
  fill(uiBackground);
  rect(8, 42, 148, 220, 8);

  fill(255);
  textSize(10);
  text("HOUSE PARTS", 15, 59);

  drawButton("ROOF", showRoof, 14, 68, 62, 25);
  drawButton("BALCONY", showBalcony, 82, 68, 67, 25);

  drawButton("STAIRS", showStairs, 14, 99, 62, 25);
  drawButton("WINDOWS", showWindows, 82, 99, 67, 25);

  drawButton("CANOPY", showCanopy, 14, 130, 62, 25);
  drawButton("GRILLS", showGrills, 82, 130, 67, 25);

  drawButton("WALL", showCompound, 14, 161, 62, 25);
  drawButton("GATES", showGates, 82, 161, 67, 25);

  drawButton("GARDEN", showGarden, 14, 192, 62, 25);
  drawButton("LIGHTS", showLights, 82, 192, 67, 25);

  drawButton("HIDE UI", false, 14, 226, 135, 26);

  // Right camera panel.
  float rx = width - 142;

  fill(uiBackground);
  rect(rx, 42, 134, 220, 8);

  fill(255);
  textSize(10);
  text("CAMERA VIEWS", rx + 9, 59);

  drawButton("FRONT", cameraMode == 0,
             rx + 9, 68, 116, 25);

  drawButton("3D ELEVATED", cameraMode == 1,
             rx + 9, 99, 116, 25);

  drawButton("LEFT SIDE", cameraMode == 2,
             rx + 9, 130, 116, 25);

  drawButton("RIGHT SIDE", cameraMode == 3,
             rx + 9, 161, 116, 25);

  drawButton("REAR", cameraMode == 4,
             rx + 9, 192, 116, 25);

  drawButton("TOP VIEW", cameraMode == 5,
             rx + 9, 223, 116, 25);

  // Bottom control bar.
  float barW = 390;
  float barX = width * 0.5 - barW * 0.5;
  float barY = height - 40;

  fill(uiBackground);
  rect(barX, barY - 3, barW, 36, 8);

  drawButton("ZOOM +", false,
             barX + 5, barY + 2, 64, 25);

  drawButton("ZOOM -", false,
             barX + 74, barY + 2, 64, 25);

  drawButton("COLOUR", false,
             barX + 143, barY + 2, 66, 25);

  drawButton("RESET", false,
             barX + 214, barY + 2, 58, 25);

  drawButton("HIDE UI", false,
             barX + 277, barY + 2, 106, 25);

  hint(ENABLE_DEPTH_TEST);
}

// ==================================================================
// TOUCH / MOUSE HIT TEST
// ==================================================================

boolean hit(float x, float y, float w, float h) {

  return mouseX >= x && mouseX <= x + w &&
         mouseY >= y && mouseY <= y + h;
}

// ==================================================================
// TOUCH PRESSED
// ==================================================================

void mousePressed() {

  previousTouchX = mouseX;
  previousTouchY = mouseY;

  draggingModel = false;

  if (!showUI) {

    if (hit(width - 116, 8, 108, 32)) {
      showUI = true;
      return;
    }

    draggingModel = true;
    return;
  }

  // Left house parts panel.
  if (hit(8, 42, 148, 220)) {

    if (hit(14, 68, 62, 25)) {
      showRoof = !showRoof;
      return;
    }

    if (hit(82, 68, 67, 25)) {
      showBalcony = !showBalcony;
      return;
    }

    if (hit(14, 99, 62, 25)) {
      showStairs = !showStairs;
      return;
    }

    if (hit(82, 99, 67, 25)) {
      showWindows = !showWindows;
      return;
    }

    if (hit(14, 130, 62, 25)) {
      showCanopy = !showCanopy;
      return;
    }

    if (hit(82, 130, 67, 25)) {
      showGrills = !showGrills;
      return;
    }

    if (hit(14, 161, 62, 25)) {
      showCompound = !showCompound;
      return;
    }

    if (hit(82, 161, 67, 25)) {
      showGates = !showGates;
      return;
    }

    if (hit(14, 192, 62, 25)) {
      showGarden = !showGarden;
      return;
    }

    if (hit(82, 192, 67, 25)) {
      showLights = !showLights;
      return;
    }

    if (hit(14, 226, 135, 26)) {
      showUI = false;
      return;
    }

    return;
  }

  // Right camera panel.
  float rx = width - 142;

  if (hit(rx, 42, 134, 220)) {

    if (hit(rx + 9, 68, 116, 25)) {
      setView(0);
      return;
    }

    if (hit(rx + 9, 99, 116, 25)) {
      setView(1);
      return;
    }

    if (hit(rx + 9, 130, 116, 25)) {
      setView(2);
      return;
    }

    if (hit(rx + 9, 161, 116, 25)) {
      setView(3);
      return;
    }

    if (hit(rx + 9, 192, 116, 25)) {
      setView(4);
      return;
    }

    if (hit(rx + 9, 223, 116, 25)) {
      setView(5);
      return;
    }

    return;
  }

  // Bottom controls.
  float barW = 390;
  float barX = width * 0.5 - barW * 0.5;
  float barY = height - 40;

  if (hit(barX, barY - 3, barW, 36)) {

    if (hit(barX + 5, barY + 2, 64, 25)) {

      cameraDistance = max(
        760,
        cameraDistance - 90
      );

      return;
    }

    if (hit(barX + 74, barY + 2, 64, 25)) {

      cameraDistance = min(
        2200,
        cameraDistance + 90
      );

      return;
    }

    if (hit(barX + 143, barY + 2, 66, 25)) {
      nextPalette();
      return;
    }

    if (hit(barX + 214, barY + 2, 58, 25)) {
      resetCamera();
      return;
    }

    if (hit(barX + 277, barY + 2, 106, 25)) {
      showUI = false;
      return;
    }

    return;
  }

  draggingModel = true;
}

// ==================================================================
// TOUCH DRAG
// ==================================================================

void mouseDragged() {

  if (!draggingModel) return;

  float dx = mouseX - previousTouchX;
  float dy = mouseY - previousTouchY;

  cameraAngle += dx * 0.007;

  cameraTilt += dy * 0.004;

  cameraTilt = constrain(
    cameraTilt,
    -0.12,
    1.43
  );

  previousTouchX = mouseX;
  previousTouchY = mouseY;

  cameraMode = -1;
}

// ==================================================================
// TOUCH RELEASE
// ==================================================================

void mouseReleased() {
  draggingModel = false;
}

// ==================================================================
// KEYBOARD SHORTCUTS
// ==================================================================

void keyPressed() {

  if (key == '1') setView(0);
  if (key == '2') setView(1);
  if (key == '3') setView(2);
  if (key == '4') setView(3);
  if (key == '5') setView(4);
  if (key == '6') setView(5);

  if (key == '+' || key == '=') {
    cameraDistance = max(
      760,
      cameraDistance - 90
    );
  }

  if (key == '-') {
    cameraDistance = min(
      2200,
      cameraDistance + 90
    );
  }

  if (key == 'r' || key == 'R') {
    resetCamera();
  }

  if (key == 'u' || key == 'U') {
    showUI = !showUI;
  }

  if (key == 'c' || key == 'C') {
    nextPalette();
  }
}
