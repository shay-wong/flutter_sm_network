part of 'http.dart';

/// 原始请求会话
abstract class RawSession<R extends BaseResp<T>, T>
    with HttpOptionsMixin<R, T>, RequestMixin<R, T> {}

/// 请求会话
abstract class Session<T> extends RawSession<BaseResp<T>, T> {}

class _DefaultSession<T> extends Session<T> {
  _DefaultSession({
    this.cancelToken,
    this.contentType,
    Converter<BaseResp<T>, T>? converter,
    this.data,
    this.deleteOnError,
    this.extra,
    this.fileAccessMode,
    this.files,
    this.followRedirects,
    this.fromJsonT,
    this.headers,
    this.lengthHeader,
    this.listFormat,
    this.maxRedirects,
    this.method,
    this.onReceiveProgress,
    this.onSendProgress,
    HttpOptions<BaseResp<T>, T>? options,
    this.parameters,
    this.path,
    this.persistentConnection,
    this.preserveHeaderCase,
    this.receiveDataWhenStatusError,
    this.receiveTimeout,
    this.requestEncoder,
    this.responseDecoder,
    this.responseType,
    this.savePath,
    this.sendTimeout,
    this.validateStatus,
  })  : _converter = converter,
        _options = options;

  final Converter<BaseResp<T>, T>? _converter;
  final HttpOptions<BaseResp<T>, T>? _options;

  @override
  final CancelToken? cancelToken;

  @override
  final ContentType? contentType;

  @override
  final Object? data;

  @override
  bool? deleteOnError;

  @override
  final Parameters? extra;

  @override
  FileAccessMode? fileAccessMode;

  @override
  FormFiles? files;

  @override
  final bool? followRedirects;

  @override
  final FromJsonT<T>? fromJsonT;

  @override
  final HTTPHeaders? headers;

  @override
  String? lengthHeader;

  @override
  final ListFormat? listFormat;

  @override
  final int? maxRedirects;

  @override
  final Method? method;

  @override
  final ProgressCallback? onReceiveProgress;

  @override
  final ProgressCallback? onSendProgress;

  @override
  final Parameters? parameters;

  @override
  final String? path;

  @override
  final bool? persistentConnection;

  @override
  final bool? preserveHeaderCase;

  @override
  final bool? receiveDataWhenStatusError;

  @override
  final Duration? receiveTimeout;

  @override
  final RequestEncoder? requestEncoder;

  @override
  final ResponseDecoder? responseDecoder;

  @override
  final ResponseType? responseType;

  @override
  final dynamic savePath;

  @override
  final Duration? sendTimeout;

  @override
  final ValidateStatus? validateStatus;

  @override
  Converter<BaseResp<T>, T> get converter => _converter ?? super.converter;

  @override
  HttpOptions<BaseResp<T>, T>? get options => _options ?? super.options;
}
