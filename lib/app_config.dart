class AppConfig {
  static const String version = '1.0.1';
  static const String buildNumber = '100';
  static const String stage = 'BETA';

  /// Display version for dashboard (v1.0.1)
  static String get displayVersion => 'v$version';

  /// Full version for settings (1.0.1-BETA_BUILD_100)
  static String get fullVersion => '$version-${stage}_BUILD_$buildNumber';
}
