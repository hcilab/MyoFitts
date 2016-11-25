class FittsInstanceImpulse extends FittsInstance {
  boolean wasImpulseSinceLastEntry;

  public FittsInstanceImpulse(float relativeHeight, float relativeWidth, float relativeCenterX, float relativeCenterY, float relativeTargetX, float relativeTargetWidth) {
    super(relativeHeight, relativeWidth, relativeCenterX, relativeCenterY, relativeTargetX, relativeTargetWidth);
    wasImpulseSinceLastEntry = false;
  }


  public void update(float frameTimeMillis, HashMap<Action, Float> readings) {
    super.update(frameTimeMillis, readings);

    if (currentState.isCursorInTarget() && readings.get(Action.IMPULSE) > 0.0)
      wasImpulseSinceLastEntry = true;
    else if (!currentState.isCursorInTarget())
      wasImpulseSinceLastEntry = false;
  }

  public boolean isAcquired() {
     return currentState.isCursorInTarget() && wasImpulseSinceLastEntry;
  }

  protected void drawAcquiredTarget(HashMap<FittsComponent, Color> componentColors) {
    if (isAcquired()) {
      // dynamically calculate locations (enables resizes)
      float absoluteWidth = relativeWidth*width;
      float absoluteHeight = relativeHeight*height;
      float centerX = (width/2) + (relativeCenterX*(width/2));
      float centerY = (height/2) + (relativeCenterY*(height/2));
      float targetX = centerX + currentState.relativeTargetX*(absoluteWidth/2);
      float targetWidth = currentState.relativeTargetWidth * absoluteWidth;
      float cornerRadius = absoluteHeight/10;

      rectMode(CENTER);
      stroke(componentColors.get(FittsComponent.TARGET_ACQUIRED).getRGB());
      fill(componentColors.get(FittsComponent.TARGET_ACQUIRED).getRGB());
      rect(targetX, centerY, targetWidth, absoluteHeight, cornerRadius);
    }
  }
}
