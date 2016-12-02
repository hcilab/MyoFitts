import java.util.HashMap;

enum FittsComponent {CURSOR, CROSSHAIR, TARGET_FREE, TARGET_ACQUIRED, BACKGROUND};

class FittsInstance {
  // Specified in the range [-1.0, 1.0].
  //  - (0, 0) is the center of the screen
  //  - negative numbers imply left/up
  //  - positive numbers imply right/down
  protected float relativeCenterX;
  protected float relativeCenterY;

  // Specified in the range [0.0, 1.0]
  //  - 0.0 is no height/width
  //  - 1.0 is entire screen height/width
  protected float relativeHeight;
  protected float relativeWidth;

  protected FittsState state;

  public FittsInstance(float relativeHeight, float relativeWidth, float relativeCenterX, float relativeCenterY, float relativeTargetX, float relativeTargetWidth) {
    this.relativeHeight = relativeHeight;
    this.relativeWidth = relativeWidth;
    this.relativeCenterX = relativeCenterX;
    this.relativeCenterY = relativeCenterY;

    state = new FittsState(System.currentTimeMillis(), 0.0, relativeTargetX, relativeTargetWidth);
  }

  public void update(long frameTimeMillis, HashMap<Action, Float> readings) {
    float speed = readings.get(Action.RIGHT) - readings.get(Action.LEFT);
    float newX = state.relativeCursorX + speed*(frameTimeMillis/settings.travelTimeMillis);
    newX = max(-1.0, newX);
    newX = min(newX, 1.0);

    state = state.clone();
    state.tod += frameTimeMillis;
    state.relativeCursorX = newX;
  }

  public FittsState getState() {
    return state;
  }

  public void draw(HashMap<FittsComponent, Color> componentColors) {
    drawBackground(componentColors);
    drawFreeTarget(componentColors);
    drawAcquiredTarget(componentColors);
    drawCursor(componentColors);
  }

  protected void drawBackground(HashMap<FittsComponent, Color> componentColors) {
    // dynamically calculate locations (enables resizes)
    float absoluteWidth = relativeWidth*width;
    float absoluteHeight = relativeHeight*height;
    float centerX = (width/2) + (relativeCenterX*(width/2));
    float centerY = (height/2) + (relativeCenterY*(height/2));
    float cornerRadius = absoluteHeight/10;

    rectMode(CENTER);
    stroke(componentColors.get(FittsComponent.BACKGROUND).getRGB());
    fill(componentColors.get(FittsComponent.BACKGROUND).getRGB());
    rect(centerX, centerY, absoluteWidth, 0.7*absoluteHeight, cornerRadius);
  }

  protected void drawFreeTarget(HashMap<FittsComponent, Color> componentColors) {
    // dynamically calculate locations (enables resizes)
    float absoluteWidth = relativeWidth*width;
    float absoluteHeight = relativeHeight*height;
    float centerX = (width/2) + (relativeCenterX*(width/2));
    float centerY = (height/2) + (relativeCenterY*(height/2));
    float targetX = centerX + state.relativeTargetX*(absoluteWidth/2);
    float targetWidth = state.relativeTargetWidth*absoluteWidth / 2;
    float cornerRadius = absoluteHeight/10;

    rectMode(CENTER);
    stroke(componentColors.get(FittsComponent.TARGET_FREE).getRGB());
    fill(componentColors.get(FittsComponent.TARGET_FREE).getRGB());
    rect(targetX, centerY, targetWidth, absoluteHeight, cornerRadius);
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
      rect(targetX, centerY, targetWidth, absoluteHeight, cornerRadius);
    }
  }

  protected void drawCursor(HashMap<FittsComponent, Color> componentColors) {
    // dynamically calculate locations (enables resizes)
    float absoluteWidth = relativeWidth*width;
    float absoluteHeight = relativeHeight*height;
    float centerX = (width/2) + (relativeCenterX*(width/2));
    float centerY = (height/2) + (relativeCenterY*(height/2));
    float cursorX = centerX + state.relativeCursorX*(absoluteWidth/2);
    float cursorWidth = 0.03*absoluteWidth;
    float crossHairWidth = 0.001*absoluteWidth;
    float cornerRadius = absoluteHeight/15;

    rectMode(CENTER);
    stroke(componentColors.get(FittsComponent.CURSOR).getRGB());
    fill(componentColors.get(FittsComponent.CURSOR).getRGB());
    rect(cursorX, centerY, cursorWidth, 0.8*absoluteHeight, cornerRadius);

    stroke(componentColors.get(FittsComponent.CROSSHAIR).getRGB());
    fill(componentColors.get(FittsComponent.CROSSHAIR).getRGB());
    rect(cursorX, centerY, crossHairWidth, 0.8*absoluteHeight);
  }

  public boolean isAcquired() {
     return state.isCursorInTarget();
  }
}
