class FittsState {
  public long tod;

  // Specified in the range [-1.0, 1.0]
  //  - negative numbers imply left
  //  - positive numbers imply right
  public float relativeCursorX;
  public float relativeTargetX;

  // Specified in the range [0.0, 2.0]
  //  - 0.0 is no width
  //  - 2.0 is entire instance width
  public float relativeTargetWidth;

  public FittsState() {}

  public FittsState(long tod, float relativeCursorX, float relativeTargetX, float relativeTargetWidth) {
    this.tod = tod;
    this.relativeCursorX = relativeCursorX;
    this.relativeTargetX = relativeTargetX;
    this.relativeTargetWidth = relativeTargetWidth;
  }

  public FittsState clone() {
    return new FittsState(tod, relativeCursorX, relativeTargetX, relativeTargetWidth);
  }

  public boolean isCursorInTarget() {
    return relativeCursorX >= relativeTargetX - relativeTargetWidth/2 && relativeCursorX <= relativeTargetX + relativeTargetWidth/2;
  }

}
