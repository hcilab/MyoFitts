enum Direction {INSIDE, OUTSIDE};


class FittsStatistics {
  public long tod;
  public float amplitude;
  public float width;

  public long elapsedTimeMillis;
  public float distanceTravelled;
  public int errors;
  public int overShoots;

  private Direction lastEnteredTargetFrom;

  private ArrayList<FittsState> states;

  public FittsStatistics () {
    this.tod = System.currentTimeMillis();
    this.amplitude = 0;
    this.width = 0;
    this.elapsedTimeMillis = 0;
    this.distanceTravelled = 0;
    this.errors = 0;
    this.overShoots = 0;

    if (settings.acquisitionPolicy == AcquisitionPolicy.DWELL)
      this.elapsedTimeMillis -= settings.dwellTimeMillis;

    // the initial value doesn't really matter
    lastEnteredTargetFrom = Direction.INSIDE;

    states = new ArrayList<FittsState>();
  }

  public void update(FittsState state) {
    states.add(state);
    if (states.size() < 2)
      return;

    FittsState currentState = states.get(states.size()-1);
    FittsState previousState = states.get(states.size()-2);

    // save "constants"
    this.amplitude = abs(currentState.relativeTargetX);
    this.width = currentState.relativeTargetWidth;

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

  public ArrayList<FittsState> getStates() {
    return states;
  }
}
