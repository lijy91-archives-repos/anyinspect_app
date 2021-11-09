import 'package:anyinspect_client/anyinspect_client.dart';
import 'package:anyinspect_ui/anyinspect_ui.dart';
import 'package:flutter/material.dart' hide DataTable;

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
    with AnyInspectPluginEventListener {
  final List<Map<String, dynamic>> _records = [];

  @override
  void initState() {
    widget.plugin.addEventListener(this);
    widget.plugin.callMethod('getAll');
    super.initState();
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
    }
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
            Text(record['key']),
          ),
          DataCell(
            Text('${record['value']}'),
          ),
        ],
      );
      rows.add(dataRow);
    }
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    return Inspector(
      child: DataTable(
        initialColumnWeights: const [2, 3],
        columns: _buildDataColumns(),
        rows: _buildDataRows(),
      ),
    );
  }
}
