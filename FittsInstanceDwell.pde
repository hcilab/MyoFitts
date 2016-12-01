class FittsInstanceDwell extends FittsInstance {
  int currentDwellTimeMillis;

  public FittsInstanceDwell(float relativeHeight, float relativeWidth, float relativeCenterX, float relativeCenterY, float relativeTargetX, float relativeTargetWidth) {
    super(relativeHeight, relativeWidth, relativeCenterX, relativeCenterY, relativeTargetX, relativeTargetWidth);
    currentDwellTimeMillis = 0;
  }


  public void update(long frameTimeMillis, HashMap<Action, Float> readings) {
    super.update(frameTimeMillis, readings);
    if (state.isCursorInTarget())
      currentDwellTimeMillis += frameTimeMillis;
    else
      currentDwellTimeMillis = 0;
  }

  public boolean isAcquired() {
     return state.isCursorInTarget() && currentDwellTimeMillis > settings.dwellTimeMillis;
  }

  protected void drawAcquiredTarget(HashMap<FittsComponent, Color> componentColors) {
    if (state.isCursorInTarget()) {
      // dynamically calculate locations (enables resizes)
      float absoluteWidth = relativeWidth*width;
      float absoluteHeight = relativeHeight*height;
      float centerX = (width/2) + (relativeCenterX*(width/2));
      float centerY = (height/2) + (relativeCenterY*(height/2));
      float targetX = centerX + state.relativeTargetX*(absoluteWidth/2);
      float targetWidth = state.relativeTargetWidth*absoluteWidth / 2;
      float cornerRadius = absoluteHeight/10;

      rectMode(CENTER);
      stroke(componentColors.get(FittsComponent.TARGET_ACQUIRED).getRGB());
      fill(componentColors.get(FittsComponent.TARGET_ACQUIRED).getRGB());
      float percentComplete = min(1.0, currentDwellTimeMillis/settings.dwellTimeMillis);
      rect(targetX, centerY, targetWidth, percentComplete*absoluteHeight, cornerRadius);
    }
  }
}
