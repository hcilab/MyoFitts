class CountdownManager {

  private long elapsedTimeMillis;
  private long countdownDurationMillis;

  public CountdownManager(long countdownDurationMillis) {
    this.countdownDurationMillis = countdownDurationMillis;
    this.elapsedTimeMillis = 0;
  }

  public void update(long frameTimeMillis) {
    elapsedTimeMillis += frameTimeMillis;
  }

  public void reset() {
    elapsedTimeMillis = 0;
  }

  public boolean isDone() {
    return elapsedTimeMillis >= countdownDurationMillis;
  }

  public void draw() {
    if (!isDone()) {
      rectMode(CENTER);
      stroke(192, 192, 192, 200);
      fill(192, 192, 192, 200);
      rect(width/2, height/2, 1.1*width, 1.1*height);
    }
  }
}
