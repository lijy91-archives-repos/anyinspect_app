import 'package:anyinspect_app/includes.dart';
import 'package:dio/dio.dart';

import 'apis/versions.dart';
import 'api_client_interceptor.dart';

class ApiClient {
  static String guestKey = '';

  ApiClient._() {
    BaseOptions options = BaseOptions(
      baseUrl: Env.instance.apiUrl,
      connectTimeout: 60000,
      receiveTimeout: 60000,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      },
      responseType: ResponseType.json,
    );
    _http = Dio(options);
    _http.interceptors.add(ApiClientInterceptor());

    _versionsApi = VersionsApi(_http);
  }

  /// The shared instance of [ApiClient].
  static final ApiClient instance = ApiClient._();

  late Dio _http;

  late VersionsApi _versionsApi;

  void setDebug() {
    _http.options.baseUrl = 'http://127.0.0.1:8080';
  }

  VersionsApi get versions => version(null);

  VersionsApi version(String? id) {
    _versionsApi.setVersionId(id);
    return _versionsApi;
  }
}
