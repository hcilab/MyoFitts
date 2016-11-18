class FittsState {
  // Specified in the range [-1.0, 1.0]
  //  - negative numbers imply left
  //  - positive numbers imply right
  public float relativeCursorX;
  public float relativeTargetX;

  // Specified in the range [0.0, 1.0]
  //  - 0.0 is no width
  //  - 1.0 is entire instance width
  public float relativeTargetWidth;

  public FittsState() {}

  public FittsState(float relativeCursorX, float relativeTargetX, float relativeTargetWidth) {
    this.relativeCursorX = relativeCursorX;
    this.relativeTargetX = relativeTargetX;
    this.relativeTargetWidth = relativeTargetWidth;
  }

  public FittsState clone() {
    return new FittsState(relativeCursorX, relativeTargetX, relativeTargetWidth);
  }

  public boolean isCursorInTarget() {
    return relativeCursorX >= relativeTargetX - relativeTargetWidth && relativeCursorX <= relativeTargetX + relativeTargetWidth;
  }

}
