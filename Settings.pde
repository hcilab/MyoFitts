class Settings {
  // general settings
  public String calibrationFile;
  public String inputFile; 
  public int dof;

  // control related
  public Policy controlPolicy;
  public float activationThreshold;
  public float timeBetweenImpulseMillis;

  // fitts related
  public float travelTimeMillis;
  public float dwellTimeMillis;


  public Settings(String filename) {
    JSONObject s = loadJSONObject(filename);

    calibrationFile = s.getString("calibrationFile");
    inputFile = s.getString("inputFile");
    dof = s.getInt("dof");

    controlPolicy = parseControlPolicy(s.getString("controlPolicy"));
    activationThreshold = s.getFloat("activationThreshold");
    timeBetweenImpulseMillis = s.getFloat("timeBetweenImpulseMillis");

    travelTimeMillis = s.getFloat("travelTimeMillis");
    dwellTimeMillis = s.getFloat("dwellTimeMillis");
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
}
