class ControlManager {
  private LibMyoProportional myoProportional;
  private float lastImpulseTime;

  public ControlManager(PApplet mainObject) throws MyoNotDetectectedError, CalibrationFailedException {
    myoProportional = new LibMyoProportional(mainObject);
    myoProportional.loadCalibrationSettings(settings.calibrationFile);
    myoProportional.enableEmgLogging(sketchPath() + "/data/" + settings.emgFile);
    lastImpulseTime = 0;
  }

  public HashMap<Action, Float> poll() {
    HashMap<Action, Float> readings = myoProportional.pollAndTrim(settings.controlPolicy);

    // allow a single impulse to occur per `timeBetweenImpulseMillis` 
    if (readings.get(Action.IMPULSE) > 0.0 && millis() > lastImpulseTime+settings.timeBetweenImpulseMillis)
      lastImpulseTime = millis();
    else
      readings.put(Action.IMPULSE, 0.0);

    return readings;
  }

  // TODO leaky interface
  public void flushEmgLog() {
    myoProportional.flushEmgLog();
  }
}
