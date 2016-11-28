class GameManager {
  private ControlManager controlManager;
  private ArrayList<FittsInstance> instance;
  private int currentInstanceIndex;
  private Table logTable;

  public GameManager(PApplet mainObject) throws MyoNotDetectectedError, CalibrationFailedException {
    controlManager = new ControlManager(mainObject);
    instance = new ArrayList<FittsInstance>();
    currentInstanceIndex = 0;
    loadLogTable();
  }

  private void loadLogTable() {
    File f = new File(settings.logFile);
    if (f.exists()) {
      logTable = loadTable(settings.logFile, "header");
    } else {
      logTable = new Table();
      logTable.addColumn("tod");
      logTable.addColumn("initialDistance");
      logTable.addColumn("targetWidth");
      logTable.addColumn("elapsedTime");
      logTable.addColumn("errors");
    }

    saveTable(logTable, settings.logFile);
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

  public void update(float frameTimeMillis) {
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
  }

  public void draw() {
    for (int i=0; i<instance.size(); i++) {
      if (i == currentInstanceIndex)
        instance.get(i).draw(ACTIVE_COLORS);
      else
        instance.get(i).draw(BACKGROUND_COLORS);
    }
  }

  public void logStatistics() {
    // is this even a valid approach?
    FittsStatistics consolidatedStats = new FittsStatistics();
    for (FittsInstance i : instance) {
      FittsStatistics s = i.getStatistics();

      consolidatedStats.tod = consolidatedStats.tod > s.tod ? consolidatedStats.tod : s.tod;
      consolidatedStats.initialDistance += abs(s.initialDistance);
      consolidatedStats.targetWidth += s.targetWidth;
      consolidatedStats.elapsedTime = max(consolidatedStats.elapsedTime, s.elapsedTime);
      consolidatedStats.errors += s.errors;
    }

    TableRow newRow = logTable.addRow();
    newRow.setLong("tod", consolidatedStats.tod);
    newRow.setFloat("initialDistance", consolidatedStats.initialDistance);
    newRow.setFloat("targetWidth", consolidatedStats.targetWidth);
    newRow.setInt("elapsedTime", consolidatedStats.elapsedTime);
    newRow.setInt("errors", consolidatedStats.errors);

    saveTable(logTable, settings.logFile);
  }
}
