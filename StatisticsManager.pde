class StatisticsManager {
  Table statisticsTable;
  Table statesTable;
  ArrayList<FittsStatistics> statistics;

  public StatisticsManager() {
    loadStatisticsTable();
    loadStatesTable();
    statistics = new ArrayList<FittsStatistics>();
    for (int i=0; i<settings.dof; i++)
      statistics.add(new FittsStatistics());
  }

  private void loadStatisticsTable() {
    if (fileExists(settings.statisticsFile)) {
      statisticsTable = loadTable(settings.statisticsFile, "header");
    } else {
      statisticsTable = new Table();
      statisticsTable.addColumn("tod");
      statisticsTable.addColumn("dof");
      statisticsTable.addColumn("acquisitionPolicy");
      statisticsTable.addColumn("dwellTimeMillis");
      statisticsTable.addColumn("travelTimeMillis");
      statisticsTable.addColumn("amplitude");
      statisticsTable.addColumn("width");
      statisticsTable.addColumn("elapsedTimeMillis");
      statisticsTable.addColumn("distanceTravelled");
      statisticsTable.addColumn("errors");
      statisticsTable.addColumn("overshoots");
    }

    saveTable(statisticsTable, settings.statisticsFile);
  }

  private void loadStatesTable() {
    if (fileExists(settings.stateFile)) {
      statesTable = loadTable(settings.stateFile, "header");
    } else {
      statesTable = new Table();
      statesTable.addColumn("dof");
      statesTable.addColumn("tod");
      statesTable.addColumn("cursorX");
      statesTable.addColumn("targetX");
      statesTable.addColumn("targetWidth");
    }

    saveTable(statesTable, settings.stateFile);
  }

  private boolean fileExists(String filename) {
    File f = new File(settings.stateFile);
    return f.exists();
  }

  public void update(ArrayList<FittsInstance> currentInstance) {
    for (int i=0; i<settings.dof; i++)
      statistics.get(i).update(currentInstance.get(i).getState());
  }

  public void clear() {
    for (int i=0; i<settings.dof; i++)
      statistics.set(i, new FittsStatistics());
  }

  public void logStatistics() {
    // is this even a valid approach?
    FittsStatistics consolidatedStats = new FittsStatistics();

    for (FittsStatistics s : statistics) {
      consolidatedStats.tod = consolidatedStats.tod > s.tod ? consolidatedStats.tod : s.tod;
      consolidatedStats.amplitude += abs(s.amplitude);
      consolidatedStats.width += s.width;
      consolidatedStats.elapsedTimeMillis = consolidatedStats.elapsedTimeMillis > s.elapsedTimeMillis ? consolidatedStats.elapsedTimeMillis : s.elapsedTimeMillis;
      consolidatedStats.distanceTravelled += s.distanceTravelled;
      consolidatedStats.errors += s.errors;
      consolidatedStats.overShoots += s.overShoots;
    }

    TableRow newRow = statisticsTable.addRow();
    newRow.setLong("tod", consolidatedStats.tod);
    newRow.setInt("dof", settings.dof);
    newRow.setString("acquisitionPolicy", settings.acquisitionPolicy == AcquisitionPolicy.DWELL ? "dwell" : "impulse");
    newRow.setLong("dwellTimeMillis", settings.dwellTimeMillis);
    newRow.setLong("travelTimeMillis", settings.travelTimeMillis);
    newRow.setFloat("amplitude", consolidatedStats.amplitude);
    newRow.setFloat("width", consolidatedStats.width);
    newRow.setLong("elapsedTimeMillis", consolidatedStats.elapsedTimeMillis);
    newRow.setFloat("distanceTravelled", consolidatedStats.distanceTravelled);
    newRow.setInt("errors", consolidatedStats.errors);
    newRow.setInt("overshoots", consolidatedStats.overShoots);

    saveTable(statisticsTable, settings.statisticsFile);
  }

  public void logStates() {
    int count = statistics.get(0).getStates().size();

    FittsState state;
    TableRow newRow;
    for (int i=0; i<count; i++) {
      for (int j=0; j<settings.dof; j++) {
        state = statistics.get(j).getStates().get(i);
        newRow = statesTable.addRow();

        newRow.setInt("dof", j);
        newRow.setLong("tod", state.tod);
        newRow.setFloat("cursorX", state.relativeCursorX);
        newRow.setFloat("targetX", state.relativeTargetX);
        newRow.setFloat("targetWidth", state.relativeTargetWidth);
      }
    }

    saveTable(statesTable, settings.stateFile);
  }
}
