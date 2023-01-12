//TODO(AAllport): Make this work better, (maybe via some form of build script)
//NB: Tempted to do a sourcegen thing, since source-gen is not committed, and this sucks

class Env {
  static const PRODUCTION = 'prod';
  static const STAGING = 'stage';
  static const DEVELOPMENT = 'dev';
}

class BuildConfig {
  final String env;
  final String gMapsApiKey;
  final String apiUrl;
  final String apiClientId;
  final String apiClientSecret;

  BuildConfig({
    this.env = Env.PRODUCTION,
    required this.apiUrl,
    required this.apiClientId,
    required this.apiClientSecret,
    this.gMapsApiKey = "AIzaSyCeUX8xBTUC1cl718wxWxy84-ZnZhMUES4",
  });
}
