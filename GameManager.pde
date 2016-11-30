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
      logTable.addColumn("dof");
      logTable.addColumn("acquisitionPolicy");
      logTable.addColumn("dwellTimeMillis");
      logTable.addColumn("travelTimeMillis");
      logTable.addColumn("activationThreshold");
      logTable.addColumn("amplitude");
      logTable.addColumn("width");
      logTable.addColumn("elapsedTimeMillis");
      logTable.addColumn("distanceTravelled");
      logTable.addColumn("errors");
      logTable.addColumn("overShoots");
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
      consolidatedStats.amplitude += abs(s.amplitude);
      consolidatedStats.width += s.width;
      consolidatedStats.elapsedTimeMillis = max(consolidatedStats.elapsedTimeMillis, s.elapsedTimeMillis);
      consolidatedStats.distanceTravelled += s.distanceTravelled;
      consolidatedStats.errors += s.errors;
      consolidatedStats.overShoots += s.overShoots;
    }

    TableRow newRow = logTable.addRow();
    newRow.setLong("tod", consolidatedStats.tod);
    newRow.setInt("dof", settings.dof);
    newRow.setString("acquisitionPolicy", settings.acquisitionPolicy == AcquisitionPolicy.DWELL ? "dwell" : "impulse");
    newRow.setFloat("dwellTimeMillis", settings.dwellTimeMillis);
    newRow.setFloat("travelTimeMillis", settings.travelTimeMillis);
    newRow.setFloat("activationThreshold", settings.activationThreshold);
    newRow.setFloat("amplitude", consolidatedStats.amplitude);
    newRow.setFloat("width", consolidatedStats.width);
    newRow.setFloat("elapsedTimeMillis", consolidatedStats.elapsedTimeMillis);
    newRow.setFloat("distanceTravelled", consolidatedStats.distanceTravelled);
    newRow.setInt("errors", consolidatedStats.errors);
    newRow.setInt("overShoots", consolidatedStats.overShoots);

    saveTable(logTable, settings.logFile);
  }
}
