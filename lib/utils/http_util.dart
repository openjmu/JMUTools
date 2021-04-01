///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2021-04-01 21:08
///
import 'dart:convert';
import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart' as web_view
    show Cookie, CookieManager;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

import 'package:jmu_tools/apis/user_api.dart';
import 'package:jmu_tools/exports/models.dart';
import 'package:jmu_tools/exports/utils.dart';
import 'package:permission_handler/permission_handler.dart';

enum FetchType { head, get, post, put, patch, delete }

class HttpUtil {
  const HttpUtil._();

  static const bool _isProxyEnabled = false;
  static const String _proxyDestination = 'PROXY 192.168.1.23:8764';

  static const bool shouldLogRequest = false;

  static final Dio dio = Dio(
    BaseOptions(connectTimeout: 15000, followRedirects: true),
  );
  static final Dio tokenDio = Dio(
    BaseOptions(connectTimeout: 15000, followRedirects: true),
  );

  static late final PersistCookieJar cookieJar;
  static late final PersistCookieJar tokenCookieJar;
  static late final CookieManager cookieManager;
  static late final CookieManager tokenCookieManager;
  static final web_view.CookieManager webViewCookieManager =
      web_view.CookieManager.instance();

  static late final Directory _tempDir;

  static bool isLogEnabled = true;

  static Future<void> initConfig() async {
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        _clientCreate;
    (tokenDio.httpClientAdapter as DefaultHttpClientAdapter)
        .onHttpClientCreate = _clientCreate;

    dio.interceptors..add(_interceptor)..add(cookieManager);
    tokenDio.interceptors..add(_interceptor)..add(tokenCookieManager);

    if (shouldLogRequest) {
      dio.interceptors.add(LoggingInterceptor());
      tokenDio.interceptors.add(LoggingInterceptor());
    }
  }

  static Future<void> initCookieManagement() async {
    _tempDir = await getTemporaryDirectory();
    // Initialize cookie jars.
    if (!Directory('${_tempDir.path}/cookie_jar').existsSync()) {
      Directory('${_tempDir.path}/cookie_jar').createSync();
    }
    if (!Directory('${_tempDir.path}/token_cookie_jar').existsSync()) {
      Directory('${_tempDir.path}/token_cookie_jar').createSync();
    }
    if (!Directory('${_tempDir.path}/web_view_cookie_jar').existsSync()) {
      Directory('${_tempDir.path}/web_view_cookie_jar').createSync();
    }
    cookieJar = PersistCookieJar(
      storage: FileStorage('${_tempDir.path}/cookie_jar'),
    );
    tokenCookieJar = PersistCookieJar(
      storage: FileStorage('${_tempDir.path}/token_cookie_jar'),
    );
    cookieManager = CookieManager(cookieJar);
    tokenCookieManager = CookieManager(tokenCookieJar);
  }

  static Future<T> fetch<T>(
    FetchType fetchType, {
    required String url,
    Map<String, String>? queryParameters,
    dynamic? body,
    Map<String, dynamic>? headers,
    ResponseType responseType = ResponseType.json,
  }) async {
    final Response<T> response = await _getResponse(
      fetchType,
      url: url,
      queryParameters: queryParameters,
      body: body,
      headers: headers,
      responseType: responseType,
    );
    return response.data as T;
  }

  static Future<T> fetchModel<T extends DataModel>(
    FetchType fetchType, {
    required String url,
    Map<String, String>? queryParameters,
    dynamic? body,
    Map<String, dynamic>? headers,
    ResponseType responseType = ResponseType.json,
  }) async {
    final Response<Map<String, dynamic>> response = await _getResponse(
      fetchType,
      url: url,
      queryParameters: queryParameters,
      body: body,
      headers: headers,
      responseType: responseType,
    );

    final Map<String, dynamic> resBody = response.data!;
    final T model = makeModel<T>(resBody);
    if (isLogEnabled) {
      LogUtil.d('Response model: $model');
    }
    return model;
  }

  static Future<List<T>> fetchModels<T extends DataModel>(
    FetchType fetchType, {
    required String url,
    Map<String, String>? queryParameters,
    dynamic? body,
    Map<String, dynamic>? headers,
    ResponseType responseType = ResponseType.json,
  }) async {
    final Response<List<Map<dynamic, dynamic>>> response = await _getResponse(
      fetchType,
      url: url,
      queryParameters: queryParameters,
      body: body,
      headers: headers,
      responseType: responseType,
    );

    final List<Map<dynamic, dynamic>>? resBody = response.data;
    if (resBody != null && resBody.isNotEmpty) {
      final List<T> models = makeModels<T>(resBody);
      if (isLogEnabled) {
        LogUtil.d('Response models: $models');
      }
      return models;
    } else {
      return <T>[];
    }
  }

  /// For download progress, here we don't simply use the [dio.download],
  /// because there's no file name provided. So in here we take two steps:
  ///  * Using [HEAD] to get the 'content-disposition' in headers to determine
  ///   the real file name of the attachment.
  ///  * Call [dio.download] to download the file with the real name.
  ///
  /// Return save path if succeed.
  static Future<String?> download(
    String url, {
    dynamic? data,
    Map<String, dynamic>? headers,
    ProgressCallback? progressCallback,
  }) async {
    Response<dynamic> response;
    String path;
    final bool isAllGranted = await checkPermissions(
      <Permission>[Permission.storage],
    );
    if (isAllGranted) {
      showToast('开始下载...');
      LogUtil.d('File start download: $url');
      path = '${(await getExternalStorageDirectory())!.path}/';
      try {
        response = await _getResponse<dynamic>(
          FetchType.head,
          url: url,
          body: data,
          headers: headers,
        );
        String? filename = response.headers
            .value('content-disposition')
            ?.split('; ')
            .where((String element) => element.contains('filename'))
            .first;
        if (filename != null) {
          final RegExp filenameReg = RegExp(r'filename=\"(.+)\"');
          filename = filenameReg.allMatches(filename).first.group(1);
          filename = Uri.decodeComponent(filename!);
          path += filename;
        } else {
          filename = url.split('/').last.split('?').first;
          path += filename;
        }
      } catch (e) {
        LogUtil.e('File download failed when fetching head: $e');
        return null;
      }
      try {
        response = await dio.download(
          url,
          path,
          data: data,
          options: Options(headers: headers),
          onReceiveProgress: progressCallback,
        );
        LogUtil.d('File downloaded: $path');
        showToast('下载完成 $path');
        OpenFile.open(path)
            .then(
              (OpenResult result) =>
                  LogUtil.d('File open result: ${result.type}'),
            )
            .catchError(
              (Object e) => LogUtil.e('Error when opening download file: $e'),
            );
        return path;
      } catch (e) {
        LogUtil.e('File download failed: $e');
        return null;
      }
    } else {
      LogUtil.e('No permission to download file: $url');
      showToast('未获得存储权限');
      return null;
    }
  }

  static Future<Response<T>> _getResponse<T>(
    FetchType fetchType, {
    required String url,
    Map<String, String>? queryParameters,
    dynamic? body,
    Map<String, dynamic>? headers,
    ResponseType responseType = ResponseType.json,
  }) async {
    Response<T> response;

    if (headers?.isNotEmpty == true && isLogEnabled) {
      LogUtil.d('$fetchType headers: $headers');
    }
    final Map<String, String>? _queryParameters =
        queryParameters?.map<String, String>(
      (String key, dynamic value) =>
          MapEntry<String, String>(key, value.toString()),
    );
    final Uri replacedUri = Uri.parse(url).replace(
      queryParameters: _queryParameters,
    );
    if (isLogEnabled) {
      LogUtil.d('$fetchType url: ${dio.options.baseUrl}$replacedUri');
    }
    if (body != null && isLogEnabled) {
      LogUtil.d('Raw request body: $body');
    }

    switch (fetchType) {
      case FetchType.head:
        response = await dio.head(
          replacedUri.toString(),
          options: Options(
            followRedirects: true,
            headers: headers,
            receiveDataWhenStatusError: true,
            responseType: responseType,
          ),
        );
        break;
      case FetchType.get:
        response = await dio.get(
          replacedUri.toString(),
          options: Options(
            followRedirects: true,
            headers: headers,
            receiveDataWhenStatusError: true,
            responseType: responseType,
          ),
        );
        break;
      case FetchType.post:
        response = await dio.post(
          replacedUri.toString(),
          data: body,
          options: Options(
            followRedirects: true,
            headers: headers,
            receiveDataWhenStatusError: true,
            responseType: responseType,
          ),
        );
        break;
      case FetchType.put:
        response = await dio.put(
          replacedUri.toString(),
          data: body,
          options: Options(
            followRedirects: true,
            headers: headers,
            receiveDataWhenStatusError: true,
            responseType: responseType,
          ),
        );
        break;
      case FetchType.patch:
        response = await dio.patch(
          replacedUri.toString(),
          data: body,
          options: Options(
            followRedirects: true,
            headers: headers,
            receiveDataWhenStatusError: true,
            responseType: responseType,
          ),
        );
        break;
      case FetchType.delete:
        response = await dio.delete(
          replacedUri.toString(),
          data: body,
          options: Options(
            followRedirects: true,
            headers: headers,
            receiveDataWhenStatusError: true,
            responseType: responseType,
          ),
        );
        break;
    }
    if (isLogEnabled) {
      LogUtil.d(
        'Got response from: ${dio.options.baseUrl}$replacedUri '
        '${response.statusCode}',
      );
      LogUtil.d('Raw response body: ${response.data}');
    }
    return response;
  }

  /// Method to update ticket.
  static Future<void> updateTicket() async {
    // Lock and clear dio while requesting new ticket.
    dio
      ..lock()
      ..clear();

    if (await UserAPI.getTicket()) {
      LogUtil.d('Ticket updated success with new ticket: ${UserAPI.user.sid}');
    } else {
      LogUtil.e('Ticket updated error: ${UserAPI.user.sid}');
    }
    // Release lock.
    dio.unlock();
  }

  static List<Cookie> convertWebViewCookies(List<web_view.Cookie>? cookies) {
    if (cookies?.isNotEmpty != true) {
      return const <Cookie>[];
    }
    final List<Cookie> replacedCookies = cookies!.map((web_view.Cookie cookie) {
      return Cookie(cookie.name, cookie.value)
        ..domain = cookie.domain
        ..httpOnly = cookie.isHttpOnly ?? false
        ..secure = cookie.isSecure ?? false
        ..path = cookie.path;
    }).toList();
    return replacedCookies;
  }

  static Future<void> updateDomainsCookies(
    List<String> urls, [
    List<Cookie>? cookies,
  ]) async {
    final List<Cookie> _cookies =
        cookies ?? _buildPHPSESSIDCookies(UserAPI.user.sid);
    for (final String url in urls) {
      final String httpUrl = url.replaceAll(
        RegExp(r'http(s)?://'),
        'http://',
      );
      final String httpsUrl = url.replaceAll(
        RegExp(r'http(s)?://'),
        'https://',
      );
      await Future.wait<void>(
        <Future<void>>[
          cookieJar.saveFromResponse(Uri.parse('$httpUrl/'), _cookies),
          tokenCookieJar.saveFromResponse(Uri.parse('$httpUrl/'), _cookies),
          cookieJar.saveFromResponse(Uri.parse('$httpsUrl/'), _cookies),
          tokenCookieJar.saveFromResponse(Uri.parse('$httpsUrl/'), _cookies),
        ],
      );
    }
  }

  static List<Cookie> _buildPHPSESSIDCookies(String? sid) => <Cookie>[
        if (sid != null) Cookie('PHPSESSID', sid),
        if (sid != null) Cookie('OAPSID', sid),
      ];

  static dynamic Function(HttpClient client) get _clientCreate {
    return (HttpClient client) {
      if (_isProxyEnabled) {
        client.findProxy = (_) => _proxyDestination;
      }
      client.badCertificateCallback = (_, __, ___) => true;
    };
  }

  static InterceptorsWrapper get _interceptor {
    return InterceptorsWrapper(
      onResponse: (
        Response<dynamic> r,
        ResponseInterceptorHandler handler,
      ) {
        dynamic? _resolvedData;
        if (r.statusCode == HttpStatus.noContent) {
          const Map<String, dynamic>? _data = null;
          _resolvedData = _data;
          r.data = _data;
          handler.resolve(r);
          return;
        }
        final dynamic data = r.data;
        if (data is String) {
          try {
            // If we do want a JSON all the time, DO try to decode the data.
            _resolvedData = jsonDecode(data) as Map<String, dynamic>;
          } catch (e) {
            _resolvedData = data;
          }
        } else {
          _resolvedData = data;
        }
        r.data = _resolvedData;
        handler.next(r);
      },
      onError: (
        DioError e,
        ErrorInterceptorHandler handler,
      ) {
        if (e.response?.isRedirect == true ||
            e.response?.statusCode == HttpStatus.movedPermanently ||
            e.response?.statusCode == HttpStatus.movedTemporarily ||
            e.response?.statusCode == HttpStatus.seeOther ||
            e.response?.statusCode == HttpStatus.temporaryRedirect) {
          handler.next(e);
          return;
        }
        if (e.response?.statusCode == HttpStatus.unauthorized) {
          updateTicket();
        }
        if (isLogEnabled) {
          LogUtil.e(
            'Error when requesting ${e.requestOptions.uri} '
            '${e.response?.statusCode}'
            ': ${e.response?.data}',
            withStackTrace: false,
          );
        }
        handler.reject(e);
      },
    );
  }
}

class LoggingInterceptor extends Interceptor {
  late DateTime startTime;
  late DateTime endTime;

  static const String HTTP_TAG = 'HTTP - LOG';

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    startTime = DateTime.now();
    LogUtil.d(' ', tag: HTTP_TAG);
    LogUtil.d(
      '------------------- Start -------------------',
      tag: HTTP_TAG,
    );
    if (options.queryParameters.isEmpty) {
      LogUtil.d(
        'Request Url         : '
        '${options.method}'
        ' '
        '${options.baseUrl}'
        '${options.path}',
        tag: HTTP_TAG,
      );
    } else {
      LogUtil.d(
        'Request Url         : '
        '${options.method}  '
        '${options.baseUrl}${options.path}?'
        '${Transformer.urlEncodeMap(options.queryParameters)}',
        tag: HTTP_TAG,
      );
    }
    LogUtil.d(
      'Request ContentType : ${options.contentType}',
      tag: HTTP_TAG,
    );
    if (options.data != null) {
      LogUtil.d(
        'Request Data        : ${options.data.toString()}',
        tag: HTTP_TAG,
      );
    }
    LogUtil.d(
      'Request Headers     : ${options.headers.toString()}',
      tag: HTTP_TAG,
    );
    LogUtil.d('--', tag: HTTP_TAG);
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    endTime = DateTime.now();
    final int duration = endTime.difference(startTime).inMilliseconds;
    LogUtil.d(
      'Response_Code       : ${response.statusCode}',
      tag: HTTP_TAG,
    );
    // 输出结果
    LogUtil.d(
      'Response_Data       : ${response.data.toString()}',
      tag: HTTP_TAG,
    );
    LogUtil.d(
      '------------- End: $duration ms -------------',
      tag: HTTP_TAG,
    );
    LogUtil.d('' '', tag: HTTP_TAG);
    handler.next(response);
  }

  @override
  void onError(
    DioError err,
    ErrorInterceptorHandler handler,
  ) {
    LogUtil.e(
      '------------------- Error -------------------',
      tag: HTTP_TAG,
    );
    handler.next(err);
  }
}
