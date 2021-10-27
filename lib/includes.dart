export './inspectors/inspectors.dart';
export './models/models.dart';
export './pages/pages.dart';
export './themes/themes.dart';
export './utilities/utilities.dart';
export './widgets/widgets.dart';

import 'package:anyinspect_server/anyinspect_server.dart';

import './models/models.dart';

extension AnyInspectServerExt on AnyInspectServer {
  List<Device> get allDevices {
    return allClients
        .map((e) => Device(
            id: e.deviceId,
            name: e.deviceName,
            isPhysical: e.deviceIsPhysical ?? false,
            system: e.deviceSystem!,
            systemVersion: e.deviceSystemVersion!))
        .toList();
  }
}
