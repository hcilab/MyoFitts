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

  // Normalized to the range [0.0, 1.0], but values can exceed upper limit when
  // muscle contraction exceeds calibrated max threshold.
  //  - 0.0 no muscle activity
  //  - 1.0 contraction matching maximum calibrated threshold
  //  - > 1.0 contraction exceeding maximum calibrated threshold
  public float emgLeft;
  public float emgRight;

  public FittsState() {}

  public FittsState(long tod, float relativeCursorX, float relativeTargetX, float relativeTargetWidth) {
    this(tod, relativeCursorX, relativeTargetX, relativeTargetWidth, 0.0, 0.0);
  }

  public FittsState(long tod, float relativeCursorX, float relativeTargetX, float relativeTargetWidth, float emgLeft, float emgRight) {
    this.tod = tod;
    this.relativeCursorX = relativeCursorX;
    this.relativeTargetX = relativeTargetX;
    this.relativeTargetWidth = relativeTargetWidth;
    this.emgLeft = emgLeft;
    this.emgRight = emgRight;
  }

  public FittsState clone() {
    return new FittsState(tod, relativeCursorX, relativeTargetX, relativeTargetWidth, emgLeft, emgRight);
  }

  public boolean isCursorInTarget() {
    return relativeCursorX >= relativeTargetX - relativeTargetWidth/2 && relativeCursorX <= relativeTargetX + relativeTargetWidth/2;
  }

}
