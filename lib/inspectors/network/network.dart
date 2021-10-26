import 'package:anyinspect_client/anyinspect_client.dart';
import 'package:anyinspect_ui/anyinspect_ui.dart';
import 'package:flutter/material.dart' hide DataTable;
import 'package:intl/intl.dart';

import 'network_record.dart';

class NetworkInspector extends StatefulWidget {
  final AnyInspectPlugin plugin;

  const NetworkInspector(
    this.plugin, {
    Key? key,
  }) : super(key: key);

  @override
  State<NetworkInspector> createState() => _NetworkInspectorState();
}

class _NetworkInspectorState extends State<NetworkInspector> {
  final List<NetworkRecord> _records = [];

  NetworkRecord? _selectedRecord;

  @override
  void initState() {
    widget.plugin.receive('request', (data) {
      NetworkRecordRequest req = NetworkRecordRequest.fromJson(data);
      _onRequest(req);
    });
    widget.plugin.receive('response', (data) {
      NetworkRecordResponse res = NetworkRecordResponse.fromJson(data);
      _onResponse(res);
    });
    super.initState();
  }

  void _onRequest(NetworkRecordRequest request) {
    NetworkRecord record = NetworkRecord(
      id: request.requestId,
      request: request,
    );
    _records.add(record);
    setState(() {});
  }

  void _onResponse(NetworkRecordResponse response) {
    int recordIndex = _records.indexWhere((e) => e.id == response.requestId);
    if (recordIndex != -1) {
      _records[recordIndex].response = response;
      setState(() {});
    }
  }

  List<DataColumn> _buildDataColumns() {
    return const [
      DataColumn(
        label: Text('Method'),
      ),
      DataColumn(
        label: Text('Uri'),
      ),
      DataColumn(
        label: Text('Status'),
      ),
      DataColumn(
        label: Text('Duration'),
      ),
      DataColumn(
        label: Text('Timestamp'),
      ),
    ];
  }

  List<DataRow> _buildDataRows() {
    List<DataRow> rows = [];
    for (var record in _records) {
      NetworkRecordRequest request = record.request!;
      NetworkRecordResponse? response = record.response;

      DataRow dataRow = DataRow(
        selected: _selectedRecord?.id == record.id,
        onSelectChanged: (bool? selected) {
          if (selected != null && selected) {
            _selectedRecord = record;
          }
          setState(() {});
        },
        cells: <DataCell>[
          DataCell(
            Text(request.method),
          ),
          DataCell(
            Text(
              request.uri,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          DataCell(
            Builder(
              builder: (_) {
                if (response != null) {
                  return Text('${response.statusCode}');
                }
                return Container();
              },
            ),
          ),
          DataCell(
            Builder(
              builder: (_) {
                if (response != null) {
                  Duration duration = Duration(
                    milliseconds: response.timeStamp - request.timeStamp,
                  );
                  return Text('${duration.inMilliseconds} ms');
                }
                return Container();
              },
            ),
          ),
          DataCell(
            Text(
              DateFormat('HH:mm:ss').format(
                DateTime.fromMillisecondsSinceEpoch(request.timeStamp),
              ),
            ),
          ),
        ],
      );
      rows.add(dataRow);
    }
    return rows;
  }

  Widget _buildSelectedRecordViewer(BuildContext context) {
    NetworkRecordRequest request = _selectedRecord!.request!;
    NetworkRecordResponse? response = _selectedRecord!.response;

    return DataViewer(
      children: [
        DataViewerSection(
          title: const Text('General'),
          children: [
            DataViewerItem(
              title: const Text('Request URL'),
              detailText: Text(request.uri),
            ),
            DataViewerItem(
              title: const Text('Request Method'),
              detailText: Text(request.method),
            ),
            if (response != null)
              DataViewerItem(
                title: const Text('Status Code'),
                detailText: Text('${response.statusCode}'),
              ),
          ],
        ),
        DataViewerSection(
          title: const Text('Request Headers'),
          children: [
            for (var key in (request.headers.keys))
              DataViewerItem(
                title: Text(key),
                detailText: Text('${request.headers[key]}'),
              ),
          ],
        ),
        DataViewerSection(
          title: const Text('Request Body'),
          children: [
            if (request.body != null)
              Padding(
                padding: const EdgeInsets.only(left: 14, right: 14),
                child: Text(
                  request.body,
                ),
              ),
          ],
        ),
        if (response != null)
          DataViewerSection(
            title: const Text('Response Headers'),
            children: [
              for (var key in (response.headers.keys))
                DataViewerItem(
                  title: Text(key),
                  detailText: Text('${response.headers[key]}'),
                ),
            ],
          ),
        if (response != null)
          DataViewerSection(
            title: const Text('Response Body'),
            children: [
              if (response.body != null)
                Padding(
                  padding: const EdgeInsets.only(left: 14, right: 14),
                  child: Text(
                    response.body,
                  ),
                ),
            ],
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Inspector(
      child: DataTable(
        initialColumnWeights: const [1, 4, 1, 1, 1],
        columns: _buildDataColumns(),
        rows: _buildDataRows(),
      ),
      detailView:
          _selectedRecord == null ? null : _buildSelectedRecordViewer(context),
    );
  }
}
