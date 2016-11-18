HashMap<FittsComponent, Color> ACTIVE_COLORS;
HashMap<FittsComponent, Color> BACKGROUND_COLORS;

Settings settings;
InstanceManager instanceManager;
GameManager gameManager;


void setup() {
  fullScreen();
  surface.setResizable(true);
  initializeColors();

  initializeSettingsOrDie();

  initializeGameManagerOrDie();
  initializeInstanceManagerOrDie();

  // load initial instance
  if (instanceManager.hasNext())
    gameManager.setInstance(instanceManager.getNext());
}


void draw() {
  background(255, 255, 255);
  float frameTimeMillis = 1000.0/frameRate;

  if (gameManager.isAcquired()) {
    gameManager.logStatistics();
    if (instanceManager.hasNext())
      gameManager.setInstance(instanceManager.getNext());
    else
      exit();
  }

  gameManager.update(frameTimeMillis);
  gameManager.draw();
}


private void initializeColors() {
  ACTIVE_COLORS = new HashMap<FittsComponent, Color>();
  ACTIVE_COLORS.put(FittsComponent.CURSOR, new Color(0, 0, 255));
  ACTIVE_COLORS.put(FittsComponent.TARGET_FREE, new Color(255, 0, 0));
  ACTIVE_COLORS.put(FittsComponent.TARGET_ACQUIRED, new Color(0, 255, 0));
  ACTIVE_COLORS.put(FittsComponent.BACKGROUND, new Color(128, 128, 128));

  BACKGROUND_COLORS = new HashMap<FittsComponent, Color>();
  BACKGROUND_COLORS.put(FittsComponent.CURSOR, new Color(153, 153, 255));
  BACKGROUND_COLORS.put(FittsComponent.TARGET_FREE, new Color(255, 153, 153));
  BACKGROUND_COLORS.put(FittsComponent.TARGET_ACQUIRED, new Color(153, 255, 153));
  BACKGROUND_COLORS.put(FittsComponent.BACKGROUND, new Color(224, 224, 224));
}

private void initializeSettingsOrDie() {
  settings = new Settings("settings.json");
}

private void initializeGameManagerOrDie() {
  try {
    gameManager = new GameManager(this);
  } catch (MyoNotDetectectedError e) {
    println("[ERROR] Could not detect armband, exiting.");
    System.exit(1);
  } catch (CalibrationFailedException e) {
    println("[ERROR] Could not load calibration settings from: " + settings.calibrationFile + ", exiting.");
    System.exit(2);
  }
}

private void initializeInstanceManagerOrDie() {
  instanceManager = new InstanceManager(settings.inputFile);
}
