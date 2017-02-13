class GameManager {
  private ControlManager controlManager;
  private StatisticsManager statisticsManager;
  private ArrayList<FittsInstance> instance;
  private int currentInstanceIndex;
  private Table logTable;

  public GameManager(PApplet mainObject) throws MyoNotDetectectedError, CalibrationFailedException {
    controlManager = new ControlManager(mainObject);
    statisticsManager = new StatisticsManager();
    instance = new ArrayList<FittsInstance>();
    currentInstanceIndex = 0;
  }

  public boolean isAcquired() {
    boolean allTargetsAcquired = true;
    for (FittsInstance i : instance)
      allTargetsAcquired = allTargetsAcquired && i.isAcquired();
    return allTargetsAcquired;
  }

  public void setInstance(ArrayList<FittsInstance> instance) {
    this.instance = instance;
    currentInstanceIndex = 0;
  }

  public void update(long frameTimeMillis) {
    HashMap<Action, Float> realReadings = controlManager.poll();

    HashMap<Action, Float> nullReadings = new HashMap<Action, Float>();
    nullReadings.put(Action.LEFT, 0.0);
    nullReadings.put(Action.RIGHT, 0.0);
    nullReadings.put(Action.IMPULSE, 0.0);

    for (int i=0; i<instance.size(); i++) {
      if (i == currentInstanceIndex)
        instance.get(i).update(frameTimeMillis, realReadings);
      else
        instance.get(i).update(frameTimeMillis, nullReadings);
    }

    if (realReadings.get(Action.IMPULSE) > 0.0)
      currentInstanceIndex = (currentInstanceIndex+1) % instance.size();

    statisticsManager.update(instance);
  }

  public void draw() {
    for (int i=0; i<instance.size(); i++) {
      if (i == currentInstanceIndex)
        instance.get(i).draw(ACTIVE_COLORS);
      else
        instance.get(i).draw(BACKGROUND_COLORS);
    }
  }

  public void log() {
    statisticsManager.logStatistics();
    statisticsManager.logStates();
    statisticsManager.clear();
    controlManager.flushEmgLog();
  }
}
