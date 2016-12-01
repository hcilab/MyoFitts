HashMap<FittsComponent, Color> ACTIVE_COLORS;
HashMap<FittsComponent, Color> BACKGROUND_COLORS;

Settings settings;
ReplayManager replayManager;
ArrayList<FittsState> currentStates;
ArrayList<FittsState> nextStates;

long timeBetweenStates;
long elapsedTime;

void setup() {
  fullScreen();
  surface.setResizable(true);
  initializeColors();

  initializeSettingsOrDie();
  initializeReplayManagerOrDie();

  nextStates = replayManager.getNext();
  currentStates = nextStates;

  timeBetweenStates = nextStates.get(0).tod - currentStates.get(0).tod;
  elapsedTime = 0;
}


void draw() {
  background(255, 255, 255);
  long frameTimeMillis = round(1000.0/frameRate);

  elapsedTime += frameTimeMillis;

  if (elapsedTime > timeBetweenStates) {
    if (replayManager.hasNext()) {
      currentStates = nextStates;
      nextStates = replayManager.getNext();
      timeBetweenStates = nextStates.get(0).tod - currentStates.get(0).tod;
      elapsedTime = 0;
    } else {
      exit();
    }
  }

  // currently hard-coded for 2 dof
  FittsInstance i1 = new FittsInstance(0.4, 0.8, 0.0, -0.5, currentStates.get(0).relativeTargetX, currentStates.get(0).relativeTargetWidth, currentStates.get(0).relativeCursorX);
  FittsInstance i2 = new FittsInstance(0.4, 0.8, 0.0, 0.5, currentStates.get(1).relativeTargetX, currentStates.get(1).relativeTargetWidth, currentStates.get(1).relativeCursorX);

  i1.draw(BACKGROUND_COLORS);
  i2.draw(BACKGROUND_COLORS);
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

private void initializeReplayManagerOrDie() {
  replayManager = new ReplayManager(settings.stateFile);
}


class ReplayManager {
  Table replayData;
  int currentRow;

  public ReplayManager(String filename) {
    replayData = loadTable(filename, "header");
    currentRow = 0;
  }

  public boolean hasNext() {
    return currentRow + settings.dof < replayData.getRowCount();
  }

  public ArrayList<FittsState> getNext() {
    ArrayList<FittsState> states = new ArrayList<FittsState>();

    for (int i=0; i<settings.dof; i++) {
      TableRow r = replayData.getRow(currentRow++);
      states.add(new FittsState(r.getLong("tod"), r.getFloat("cursorX"), r.getFloat("targetX"), r.getFloat("targetWidth")));
    }

    return states;
  }
}
