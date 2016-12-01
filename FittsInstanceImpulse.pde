class FittsInstanceImpulse extends FittsInstance {
  boolean wasImpulseSinceLastEntry;

  public FittsInstanceImpulse(float relativeHeight, float relativeWidth, float relativeCenterX, float relativeCenterY, float relativeTargetX, float relativeTargetWidth) {
    super(relativeHeight, relativeWidth, relativeCenterX, relativeCenterY, relativeTargetX, relativeTargetWidth);
    wasImpulseSinceLastEntry = false;
  }


  public void update(long frameTimeMillis, HashMap<Action, Float> readings) {
    super.update(frameTimeMillis, readings);

    if (state.isCursorInTarget() && readings.get(Action.IMPULSE) > 0.0)
      wasImpulseSinceLastEntry = true;
    else if (!state.isCursorInTarget())
      wasImpulseSinceLastEntry = false;
  }

  public boolean isAcquired() {
     return state.isCursorInTarget() && wasImpulseSinceLastEntry;
  }

  protected void drawAcquiredTarget(HashMap<FittsComponent, Color> componentColors) {
    if (isAcquired()) {
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
      rect(targetX, centerY, targetWidth, absoluteHeight, cornerRadius);
    }
  }
}
