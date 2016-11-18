class InstanceManager {
  Table input;
  int currentRow;

  public InstanceManager(String inputFilename) {
    input = loadTable(inputFilename, "header");
    currentRow = 0;

    assert(settings.dof <= 2);
    assert(input.getRowCount() % settings.dof == 0);
  }

  public boolean hasNext() {
    return currentRow+(settings.dof-1) < input.getRowCount();
  }

  public ArrayList<FittsInstance> getNext() {
    assert(hasNext());

    ArrayList<FittsInstance> instance = new ArrayList<FittsInstance>();

    TableRow r;
    float targetX;
    float targetWidth;

    // This is a hack. Placement should be generalized to support N-DOF.
    // TODO: Derive a formula for bar placement.
    if (settings.dof == 1) {
      r = input.getRow(currentRow++);
      targetX = r.getFloat("targetX");
      targetWidth = r.getFloat("targetWidth");
      instance.add(new FittsInstance(0.5, 0.8, 0.0, 0.0, targetX, targetWidth));

    } else if (settings.dof == 2) {
      r = input.getRow(currentRow++);
      targetX = r.getFloat("targetX");
      targetWidth = r.getFloat("targetWidth");
      instance.add(new FittsInstance(0.4, 0.8, 0.0, -0.5, targetX, targetWidth));

      r = input.getRow(currentRow++);
      targetX = r.getFloat("targetX");
      targetWidth = r.getFloat("targetWidth");
      instance.add(new FittsInstance(0.4, 0.8, 0.0, 0.5, targetX, targetWidth));
    }

    return instance;
  }
}
