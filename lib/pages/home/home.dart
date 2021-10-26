import 'dart:io';

import 'package:anyinspect_client/anyinspect_client.dart';
import 'package:anyinspect_server/anyinspect_server.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'package:multi_split_view/multi_split_view.dart';

import '../../includes.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AnyInspectServerListener {
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
  }

  @override
  void dispose() {
    AnyInspectServer.instance.removeListener(this);
    super.dispose();
  }

  Widget _buildPageSidebar(BuildContext context) {
    return Sidebar(
      children: [
        if (Platform.isMacOS) const SizedBox(height: 22),
        if (_selectedClientId != null)
          _SidebarHeader(
            clients: _clients,
            selectedClient: selectedClient,
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
                          color: const Color(0xffbfbfbf),
                          // color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        width: 25,
                        height: 25,
                        child: const Icon(
                          SFSymbols.cube,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                      title: Container(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(plugin.id),
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
        const SizedBox(height: 4),
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
          return const Center(
            child: Text('NO APPLICATIONS FOUND'),
          );
        }
        return Container(
          margin: const EdgeInsets.only(right: 14),
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
              dividerThickness: 14,
              dividerPainter: DividerPainters.grooved1(),
            ),
          ),
        );
      }),
    );
  }

  @override
  void onClientConnect(AnyInspectClient client) {
    _clients = AnyInspectServer.instance.allClients;
    _selectedClientId = _clients.first.id;
    setState(() {});
  }

  @override
  void onClientDisconnect(AnyInspectClient client) {
    _clients = AnyInspectServer.instance.allClients;
    setState(() {});
  }
}

class _SidebarHeader extends StatelessWidget {
  final List<AnyInspectClient> clients;
  final AnyInspectClient selectedClient;

  const _SidebarHeader({
    Key? key,
    required this.clients,
    required this.selectedClient,
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
              for (AnyInspectClient client in clients)
                MenuItem(
                  title: Text('${client.deviceName ?? client.deviceId ?? ''}'),
                  selected: false,
                  onTap: () async {},
                ),
              MenuItem(
                title: const Text('APP2'),
                selected: false,
                onTap: () async {},
              ),
              MenuItem(
                title: const Text('APP3'),
                selected: false,
                onTap: () async {},
              ),
              MenuItem(
                title: const Text('APP4'),
                selected: false,
                onTap: () async {},
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
                  borderRadius: BorderRadius.circular(6),
                ),
                margin: const EdgeInsets.only(
                  left: 14,
                  right: 14,
                  top: 14,
                ),
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      width: 28,
                      height: 28,
                      margin: const EdgeInsets.only(right: 8),
                    ),
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
          margin: const EdgeInsets.only(top: 14, bottom: 14),
          child: MenuItem(
            icon: Icon(
              SFSymbols.gear_alt,
              size: 18,
              color: Theme.of(context).textTheme.bodyText2!.color!,
            ),
            title: const Text('Settings'),
            detailText: Padding(
              padding: const EdgeInsets.only(),
              child: Text(
                '${Env.instance.appVersion}+${Env.instance.appBuildNumber}',
                style: TextStyle(
                  color: Theme.of(context)
                      .textTheme
                      .bodyText2!
                      .color!
                      .withOpacity(0.5),
                ),
              ),
            ),
            onTap: () {
              Size size = MediaQuery.of(context).size;
              Future<void> future = showDialog(
                context: context,
                builder: (ctx) {
                  return Center(
                    child: SizedBox(
                      width: size.width * 0.6,
                      height: size.height * 0.8,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: const SettingsPage(),
                      ),
                    ),
                  );
                },
              );
              future.whenComplete(() => {});
            },
          ),
        ),
      ],
    );
  }
}
