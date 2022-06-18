class NetworkRecord {
  final String id;
  NetworkRecordRequest? request;
  NetworkRecordResponse? response;

  NetworkRecord({
    required this.id,
    this.request,
    this.response,
  });
}

class NetworkRecordRequest {
  String requestId;
  int timeStamp;
  Map<String, dynamic> headers;
  String method;
  String uri;
  dynamic body;

  NetworkRecordRequest({
    required this.requestId,
    required this.timeStamp,
    required this.headers,
    required this.method,
    required this.uri,
    required this.body,
  });

  factory NetworkRecordRequest.fromJson(Map<String, dynamic> json) {
    return NetworkRecordRequest(
      requestId: json['requestId'],
      timeStamp: json['timeStamp'],
      headers: json['headers'],
      method: json['method'],
      uri: json['uri'],
      body: json['body'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'requestId': requestId,
      'timeStamp': timeStamp,
      'headers': headers,
      'method': method,
      'uri': uri,
      'body': body,
    }..removeWhere((key, value) => value == null);
  }

  String toCurl() {
    final StringBuffer sb = StringBuffer();
    sb.write('curl -X ${method} "${uri}"');
    if (body != null) {
      sb.write(' -d \'${body}\'');
    }
    for (var key in headers.keys) {
      sb.write(' -H \'$key: ${headers[key]}\'');
    }
    return sb.toString();
  }
}

class NetworkRecordResponse {
  String requestId;
  int timeStamp;
  int statusCode;

  Map<String, dynamic> headers;
  dynamic body;

  NetworkRecordResponse({
    required this.requestId,
    required this.timeStamp,
    required this.statusCode,
    required this.headers,
    required this.body,
  });
  factory NetworkRecordResponse.fromJson(Map<String, dynamic> json) {
    return NetworkRecordResponse(
      requestId: json['requestId'],
      timeStamp: json['timeStamp'],
      statusCode: json['statusCode'],
      headers: json['headers'],
      body: json['body'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'requestId': requestId,
      'timeStamp': timeStamp,
      'statusCode': statusCode,
      'headers': headers,
      'body': body,
    }..removeWhere((key, value) => value == null);
  }
}
