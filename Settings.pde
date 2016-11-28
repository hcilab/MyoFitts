enum AcquisitionPolicy {DWELL, IMPULSE};

class Settings {
  // general settings
  public String calibrationFile;
  public String inputFile; 
  public String logFile;
  public int dof;

  // control related
  public Policy controlPolicy;
  public float activationThreshold;
  public float timeBetweenImpulseMillis;

  // fitts related
  public float travelTimeMillis;
  public float dwellTimeMillis;
  public AcquisitionPolicy acquisitionPolicy;

  public Settings(String filename) {
    JSONObject s = loadJSONObject(filename);

    calibrationFile = s.getString("calibrationFile");
    inputFile = s.getString("inputFile");
    logFile = s.getString("logFile");
    dof = s.getInt("dof");

    controlPolicy = parseControlPolicy(s.getString("controlPolicy"));
    activationThreshold = s.getFloat("activationThreshold");
    timeBetweenImpulseMillis = s.getFloat("timeBetweenImpulseMillis");

    travelTimeMillis = s.getFloat("travelTimeMillis");
    dwellTimeMillis = s.getFloat("dwellTimeMillis");
    acquisitionPolicy = parseAcquisitionPolicy(s.getString("acquisitionPolicy"));
  }

  private Policy parseControlPolicy(String policyName) {
    Policy p = null;
    switch (policyName) {
      case "raw":
        p = Policy.RAW;
        break;
      case "maximum":
        p = Policy.MAXIMUM;
        break;
      case "difference":
        p = Policy.DIFFERENCE;
        break;
      case "first_over":
        p = Policy.FIRST_OVER;
        break;
    }

    assert (p != null);
    return p;

  }

  private AcquisitionPolicy parseAcquisitionPolicy(String policyName) {
    AcquisitionPolicy p = null;
    switch (policyName) {
      case "dwell":
        p = AcquisitionPolicy.DWELL;
        break;
      case "impulse":
        p = AcquisitionPolicy.IMPULSE;
        break;
    }

    assert (p != null);
    return p;
  }
}
