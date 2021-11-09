import 'dart:io';

import 'package:anyinspect_app/includes.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiClientInterceptor extends Interceptor {
  bool _isGettedDeviceInfo = false;

  String? _deviceUniqueId;
  String? _deviceBrand;
  String? _deviceModel;
  String? _deviceLanguage;
  String? _deviceSystem;
  String? _deviceSystemVersion;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_isGettedDeviceInfo) {
      DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

      if (!kIsWeb && Platform.isAndroid) {
        AndroidDeviceInfo info = (await _deviceInfo.androidInfo);
        _deviceUniqueId = info.androidId;
        _deviceBrand = info.brand;
        _deviceModel = info.model;
      } else if (!kIsWeb && Platform.isIOS) {
        IosDeviceInfo info = (await _deviceInfo.iosInfo);
        _deviceUniqueId = info.identifierForVendor;
        _deviceBrand = 'Apple';
        _deviceModel = info.utsname.machine;
      } else if (!kIsWeb && Platform.isLinux) {
      } else if (!kIsWeb && Platform.isMacOS) {
        MacOsDeviceInfo info = (await _deviceInfo.macOsInfo);
        _deviceBrand = 'Apple';
        _deviceModel = info.model;
      } else if (!kIsWeb && Platform.isWindows) {
        // WindowsDeviceInfo info = (await _deviceInfo.windowsInfo);
      }

      _deviceLanguage = Platform.localeName;
      _deviceSystem = Platform.operatingSystem;
      _deviceSystemVersion = Platform.operatingSystemVersion;
      _isGettedDeviceInfo = true;
    }

    options.headers["X-USER-DEVICE-UNIQUE-ID"] = (_deviceUniqueId ?? '').isEmpty
        ? Env.instance.deviceUniqueId
        : _deviceUniqueId;
    options.headers["X-USER-DEVICE-BRAND"] = _deviceBrand;
    options.headers["X-USER-DEVICE-MODEL"] = _deviceModel;
    options.headers["X-USER-DEVICE-LANGUAGE"] = _deviceLanguage;
    options.headers["X-USER-DEVICE-SYSTEM"] = _deviceSystem;
    options.headers["X-USER-DEVICE-SYSTEM-VERSION"] = _deviceSystemVersion;

    options.headers["X-USER-APP-BUILD-NUMBER"] = Env.instance.appBuildNumber;
    options.headers["X-USER-APP-VERSION"] = Env.instance.appVersion;

    handler.next(options);
  }
}
