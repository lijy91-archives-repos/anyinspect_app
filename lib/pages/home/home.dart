import 'dart:io';

import 'package:anyinspect_client/anyinspect_client.dart';
import 'package:anyinspect_server/anyinspect_server.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:preference_list/preference_list.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../includes.dart';

extension AnyInspectPluginExt on AnyInspectPlugin {
  IconData get icon {
    switch (id) {
      case 'network':
        return SFSymbols.globe;
      default:
    }
    return SFSymbols.cube_fill;
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AnyInspectServerListener {
  Version? _latestVersion;

  List<Device> _devices = [];
  List<AnyInspectClient> _clients = [];

  String? _selectedClientId;
  String? _selectedClientPluginId;

  AnyInspectClient get selectedClient {
    return _clients.firstWhere(
      (e) => e.id == _selectedClientId,
    );
  }

  AnyInspectPlugin get selectedClientPlugin {
    return selectedClient.plugins.firstWhere(
      (e) => e.id == _selectedClientPluginId,
    );
  }

  @override
  void initState() {
    AnyInspectServer.instance.addListener(this);
    super.initState();

    _loadData();
  }

  @override
  void dispose() {
    AnyInspectServer.instance.removeListener(this);
    super.dispose();
  }

  void _loadData() async {
    try {
      _latestVersion = await ApiClient.instance.version('latest').get();
      setState(() {});
    } catch (error) {}
  }

  Widget _buildPageSidebar(BuildContext context) {
    return Sidebar(
      children: [
        if (Platform.isMacOS) const SizedBox(height: 22),
        if (_selectedClientId != null)
          _SidebarHeader(
            devices: _devices,
            clients: _clients,
            selectedClient: selectedClient,
            onSelectedClientChanged: (newSelectedClient) {
              setState(() {
                _selectedClientId = newSelectedClient.id;
              });
            },
          ),
        const Divider(height: 0),
        const SizedBox(height: 4),
        Expanded(
          child: Menu(
            children: [
              MenuSection(
                title: const Text('PLUGINS'),
                children: [
                  for (AnyInspectPlugin plugin in (selectedClient.plugins))
                    MenuItem(
                      icon: Container(
                        margin: const EdgeInsets.only(top: 2, bottom: 2),
                        decoration: BoxDecoration(
                          // color: const Color(0xffbfbfbf),
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        width: 25,
                        height: 25,
                        child: Icon(
                          plugin.icon,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                      title: Container(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(plugin.name),
                      ),
                      selected: _selectedClientPluginId == plugin.id,
                      onTap: () async {
                        _selectedClientPluginId = plugin.id;
                        setState(() {});
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
        if (_latestVersion != null &&
            _latestVersion!.buildNumber > Env.instance.appBuildNumber)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(
              left: 14,
              right: 14,
              top: 14,
              bottom: 14,
            ),
            padding: const EdgeInsets.only(
              left: 12,
              right: 12,
              top: 12,
              bottom: 14,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Update available',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                Text.rich(
                  TextSpan(
                    text:
                        'AnyInspect version ${_latestVersion!.version} is now available. Click to ',
                    children: [
                      TextSpan(
                        text: 'download',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async {
                            await launch('${Env.instance.webUrl}/release-notes');
                          },
                      ),
                      const TextSpan(text: '.'),
                    ],
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        const Divider(height: 0),
        const _SidebarFooter(),
      ],
    );
  }

  Widget _buildPageContent(BuildContext context) {
    int index = selectedClient.plugins.indexWhere(
      (e) => e.id == _selectedClientPluginId,
    );
    if (index == -1) {
      return const Center(
        child: Text('NO PLUGIN SELECTED'),
      );
    }
    return IndexedStack(
      key: Key(_selectedClientId!),
      index: index,
      children: [
        for (var plugin in selectedClient.plugins)
          Builder(builder: (_) {
            switch (plugin.id) {
              case 'network':
                return NetworkInspector(plugin);
              case 'shared_preferences':
                return SharedPreferencesInspector(plugin);
            }
            return Container();
          }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(builder: (_) {
        Size size = MediaQuery.of(context).size;
        if (_clients.isEmpty || _selectedClientId == null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'NO APPLICATIONS FOUND',
                  style: TextStyle(fontSize: 16),
                ),
                CupertinoButton(
                  child: const Text('Adding to your app'),
                  onPressed: () async {
                    await launch('${Env.instance.webUrl}/docs');
                  },
                ),
              ],
            ),
          );
        }
        return Container(
          decoration: BoxDecoration(
            border: Platform.isWindows
                ? Border(top: BorderSide(color: Theme.of(context).dividerColor))
                : null,
          ),
          child: MultiSplitViewTheme(
            child: MultiSplitView(
              children: [
                _buildPageSidebar(context),
                Builder(builder: (_) {
                  if (_selectedClientId == null) {
                    return Container();
                  }
                  return _buildPageContent(context);
                }),
              ],
              controller: MultiSplitViewController(
                initialWeights: [280 / size.width],
              ),
            ),
            data: MultiSplitViewThemeData(
              dividerThickness: 1,
              dividerPainter: DividerPainters.background(
                color: Theme.of(context).dividerColor,
              ),
            ),
          ),
        );
      }),
    );
  }

  @override
  void onClientConnect(AnyInspectClient client) {
    _devices = AnyInspectServer.instance.allDevices;
    _clients = AnyInspectServer.instance.allClients;
    _selectedClientId = _clients.first.id;
    setState(() {});
  }

  @override
  void onClientDisconnect(AnyInspectClient client) {
    _devices = AnyInspectServer.instance.allDevices;
    _clients = AnyInspectServer.instance.allClients;
    setState(() {});
  }
}

class _SidebarHeader extends StatelessWidget {
  final List<Device> devices;
  final List<AnyInspectClient> clients;
  final AnyInspectClient selectedClient;
  final ValueChanged<AnyInspectClient> onSelectedClientChanged;

  const _SidebarHeader({
    Key? key,
    required this.devices,
    required this.clients,
    required this.selectedClient,
    required this.onSelectedClientChanged,
  }) : super(key: key);

  CancelFunc _show(BuildContext targetContext) {
    return BotToast.showAttachedWidget(
      targetContext: targetContext,
      onlyOne: true,
      attachedBuilder: (cancel) => Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Container(
          width: 240,
          decoration: BoxDecoration(
            color: Theme.of(targetContext).canvasColor,
            border: Border.all(
              color: Theme.of(targetContext).dividerColor,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(4),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(0.0, 6),
                blurRadius: 6,
              ),
            ],
          ),
          padding: const EdgeInsets.only(
            top: 6,
            bottom: 6,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (Device device in devices)
                MenuSection(
                  title: Text(device.name ?? device.id ?? ''),
                  children: [
                    for (AnyInspectClient client
                        in clients.where((e) => e.deviceId == device.id))
                      MenuItem(
                        title: Text(
                          client.appName ?? client.appIdentifier ?? '',
                        ),
                        selected: client.id == selectedClient.id,
                        onTap: () async {
                          onSelectedClientChanged(client);
                          cancel();
                        },
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String appIdentifier = selectedClient.appIdentifier!;
    String appName = selectedClient.appName!;
    String appVersion = selectedClient.appVersion!;
    String appBuildNumber = selectedClient.appBuildNumber!;
    return Column(
      children: [
        Builder(
          builder: (ctx) {
            return CupertinoButton(
              padding: EdgeInsets.zero,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                margin: const EdgeInsets.only(
                  left: 14,
                  right: 14,
                  top: 14,
                ),
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    // Container(
                    //   decoration: BoxDecoration(
                    //     color: Theme.of(context).primaryColor,
                    //     borderRadius: BorderRadius.circular(4),
                    //   ),
                    //   width: 28,
                    //   height: 28,
                    //   margin: const EdgeInsets.only(right: 8),
                    // ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$appName (v$appVersion+$appBuildNumber)',
                            style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyText2!.color,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            appIdentifier,
                            style: TextStyle(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyText2!
                                  .color!
                                  .withOpacity(0.5),
                              fontSize: 10,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      SFSymbols.chevron_up_chevron_down,
                      size: 15,
                      color: Theme.of(context)
                          .textTheme
                          .bodyText2!
                          .color!
                          .withOpacity(0.5),
                    ),
                  ],
                ),
              ),
              onPressed: () => _show(ctx),
            );
          },
        ),
        if (selectedClient.disconnected)
          Container(
            margin: const EdgeInsets.only(
              left: 14,
              right: 14,
              top: 6,
            ),
            child: Row(
              children: const [
                SizedBox(width: 2),
                Icon(
                  SFSymbols.info_circle,
                  size: 14,
                  color: Colors.red,
                ),
                SizedBox(width: 4),
                Text(
                  'APPLICATION DISCONNECTED',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 14),
      ],
    );
  }
}

class _SidebarFooter extends StatelessWidget {
  const _SidebarFooter({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(14),
          child: Row(
            children: [
              Text(
                '${Env.instance.appVersion}+${Env.instance.appBuildNumber}',
                style: TextStyle(
                  color: Theme.of(context)
                      .textTheme
                      .bodyText2!
                      .color!
                      .withOpacity(0.5),
                ),
              ),
              Expanded(child: Container()),
              SizedBox(
                width: 16,
                height: 16,
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: Image.asset(
                    'assets/images/github_mark.png',
                    width: 16,
                    height: 16,
                  ),
                  onPressed: () async {
                    await launch('https://github.com/anyinspect/anyinspect');
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
