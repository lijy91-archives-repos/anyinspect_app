import 'dart:io';

import 'package:uuid/uuid.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

const kAppBuildNumber = '1';

Future<void> initEnv() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  Env.instance.appBuildNumber = int.parse(packageInfo.buildNumber.isEmpty
      ? kAppBuildNumber
      : packageInfo.buildNumber);
  Env.instance.appVersion = packageInfo.version;

  final docDir = await getApplicationDocumentsDirectory();
  final homeDir = docDir.parent;

  Env.instance.dataDirectory = Directory('${homeDir.path}/.anyinspect');
  if (!Env.instance.dataDirectory.existsSync()) {
    Env.instance.dataDirectory.createSync(recursive: true);
  }
  File guestKeyFile =
      File('${Env.instance.dataDirectory.path}/device_unique_id');
  if (guestKeyFile.existsSync()) {
    Env.instance.deviceUniqueId = await guestKeyFile.readAsString();
  } else {
    Env.instance.deviceUniqueId = const Uuid().v4();
    guestKeyFile.writeAsStringSync(Env.instance.deviceUniqueId);
  }
}

class Env {
  Env._();

  /// The shared instance of [Env].
  static final Env instance = Env._();

  late Directory dataDirectory;

  String deviceUniqueId = const Uuid().v4();

  int appBuildNumber = 0;
  String appVersion = '0.0.0';

  String webUrl = 'https://www.anyinspect.dev';
  String apiUrl = 'https://anyinspect-api.leanflutter.com';
}
