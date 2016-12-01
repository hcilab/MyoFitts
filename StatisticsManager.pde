class StatisticsManager {
  Table statisticsTable;
  ArrayList<FittsStatistics> statistics;

  public StatisticsManager() {
    loadStatisticsTable();
    statistics = new ArrayList<FittsStatistics>();
    for (int i=0; i<settings.dof; i++)
      statistics.add(new FittsStatistics());
  }

  private void loadStatisticsTable() {
    File f = new File(settings.logFile);
    if (f.exists()) {
      statisticsTable = loadTable(settings.logFile, "header");
    } else {
      statisticsTable = new Table();
      statisticsTable.addColumn("tod");
      statisticsTable.addColumn("dof");
      statisticsTable.addColumn("acquisitionPolicy");
      statisticsTable.addColumn("dwellTimeMillis");
      statisticsTable.addColumn("travelTimeMillis");
      statisticsTable.addColumn("activationThreshold");
      statisticsTable.addColumn("amplitude");
      statisticsTable.addColumn("width");
      statisticsTable.addColumn("elapsedTimeMillis");
      statisticsTable.addColumn("distanceTravelled");
      statisticsTable.addColumn("errors");
      statisticsTable.addColumn("overShoots");
    }

    saveTable(statisticsTable, settings.logFile);
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
    newRow.setFloat("dwellTimeMillis", settings.dwellTimeMillis);
    newRow.setFloat("travelTimeMillis", settings.travelTimeMillis);
    newRow.setFloat("activationThreshold", settings.activationThreshold);
    newRow.setFloat("amplitude", consolidatedStats.amplitude);
    newRow.setFloat("width", consolidatedStats.width);
    newRow.setLong("elapsedTimeMillis", consolidatedStats.elapsedTimeMillis);
    newRow.setFloat("distanceTravelled", consolidatedStats.distanceTravelled);
    newRow.setInt("errors", consolidatedStats.errors);
    newRow.setInt("overShoots", consolidatedStats.overShoots);

    saveTable(statisticsTable, settings.logFile);
  }
}
