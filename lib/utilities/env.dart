import 'package:package_info_plus/package_info_plus.dart';

const kAppBuildNumber = '1';

Future<void> initEnv() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  Env.instance.appBuildNumber = int.parse(packageInfo.buildNumber.isEmpty
      ? kAppBuildNumber
      : packageInfo.buildNumber);
  Env.instance.appVersion = packageInfo.version;
}

class Env {
  Env._();

  /// The shared instance of [Env].
  static final Env instance = Env._();

  int appBuildNumber = 0;
  String appVersion = '0.0.0';
}
