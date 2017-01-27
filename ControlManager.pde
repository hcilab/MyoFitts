class ControlManager {
  private LibMyoProportional myoProportional;
  private float lastImpulseTime;

  public ControlManager(PApplet mainObject) throws MyoNotDetectectedError, CalibrationFailedException {
    myoProportional = new LibMyoProportional(mainObject);
    myoProportional.loadCalibrationSettings(settings.calibrationFile);
    lastImpulseTime = 0;
  }

  public HashMap<Action, Float> poll() {
    HashMap<Action, Float> readings = myoProportional.pollAndTrim(settings.controlPolicy);

    // high-pass filter using activationThreshold
    for (Action a : new Action[] {Action.LEFT, Action.RIGHT}) {
      if (readings.get(a) < settings.activationThreshold)
        readings.put(a, 0.0);
      else
        readings.put(a, scale(readings.get(a)));
    }

    // allow a single impulse to occur per `timeBetweenImpulseMillis` 
    if (readings.get(Action.IMPULSE) > 0.0 && millis() > lastImpulseTime+settings.timeBetweenImpulseMillis)
      lastImpulseTime = millis();
    else
      readings.put(Action.IMPULSE, 0.0);

    return readings;
  }

  // Intended for logging purposes only. This method bypasses both the
  // controlPolicy and activationThreshold specified in settings.
  public HashMap<Action, Float> pollRaw() {
    return myoProportional.poll(Policy.RAW);
  }

  private float scale(float reading) {
    // scale the reading so that the remaining range of input (i.e., above the activationThreshold) results in the full range of movement speeds
    return (reading-settings.activationThreshold) * (1.0/(1.0-settings.activationThreshold));
  }
}
