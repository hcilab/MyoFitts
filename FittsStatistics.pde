enum Direction {INSIDE, OUTSIDE};


class FittsStatistics {
  public long tod;
  public float amplitude;
  public float width;

  public float elapsedTimeMillis;
  public float distanceTravelled;
  public int errors;
  public int overShoots;

  private Direction lastEnteredTargetFrom;

  public FittsStatistics () {
    this(0.0, 0.0);
  }

  public FittsStatistics (float amplitude, float width) {
    this.tod = System.currentTimeMillis();
    this.amplitude = amplitude;
    this.width = width;
    this.elapsedTimeMillis = 0;
    this.distanceTravelled = 0;
    this.errors = 0;
    this.overShoots = 0;

    if (settings.acquisitionPolicy == AcquisitionPolicy.DWELL)
      this.elapsedTimeMillis -= settings.dwellTimeMillis;

    // the initial value doesn't really matter
    lastEnteredTargetFrom = Direction.INSIDE;
  }

  public void update(FittsState currentState, FittsState previousState) {
    // increment elapsed time and distanceTravelled
    this.elapsedTimeMillis += currentState.tod - previousState.tod;
    this.distanceTravelled += abs(currentState.relativeCursorX - previousState.relativeCursorX);

    // did cursor enter the target? from which direction?
    if (!previousState.isCursorInTarget() && currentState.isCursorInTarget()) {
      if (abs(previousState.relativeCursorX) < abs(previousState.relativeTargetX))
        lastEnteredTargetFrom = Direction.INSIDE;
      else
        lastEnteredTargetFrom = Direction.OUTSIDE;
    }

    // did cursor leave the target? from which direction?
    if (previousState.isCursorInTarget() && !currentState.isCursorInTarget()) {
      errors++;

      Direction lastExitedTargetFrom = abs(currentState.relativeCursorX) < abs(currentState.relativeTargetX) ? Direction.INSIDE : Direction.OUTSIDE;
      if ((lastEnteredTargetFrom == Direction.INSIDE && lastExitedTargetFrom == Direction.OUTSIDE) || (lastEnteredTargetFrom == Direction.OUTSIDE && lastExitedTargetFrom == Direction.INSIDE))
        overShoots++;
    }

  }
}
