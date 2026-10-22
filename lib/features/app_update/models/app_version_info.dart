class AppVersionInfo {
  const AppVersionInfo({
    required this.latestVersion,
    required this.minVersion,
    required this.iosStoreUrl,
    required this.androidStoreUrl,
    required this.message,
  });

  final String latestVersion;
  final String minVersion;
  final String iosStoreUrl;
  final String androidStoreUrl;
  final String message;

  factory AppVersionInfo.fromJson(Map<String, dynamic> json) {
    String read(String key) => (json[key] as String?)?.trim() ?? '';

    return AppVersionInfo(
      latestVersion: read('latestVersion'),
      minVersion: read('minVersion'),
      iosStoreUrl: read('iosStoreUrl'),
      androidStoreUrl: read('androidStoreUrl'),
      message: read('message'),
    );
  }
}

enum AppUpdateKind { none, soft, force }

class AppUpdateRequirement {
  const AppUpdateRequirement({
    required this.kind,
    required this.latestVersion,
    required this.storeUrl,
    required this.message,
  });

  final AppUpdateKind kind;
  final String latestVersion;
  final String storeUrl;
  final String message;

  bool get shouldPrompt => kind != AppUpdateKind.none;
}
