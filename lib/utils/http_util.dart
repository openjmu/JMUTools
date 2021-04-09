///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2021-04-01 21:08
///
import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart' as web_view
    show Cookie, CookieManager;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

import 'package:jmu_tools/apis/api.dart';
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

  static final Dio dio = Dio(_options);
  static final Dio tokenDio = Dio(_options);

  static late final PersistCookieJar cookieJar;
  static late final PersistCookieJar tokenCookieJar;
  static late final CookieManager cookieManager;
  static late final CookieManager tokenCookieManager;
  static final web_view.CookieManager webViewCookieManager =
      web_view.CookieManager.instance();

  static late final Directory _tempDir;
  static late bool shouldUseWebVPN;

  static bool isLogEnabled = true;

  static Future<void> initConfig() async {
    await initCookieManagement();

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

    await testClassKit();
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
    String? contentType,
    ResponseType responseType = ResponseType.json,
    bool useTokenDio = false,
  }) async {
    final Response<T> response = await getResponse(
      fetchType,
      url: url,
      queryParameters: queryParameters,
      body: body,
      headers: headers,
      contentType: contentType,
      responseType: responseType,
      useTokenDio: useTokenDio,
    );
    return response.data as T;
  }

  static Future<T> fetchModel<T extends DataModel>(
    FetchType fetchType, {
    required String url,
    Map<String, String>? queryParameters,
    dynamic? body,
    Map<String, dynamic>? headers,
    String? contentType,
    ResponseType responseType = ResponseType.json,
    bool useTokenDio = false,
  }) async {
    final Response<Map<String, dynamic>> response = await getResponse(
      fetchType,
      url: url,
      queryParameters: queryParameters,
      body: body,
      headers: headers,
      contentType: contentType,
      responseType: responseType,
      useTokenDio: useTokenDio,
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
    String? contentType,
    ResponseType responseType = ResponseType.json,
    bool useTokenDio = false,
  }) async {
    final Response<List<Map<dynamic, dynamic>>> response = await getResponse(
      fetchType,
      url: url,
      queryParameters: queryParameters,
      body: body,
      headers: headers,
      contentType: contentType,
      responseType: responseType,
      useTokenDio: useTokenDio,
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

  /// Get header only.
  ///
  /// This request is targeted to get filename directly.
  static Future<String?> headFilename(
    String url, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? data,
    Options? options,
    bool useTokenDio = false,
  }) async {
    final Response<dynamic> res = await dio.head<dynamic>(
      url,
      data: data,
      queryParameters: queryParameters,
      options: options ?? Options(followRedirects: true),
    );
    String? filename = res.headers
        .value('content-disposition')
        ?.split('; ')
        .where((String element) => element.contains('filename'))
        .first;
    if (filename != null) {
      final RegExp filenameReg = RegExp(r'filename=\"(.+)\"');
      filename = filenameReg.allMatches(filename).first.group(1);
      filename = Uri.decodeComponent(filename!);
    } else {
      filename = url.split('/').last.split('?').first;
    }
    return filename;
  }

  /// For download progress, here we don't simply use the [dio.download],
  /// because there's no file name provided. So in here we take two steps:
  /// * Using [headFilename] to get the 'content-disposition' in headers to
  ///   determine the real filename of the attachment.
  /// * Call [dio.download] to download the file with the real name.
  static Future<Response<dynamic>?> download(
    String url,
    String filename, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? headers,
    String? contentType,
    ProgressCallback? progressCallback,
  }) async {
    String path;
    if (await checkPermissions(<Permission>[Permission.storage])) {
      showToast('开始下载 ...');
      LogUtil.d('File start download: $url');
      path = '${(await getExternalStorageDirectory())!.path}/$filename';
      try {
        final Response<dynamic> response = await dio.download(
          url,
          path,
          data: data,
          options: Options(contentType: contentType, headers: headers),
          onReceiveProgress: progressCallback,
        );
        LogUtil.d('File downloaded: $path');
        showToast('下载完成 $path');
        try {
          final OpenResult openFileResult = await OpenFile.open(path);
          LogUtil.d('File open result: ${openFileResult.type}');
        } catch (e) {
          LogUtil.e('Failed to open download file: $path $e');
        }
        return response;
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

  static Future<Response<T>> getResponse<T>(
    FetchType fetchType, {
    required String url,
    Map<String, String>? queryParameters,
    dynamic? body,
    Map<String, dynamic>? headers,
    String? contentType,
    ResponseType responseType = ResponseType.json,
    bool useTokenDio = false,
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

    final Dio _dio = useTokenDio ? tokenDio : dio;

    switch (fetchType) {
      case FetchType.head:
        response = await _dio.head(
          replacedUri.toString(),
          options: Options(
            contentType: contentType,
            headers: headers,
            responseType: responseType,
          ),
        );
        break;
      case FetchType.get:
        response = await _dio.get(
          replacedUri.toString(),
          options: Options(
            contentType: contentType,
            headers: headers,
            responseType: responseType,
          ),
        );
        break;
      case FetchType.post:
        response = await _dio.post(
          replacedUri.toString(),
          data: body,
          options: Options(
            contentType: contentType,
            headers: headers,
            responseType: responseType,
          ),
        );
        break;
      case FetchType.put:
        response = await _dio.put(
          replacedUri.toString(),
          data: body,
          options: Options(
            contentType: contentType,
            headers: headers,
            responseType: responseType,
          ),
        );
        break;
      case FetchType.patch:
        response = await _dio.patch(
          replacedUri.toString(),
          data: body,
          options: Options(
            contentType: contentType,
            headers: headers,
            responseType: responseType,
          ),
        );
        break;
      case FetchType.delete:
        response = await _dio.delete(
          replacedUri.toString(),
          data: body,
          options: Options(
            contentType: contentType,
            headers: headers,
            responseType: responseType,
          ),
        );
        break;
    }
    if (isLogEnabled) {
      LogUtil.d(
        'Got response from: ${_dio.options.baseUrl}$replacedUri '
        '${response.statusCode}',
      );
      if (response.data != null && response.data != '') {
        LogUtil.d('Raw response body: ${response.data}');
      }
    }
    return response;
  }

  static List<Cookie> convertWebViewCookies(List<web_view.Cookie>? cookies) {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return const <Cookie>[];
    }
    if (cookies?.isNotEmpty != true) {
      return const <Cookie>[];
    }
    final List<Cookie> replacedCookies = cookies!.map((web_view.Cookie cookie) {
      return Cookie(cookie.name, cookie.value.toString())
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
    final List<Cookie> _cookies = cookies ?? _buildCookies();
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

  /// Initialize WebView's cookie with 'iPlanetDirectoryPro'.
  /// 启动时通过 Session 初始化 WebView 的 Cookie
  static Future<bool> initializeWebViewCookie() async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return false;
    }
    final String url = 'http://sso.jmu.edu.cn/imapps/2190'
        '?sid=${UserAPI.loginModel!.sid}';
    try {
      await HttpUtil.fetch<void>(FetchType.head, url: url);
      LogUtil.d('Cookie response did not return 302.');
      return false;
    } on DioError catch (dioError) {
      try {
        if (dioError.response?.statusCode == HttpStatus.movedTemporarily) {
          final List<Cookie> mainSiteCookies = await cookieJar.loadForRequest(
            Uri.parse('http://www.jmu.edu.cn/'),
          );
          for (final Cookie cookie in mainSiteCookies) {
            webViewCookieManager.setCookie(
              url: Uri.parse('${cookie.domain}${cookie.path}'),
              name: cookie.name,
              value: cookie.value,
              domain: cookie.domain,
              path: cookie.path ?? '/',
              expiresDate: cookie.expires?.millisecondsSinceEpoch,
              isSecure: cookie.secure,
              maxAge: cookie.maxAge,
            );
          }
          LogUtil.d('Successfully initialize WebView\'s Cookie.');
          return true;
        } else {
          LogUtil.e(
            'Error when initializing WebView\'s Cookie: $dioError',
            withStackTrace: false,
          );
          return false;
        }
      } catch (e) {
        LogUtil.e('Error when handling cookie response: $e');
        return false;
      }
    } catch (e) {
      LogUtil.e('Error when handling cookie response: $e');
      return false;
    }
  }

  static List<Cookie> _buildCookies() => <Cookie>[
        if (UserAPI.loginModel?.sid != null)
          Cookie('PHPSESSID', UserAPI.loginModel!.sid)..httpOnly = false,
        if (UserAPI.loginModel?.sid != null)
          Cookie('OAPSID', UserAPI.loginModel!.sid)..httpOnly = false,
      ];

  /// 通过测试「课堂助理」应用，判断是否需要使用 WebVPN。
  static Future<void> testClassKit() async {
    try {
      await fetch<String>(
        FetchType.get,
        url: API.classKitHost,
        contentType: 'text/html;charset=utf-8',
        useTokenDio: true,
      );
      shouldUseWebVPN = false;
    } on DioError catch (dioError) {
      if (dioError.response?.statusCode == HttpStatus.forbidden) {
        shouldUseWebVPN = true;
        return;
      }
      shouldUseWebVPN = false;
    } catch (e) {
      LogUtil.e('Error when testing classKit: $e');
      shouldUseWebVPN = false;
    }
  }

  static BaseOptions get _options {
    return BaseOptions(
      connectTimeout: 10000,
      sendTimeout: 10000,
      receiveTimeout: 10000,
      receiveDataWhenStatusError: true,
      followRedirects: true,
    );
  }

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
          LogUtil.e(
            'Session is outdated, calling update...',
            withStackTrace: false,
          );
          UserAPI.updateSession();
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
