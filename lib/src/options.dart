import 'package:dio/dio.dart';

import 'coverters/converter.dart';
import 'http.dart';
import 'log.dart';

/// 基础配置
class HttpBaseOptions<R extends BaseResp<T>, T> extends BaseOptions
    implements HttpCommonOptionsMixin<R, T> {
  // ignore: public_member_api_docs
  HttpBaseOptions({
    Method? method,
    super.connectTimeout,
    super.receiveTimeout,
    super.sendTimeout,
    super.baseUrl = '',
    super.queryParameters,
    super.extra,
    super.headers,
    super.preserveHeaderCase = false,
    super.responseType = ResponseType.json,
    super.contentType,
    super.validateStatus,
    super.receiveDataWhenStatusError,
    super.followRedirects,
    super.maxRedirects,
    super.persistentConnection,
    super.requestEncoder,
    super.responseDecoder,
    super.listFormat,
    this.log = const HttpLog(),
    this.converterOptions = const DefaultConverterOptions(),
    this.converter,
  }) : super(method: method?.name);

  /// 转换选项
  final ConverterOptions converterOptions;

  /// 是否打印日志
  final HttpLog log;

  @override
  final Converter<R, T>? converter;
}

/// 基础选项
abstract class HttpCommonOptionsMixin<R extends BaseResp<T>, T> {
  // ignore: public_member_api_docs
  HttpCommonOptionsMixin({
    required this.converter,
  });

  /// 转换
  final Converter<R, T>? converter;
}

/// 请求配置
class HttpOptions<R extends BaseResp<T>, T> extends Options
    implements HttpCommonOptionsMixin<R, T> {
  // ignore: public_member_api_docs
  HttpOptions({
    Method? method,
    super.sendTimeout,
    super.receiveTimeout,
    super.extra,
    super.headers,
    super.preserveHeaderCase,
    super.responseType,
    ContentType? contentType,
    super.validateStatus,
    super.receiveDataWhenStatusError,
    super.followRedirects,
    super.maxRedirects,
    super.persistentConnection,
    super.requestEncoder,
    super.responseDecoder,
    super.listFormat,
    this.converter,
  }) : super(
          method: method?.name,
          contentType: contentType?.value,
        );

  @override
  final Converter<R, T>? converter;
}

/// 参数混入
mixin HttpOptionsMixin<R extends BaseResp<T>, T> {
  /// 取消 Token
  CancelToken? get cancelToken => null;

  /// Content-Type
  ContentType? get contentType => files != null ? ContentType.multipart : null;

  /// 数据转换
  Converter<R, T> get converter => DefaultConverter<R, T>(
        fromJsonT: fromJsonT,
        options: Http.shared.options.converterOptions,
      );

  /// 请求体数据 默认 null
  Object? get data => null;

  /// 上传文件
  /// [files] 的 `value` 必须是 [MultipartFile]
  /// 当使用 [files] 文件上传时, [data] 必须是 [Parameters]
  FormFiles? get files => null;

  /// dio
  Dio get dio => Http.dio;

  /// 额外参数
  Parameters? get extra => null;

  /// 跟随重定向
  bool? get followRedirects => null;

  /// json 转换
  FromJsonT<T>? get fromJsonT => null;

  /// 请求头 默认 null
  HTTPHeaders? get headers => null;

  /// 数组格式
  ListFormat? get listFormat => null;

  /// 最大重定向次数
  int? get maxRedirects => null;

  /// 请求方式 默认 GET
  Method? get method => null;

  /// 接收进度
  ProgressCallback? get onReceiveProgress => null;

  /// 上传进度
  ProgressCallback? get onSendProgress => null;

  /// 请求配置
  HttpOptions<R, T>? get options => HttpOptions<R, T>(
        method: method,
        sendTimeout: sendTimeout,
        receiveTimeout: receiveTimeout,
        extra: extra,
        headers: headers,
        preserveHeaderCase: preserveHeaderCase,
        responseType: responseType,
        contentType: contentType,
        validateStatus: validateStatus,
        receiveDataWhenStatusError: receiveDataWhenStatusError,
        followRedirects: followRedirects,
        maxRedirects: maxRedirects,
        persistentConnection: persistentConnection,
        requestEncoder: requestEncoder,
        responseDecoder: responseDecoder,
        listFormat: listFormat,
        converter: converter,
      );

  /// 请求参数 默认 null
  Parameters? get parameters => null;

  /// 请求路径 默认 null
  String? get path => null;

  /// 持久化连接
  bool? get persistentConnection => null;

  /// 保留 Header 大小写
  bool? get preserveHeaderCase => null;

  /// 状态错误时是否接收数据
  bool? get receiveDataWhenStatusError => null;

  /// 接收超时时间
  Duration? get receiveTimeout => null;

  /// 请求编码
  RequestEncoder? get requestEncoder => null;

  /// 响应解码
  ResponseDecoder? get responseDecoder => null;

  /// 响应类型
  ResponseType? get responseType => null;

  /// 发送超时时间
  Duration? get sendTimeout => null;

  /// 请求状态校验
  ValidateStatus? get validateStatus => null;
}
