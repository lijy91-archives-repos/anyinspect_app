import 'dart:math' as math;

import 'package:anyinspect_client/anyinspect_client.dart';
import 'package:anyinspect_ui/anyinspect_ui.dart';
import 'package:flutter/material.dart' hide DataTable;
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';

class SharedPreferencesInspector extends StatefulWidget {
  final AnyInspectPlugin plugin;

  const SharedPreferencesInspector(
    this.plugin, {
    Key? key,
  }) : super(key: key);

  @override
  State<SharedPreferencesInspector> createState() =>
      _SharedPreferencesInspectorState();
}

class _SharedPreferencesInspectorState extends State<SharedPreferencesInspector>
    with SingleTickerProviderStateMixin, AnyInspectPluginEventListener {
  late AnimationController _animationController;

  List<Map<String, dynamic>> _records = [];

  @override
  void initState() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    widget.plugin.addEventListener(this);
    super.initState();

    _getAll();
  }

  @override
  void dispose() {
    widget.plugin.removeEventListener(this);
    super.dispose();
  }

  @override
  void onEvent(AnyInspectPluginEvent event) {
    if (event.name == 'getAllSuccess') {
      List<Map<String, dynamic>> list =
          List<Map<String, dynamic>>.from(event.arguments['list']);

      setState(() {
        _records.clear();
        _records.addAll(list);
      });

      Future.delayed(const Duration(seconds: 1)).then((_) {
        _animationController.stop();
      });
    }
  }

  void _getAll() {
    _animationController.repeat();
    widget.plugin.callMethod('getAll');
  }

  List<DataColumn> _buildDataColumns() {
    return const [
      DataColumn(
        label: Text('Key'),
      ),
      DataColumn(
        label: Text('Value'),
      ),
    ];
  }

  List<DataRow> _buildDataRows() {
    List<DataRow> rows = [];
    for (var record in _records) {
      DataRow dataRow = DataRow(
        onSelectChanged: (bool? selected) {},
        cells: <DataCell>[
          DataCell(
            SelectableText(record['key']),
          ),
          DataCell(
            SelectableText('${record['value']}'),
          ),
        ],
      );
      rows.add(dataRow);
    }
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Inspector(
          child: DataTable(
            initialColumnWeights: const [2, 3],
            columns: _buildDataColumns(),
            rows: _buildDataRows(),
          ),
        ),
        Positioned(
          right: 60,
          bottom: 60,
          child: FloatingActionButton.small(
            backgroundColor: Theme.of(context).primaryColor,
            child: AnimatedBuilder(
              animation: _animationController,
              child: const Icon(
                SFSymbols.arrow_2_circlepath,
                size: 20,
              ),
              builder: (_, Widget? child) {
                return Transform.rotate(
                  angle: _animationController.value * 2.0 * math.pi,
                  child: child,
                );
              },
            ),
            onPressed: () {
              _getAll();
            },
          ),
        ),
      ],
    );
  }
}
