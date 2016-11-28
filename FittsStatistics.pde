enum Direction {INSIDE, OUTSIDE};


class FittsStatistics {
  public long tod;
  public float amplitude;
  public float width;
  public int elapsedTimeMillis;
  public int errors;

  private Direction lastEnteredTargetFrom;

  public FittsStatistics () {
    this(0.0, 0.0);
  }

  public FittsStatistics (float amplitude, float width) {
    this.tod = System.currentTimeMillis();
    this.amplitude = amplitude;
    this.width = width;
    this.elapsedTimeMillis = 0;
    this.errors = 0;

    if (settings.acquisitionPolicy == AcquisitionPolicy.DWELL)
      this.elapsedTimeMillis -= settings.dwellTimeMillis;

    // the initial value doesn't really matter
    lastEnteredTargetFrom = Direction.INSIDE;
  }

  public void update(float elapsedTimeMillis, FittsState currentState, FittsState previousState) {
    // increment elapsed time
    this.elapsedTimeMillis += elapsedTimeMillis;

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
