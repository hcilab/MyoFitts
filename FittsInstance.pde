import java.util.HashMap;

enum FittsComponent {CURSOR, TARGET_FREE, TARGET_ACQUIRED, BACKGROUND};

class FittsInstance {
  // Specified in the range [-1.0, 1.0].
  //  - (0, 0) is the center of the screen
  //  - negative numbers imply left/up
  //  - positive numbers imply right/down
  private float relativeCenterX;
  private float relativeCenterY;

  // Specified in the range [0.0, 1.0]
  //  - 0.0 is no height/width
  //  - 1.0 is entire screen height/width
  private float relativeHeight;
  private float relativeWidth;

  private FittsState currentState;
  private FittsState previousState;
  private FittsStatistics statistics;

  private float currentDwellTimeMillis;

  public FittsInstance(float relativeHeight, float relativeWidth, float relativeCenterX, float relativeCenterY, float relativeTargetX, float relativeTargetWidth) {
    this.relativeHeight = relativeHeight;
    this.relativeWidth = relativeWidth;
    this.relativeCenterX = relativeCenterX;
    this.relativeCenterY = relativeCenterY;

    currentState = new FittsState(0.0, relativeTargetX, relativeTargetWidth);
    previousState = currentState.clone();
    statistics = new FittsStatistics(relativeTargetX, relativeTargetWidth);

    currentDwellTimeMillis = 0;
  }

  public void update(float frameTimeMillis, HashMap<Action, Float> readings) {
    updateState(frameTimeMillis, readings);
    statistics.update(frameTimeMillis, currentState, previousState);

    updateDwellTime(frameTimeMillis);
  }

  private void updateState(float frameTimeMillis, HashMap<Action, Float> readings) {
    float speed = readings.get(Action.RIGHT) - readings.get(Action.LEFT);
    float newX = currentState.relativeCursorX + speed*(frameTimeMillis/settings.travelTimeMillis);
    newX = max(-1.0, newX);
    newX = min(newX, 1.0);

    previousState = currentState;
    currentState = previousState.clone();
    currentState.relativeCursorX = newX;
  }

  private void updateDwellTime(float frameTimeMillis) {
    if (currentState.isCursorInTarget())
      currentDwellTimeMillis += frameTimeMillis;
    else
      currentDwellTimeMillis = 0;
  }

  public void draw(HashMap<FittsComponent, Color> componentColors) {
    // dynamically calculate locations in pixel-space (allows for resizing)
    float instanceWidth = relativeWidth*width;
    float instanceHeight = relativeHeight*height;
    float instanceCenterX = (width/2) + (relativeCenterX*(width/2));
    float instanceCenterY = (height/2) + (relativeCenterY*(height/2));
    float instanceBackgroundCornerRadius = instanceHeight/10;
    float instanceTargetX = instanceCenterX + currentState.relativeTargetX*(instanceWidth/2);
    float instanceTargetWidth = currentState.relativeTargetWidth * instanceWidth;
    float instanceTargetCornerRadius = instanceHeight/10;
    float instanceCursorX = instanceCenterX + currentState.relativeCursorX*(instanceWidth/2);
    float instanceCursorWidth = 0.05*instanceWidth;
    float instanceCursorCornerRadius = instanceHeight/15;

    rectMode(CENTER);

    // draw background
    stroke(componentColors.get(FittsComponent.BACKGROUND).getRGB());
    fill(componentColors.get(FittsComponent.BACKGROUND).getRGB());
    rect(instanceCenterX, instanceCenterY, instanceWidth, 0.7*instanceHeight, instanceBackgroundCornerRadius);

    // draw red target
    stroke(componentColors.get(FittsComponent.TARGET_FREE).getRGB());
    fill(componentColors.get(FittsComponent.TARGET_FREE).getRGB());
    rect(instanceTargetX, instanceCenterY, instanceTargetWidth, instanceHeight, instanceTargetCornerRadius);

    // draw green target (when appropriate)
    if (currentState.isCursorInTarget()) {
      stroke(componentColors.get(FittsComponent.TARGET_ACQUIRED).getRGB());
      fill(componentColors.get(FittsComponent.TARGET_ACQUIRED).getRGB());
      float percentComplete = min(1.0, currentDwellTimeMillis/settings.dwellTimeMillis);
      rect(instanceTargetX, instanceCenterY, instanceTargetWidth, percentComplete*instanceHeight, instanceTargetCornerRadius);
    }

    // draw cursor
    stroke(componentColors.get(FittsComponent.CURSOR).getRGB());
    fill(componentColors.get(FittsComponent.CURSOR).getRGB());
    rect(instanceCursorX, instanceCenterY, instanceCursorWidth, 0.8*instanceHeight, instanceCursorCornerRadius);
  }

  public boolean isAcquired() {
     return currentState.isCursorInTarget() && currentDwellTimeMillis > settings.dwellTimeMillis;
  }

  public FittsStatistics getStatistics() {
    return statistics;
  }
}
