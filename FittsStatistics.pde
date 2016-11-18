enum Direction {INSIDE, OUTSIDE};


class FittsStatistics {
  public long tod;
  public float initialDistance;
  public float targetWidth;
  public int elapsedTime;
  public int errors;

  private Direction lastEnteredTargetFrom;

  public FittsStatistics () {
    this(0.0, 0.0);
  }

  public FittsStatistics (float initialDistance, float targetWidth) {
    this.tod = System.currentTimeMillis();
    this.initialDistance = initialDistance;
    this.targetWidth = targetWidth;
    this.elapsedTime = 0;
    this.errors = 0;

    // the initial value doesn't really matter
    lastEnteredTargetFrom = Direction.INSIDE;
  }

  public void update(float elapsedTime, FittsState currentState, FittsState previousState) {
    // increment elapsed time
    this.elapsedTime += elapsedTime;

    // did cursor enter the target? from which direction?
    if (!previousState.isCursorInTarget() && currentState.isCursorInTarget()) {
      if (abs(previousState.relativeCursorX) < abs(previousState.relativeTargetX))
        lastEnteredTargetFrom = Direction.INSIDE;
      else
        lastEnteredTargetFrom = Direction.OUTSIDE;
    }

    // did cursor leave the target?
    if (previousState.isCursorInTarget() && !currentState.isCursorInTarget())
      errors++;
  }
}
