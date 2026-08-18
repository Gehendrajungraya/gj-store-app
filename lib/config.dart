class AppConfig {
  static const String baseUrl = 'https://gehendrajung.com.np';
  static const String apiBase = '$baseUrl/wp-json/gjps/v1';
  static const String appName = 'GJ Store';

  // There is no verified WordPress auth endpoint exposed for this site.
  // Keep auth disabled until the production API confirms a valid login/register route.
  static const bool authEnabled = false;
  static const String? loginPath = null;
  static const String? registerPath = null;

  static const String authTokenKey = 'auth_token';
  static const String userNameKey = 'user_name';

  // Keep false until your production API is confirmed to require a token.
  static const bool useBearerToken = false;
}
