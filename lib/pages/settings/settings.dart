import 'package:flutter/material.dart';
import 'package:preference_list/preference_list.dart';

import '../../../includes.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Widget _buildBody(BuildContext context) {
    return PreferenceList(
      children: [
        PreferenceListSection(
          title: Text('Appearance'),
          children: [
            PreferenceListItem(
              title: Text('Theme Mode'),
              detailText: Text('Light'),
              onTap: () {},
            ),
          ],
        ),
        PreferenceListSection(
          title: Text('Shortcuts'),
          children: [
            PreferenceListItem(
              title: Text('Keyboard Shortcuts'),
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: _buildBody(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _build(context);
  }
}
