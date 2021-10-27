class Device {
  final String? id;
  final String? name;
  final bool isPhysical;
  final String system;
  final String systemVersion;

  Device({
    this.id,
    this.name,
    required this.isPhysical,
    required this.system,
    required this.systemVersion,
  });
}
