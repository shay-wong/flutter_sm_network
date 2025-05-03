import 'package:dio/dio.dart';

import 'coverters/converter.dart';
import 'intercaptors/log_interceptor.dart';
import 'options.dart';
import 'request.dart';

part 'session.dart';

/// 表单文件
typedef FormFiles = Map<String, MultipartFile>;

/// 请求头
typedef HTTPHeaders = Parameters;

/// 参数
typedef Parameters = Map<String, dynamic>;

/// 请求体
enum ContentType {
  /// 原始
  raw,

  /// json
  json,

  /// urlencoded
  urlencoded,

  /// multipart
  multipart;

  /// 获取 content-type 值
  String get value {
    switch (this) {
      case ContentType.raw:
        return Headers.textPlainContentType;
      case ContentType.json:
        return Headers.jsonContentType;
      case ContentType.urlencoded:
        return Headers.formUrlEncodedContentType;
      case ContentType.multipart:
        return Headers.multipartFormDataContentType;
    }
  }

  /// 从 content-type 值获取 [ContentType]
  static ContentType? tryParse(String? value) {
    switch (value) {
      case Headers.textPlainContentType:
        return ContentType.raw;
      case Headers.jsonContentType:
        return ContentType.json;
      case Headers.formUrlEncodedContentType:
        return ContentType.urlencoded;
      case Headers.multipartFormDataContentType:
        return ContentType.multipart;
    }
    return null;
  }
}

/// http
final class Http {
  /// 单例
  factory Http() => _instance;

  Http._();

  static final _instance = Http._();

  /// dio
  static Dio get dio => _instance._dio;

  /// 单例
  static Http get shared => _instance;

  late final Dio _dio;

  late HttpBaseOptions _options;

  /// 配置
  HttpBaseOptions get options => _options;

  set options(HttpBaseOptions options) {
    _options = options;
    dio.options = options;
  }

  /// 关闭Dio客户端。
  /// 如果 [force] 为`false`（默认值），则 [Dio] 将保持活动状态直到所有活动连接完成。
  /// 如果 [force] 为`true`，任何活动连接将被关闭以立即释放所有资源。
  /// 这些关闭的连接将收到一个错误事件，以指示客户端已被关闭。
  /// 在两种情况下，在调用 [close] 之后尝试建立新的连接将抛出异常。
  void close({bool force = false}) => _dio.close(force: force);

  /// 请求配置
  ///
  /// [dio] 创建一个 [Dio] 对象
  ///
  /// [options] 请求配置
  ///
  /// [interceptors] 请求拦截器
  ///
  /// [httpClientAdapter] 适配器
  ///
  /// [transformer] 允许在将 请求数据发送至服务器/响应数据从服务器接收 之前进行更改
  /// 这仅适用于具有有效载荷的请求。
  void config({
    Dio? dio,
    HttpBaseOptions? options,
    Iterable<Interceptor>? interceptors,
    HttpClientAdapter? httpClientAdapter,
    Transformer? transformer,
  }) {
    _options = options ?? HttpBaseOptions();
    _dio = dio ?? Dio(_options);

    var logInterceptorIndex = -1;
    if (interceptors != null) {
      final inters = interceptors.toList();
      logInterceptorIndex = inters.lastIndexWhere((e) => e is HttpLogInterceptor);
      if (logInterceptorIndex != -1) {
        final filtered = inters
            .asMap()
            .entries
            .where((entry) {
              final index = entry.key;
              final value = entry.value;
              return value is! HttpLogInterceptor || index == logInterceptorIndex;
            })
            .map((e) => e.value)
            .toList();
        _dio.interceptors.addAll(filtered);
      }
    }

    // 添加日志
    if (_options.log.options.enable && logInterceptorIndex == -1) {
      _dio.interceptors.add(
        HttpLogInterceptor(
          log: _options.log,
          converterOptions: _options.converterOptions,
        ),
      );
    }

    if (httpClientAdapter != null) {
      _dio.httpClientAdapter = httpClientAdapter;
    }

    if (transformer != null) {
      _dio.transformer = transformer;
    }
  }

  /// delete
  static Future<BaseResp<T>> delete<T>({
    String? path,
    Object? data,
    Parameters? queryParameters,
    HttpOptions<BaseResp<T>, T>? options,
    CancelToken? cancelToken,
  }) {
    return session<T>().delete(
      path: path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// delete uri
  static Future<BaseResp<T>> deleteUri<T>({
    Uri? uri,
    Object? data,
    HttpOptions<BaseResp<T>, T>? options,
    CancelToken? cancelToken,
  }) {
    return session<T>().deleteUri(
      uri: uri,
      data: data,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// download
  static Future<BaseResp<ResponseBody>> download({
    String? path,
    dynamic savePath,
    Object? data,
    Map<String, dynamic>? queryParameters,
    HttpOptions<BaseResp<ResponseBody>, ResponseBody>? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
    bool? deleteOnError,
    FileAccessMode? fileAccessMode,
    String? lengthHeader,
  }) {
    return session<ResponseBody>().download(
      path: path,
      savePath: savePath,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
      deleteOnError: deleteOnError,
      fileAccessMode: fileAccessMode,
      lengthHeader: lengthHeader,
    );
  }

  /// download uri
  static Future<BaseResp<ResponseBody>> downloadUri({
    Uri? uri,
    dynamic savePath,
    Object? data,
    HttpOptions<BaseResp<ResponseBody>, ResponseBody>? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
    bool? deleteOnError,
    FileAccessMode? fileAccessMode,
    String? lengthHeader,
  }) {
    return session<ResponseBody>().downloadUri(
      uri: uri,
      savePath: savePath,
      data: data,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
      deleteOnError: deleteOnError,
      fileAccessMode: fileAccessMode,
      lengthHeader: lengthHeader,
    );
  }

  /// fetch
  static Future<Response<E?>> fetch<E, T>({
    String? path,
    dynamic savePath,
    Method? method,
    Object? data,
    FormFiles? files,
    Parameters? queryParameters,
    CancelToken? cancelToken,
    HttpOptions<BaseResp<T>, T>? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    bool? deleteOnError,
    FileAccessMode? fileAccessMode,
    String? lengthHeader,
  }) =>
      session<T>().fetch<E>(
        path: path,
        savePath: savePath,
        method: method,
        data: data,
        files: files,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: options,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
        deleteOnError: deleteOnError,
        fileAccessMode: fileAccessMode,
        lengthHeader: lengthHeader,
      );

  /// get
  static Future<BaseResp<T>> get<T>({
    String? path,
    Object? data,
    Parameters? queryParameters,
    HttpOptions<BaseResp<T>, T>? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) {
    return session<T>().get(
      path: path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// get uri
  static Future<BaseResp<T>> getUri<T>({
    Uri? uri,
    Object? data,
    HttpOptions<BaseResp<T>, T>? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) {
    return session<T>().getUri(
      uri: uri,
      data: data,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// head
  static Future<BaseResp<T>> head<T>({
    String? path,
    Object? data,
    Parameters? queryParameters,
    HttpOptions<BaseResp<T>, T>? options,
    CancelToken? cancelToken,
  }) {
    return session<T>().head(
      path: path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// head uri
  static Future<BaseResp<T>> headUri<T>({
    Uri? uri,
    Object? data,
    HttpOptions<BaseResp<T>, T>? options,
    CancelToken? cancelToken,
  }) {
    return session<T>().headUri(
      uri: uri,
      data: data,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// patch
  static Future<BaseResp<T>> patch<T>({
    String? path,
    Object? data,
    Parameters? queryParameters,
    HttpOptions<BaseResp<T>, T>? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return session<T>().patch(
      path: path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// patch uri
  static Future<BaseResp<T>> patchUri<T>({
    Uri? uri,
    Object? data,
    HttpOptions<BaseResp<T>, T>? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return session<T>().patchUri(
      uri: uri,
      data: data,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// post
  static Future<BaseResp<T>> post<T>({
    String? path,
    Object? data,
    Parameters? queryParameters,
    HttpOptions<BaseResp<T>, T>? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return session<T>().post(
      path: path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// post uri
  static Future<BaseResp<T>> postUri<T>({
    Uri? uri,
    Object? data,
    HttpOptions<BaseResp<T>, T>? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return session<T>().postUri(
      uri: uri,
      data: data,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// put
  static Future<BaseResp<T>> put<T>({
    String? path,
    Object? data,
    Parameters? queryParameters,
    HttpOptions<BaseResp<T>, T>? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return session<T>().put(
      path: path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// put uri
  static Future<BaseResp<T>> putUri<T>({
    Uri? uri,
    Object? data,
    HttpOptions<BaseResp<T>, T>? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return session<T>().putUri(
      uri: uri,
      data: data,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// request
  static Future<BaseResp<T>> request<T>({
    String? path,
    dynamic savePath,
    Method? method,
    Object? data,
    FormFiles? files,
    Parameters? queryParameters,
    CancelToken? cancelToken,
    HttpOptions<BaseResp<T>, T>? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    Converter<BaseResp<T>, T>? converter,
    bool? deleteOnError,
    FileAccessMode? fileAccessMode,
    String? lengthHeader,
  }) =>
      session<T>().request(
        path: path,
        savePath: savePath,
        method: method,
        data: data,
        files: files,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: options,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
        converter: converter,
        deleteOnError: deleteOnError,
        fileAccessMode: fileAccessMode,
        lengthHeader: lengthHeader,
      );

  /// request uri
  static Future<BaseResp<T>> requestUri<T>({
    Uri? uri,
    dynamic savePath,
    Method? method,
    Object? data,
    FormFiles? files,
    CancelToken? cancelToken,
    HttpOptions<BaseResp<T>, T>? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    Converter<BaseResp<T>, T>? converter,
    bool? deleteOnError,
    FileAccessMode? fileAccessMode,
    String? lengthHeader,
  }) {
    return session<T>().requestUri(
      uri: uri,
      savePath: savePath,
      method: method,
      data: data,
      files: files,
      cancelToken: cancelToken,
      options: options,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
      converter: converter,
      deleteOnError: deleteOnError,
      fileAccessMode: fileAccessMode,
      lengthHeader: lengthHeader,
    );
  }

  /// session
  static Session<T> session<T>({
    CancelToken? cancelToken,
    ContentType? contentType,
    Converter<BaseResp<T>, T>? converter,
    Object? data,
    bool? deleteOnError,
    Parameters? extra,
    FileAccessMode? fileAccessMode,
    FormFiles? files,
    bool? followRedirects,
    FromJsonT<T>? fromJsonT,
    HTTPHeaders? headers,
    String? lengthHeader,
    ListFormat? listFormat,
    int? maxRedirects,
    Method? method,
    ProgressCallback? onReceiveProgress,
    ProgressCallback? onSendProgress,
    HttpOptions<BaseResp<T>, T>? options,
    Parameters? queryParameters,
    String? path,
    bool? persistentConnection,
    bool? preserveHeaderCase,
    bool? receiveDataWhenStatusError,
    Duration? receiveTimeout,
    RequestEncoder? requestEncoder,
    ResponseDecoder? responseDecoder,
    ResponseType? responseType,
    dynamic savePath,
    Duration? sendTimeout,
    ValidateStatus? validateStatus,
  }) =>
      _DefaultSession<T>(
        cancelToken: cancelToken,
        contentType: contentType,
        converter: converter,
        data: data,
        deleteOnError: deleteOnError,
        extra: extra,
        fileAccessMode: fileAccessMode,
        files: files,
        followRedirects: followRedirects,
        fromJsonT: fromJsonT,
        headers: headers,
        lengthHeader: lengthHeader,
        listFormat: listFormat,
        maxRedirects: maxRedirects,
        method: method,
        onReceiveProgress: onReceiveProgress,
        onSendProgress: onSendProgress,
        options: options,
        parameters: queryParameters,
        path: path,
        persistentConnection: persistentConnection,
        preserveHeaderCase: preserveHeaderCase,
        receiveDataWhenStatusError: receiveDataWhenStatusError,
        receiveTimeout: receiveTimeout,
        requestEncoder: requestEncoder,
        responseDecoder: responseDecoder,
        responseType: responseType,
        savePath: savePath,
        sendTimeout: sendTimeout,
        validateStatus: validateStatus,
      );

  /// upload
  static Future<BaseResp<T>> upload<T>({
    String? path,
    Parameters? fields,
    FormFiles? files,
    Parameters? queryParameters,
    HttpOptions<BaseResp<T>, T>? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return session<T>().upload(
      path: path,
      fields: fields,
      files: files,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// upload uri
  static Future<BaseResp<T>> uploadUri<T>({
    Uri? uri,
    Parameters? fields,
    FormFiles? files,
    HttpOptions<BaseResp<T>, T>? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return session<T>().uploadUri(
      uri: uri,
      fields: fields,
      files: files,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }
}

/// 请求方法， dio 内部会转成大写
enum Method {
  /// delete
  delete,

  /// get
  get,

  /// head
  head,

  /// patch
  patch,

  /// post
  post,

  /// put
  put,

  /// download
  download,

  /// upload
  upload;

  /// 获取方法名
  String get methodName {
    switch (this) {
      case download:
        return get.name;
      case upload:
        return post.name;
      default:
        return name;
    }
  }
}
