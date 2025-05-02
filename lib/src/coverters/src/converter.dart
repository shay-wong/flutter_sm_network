import 'dart:convert';

import 'package:dio/dio.dart';

import '../../extension.dart';
import '../../http.dart';
import 'base_resp.dart';
import 'num_converter.dart';
import 'string_converter.dart';

/// json 数据转换
typedef FromJsonT<T> = T Function(Parameters);

/// 验证状态
typedef ValidateT = bool Function(int? status, Parameters data);

/// 数据处理器
abstract class Converter<R extends BaseResp<T>, T> {
  // ignore: public_member_api_docs
  const Converter({required this.fromJsonT, required this.options});

  /// 数据转换函数
  final FromJsonT<T>? fromJsonT;

  /// 选项
  final ConverterOptions options;

  /// 拷贝
  Converter<R, T> copyWith({
    FromJsonT<T>? fromJsonT,
    ConverterOptions? options,
  }) {
    return DefaultConverter<R, T>(
      fromJsonT: fromJsonT ?? this.fromJsonT,
      options: options ?? this.options,
    );
  }

  /// 错误数据处理
  R error(dynamic error) => throw UnimplementedError();

  /// 异常数据处理
  R exception(DioException exception) => throw UnimplementedError();

  /// 成功数据处理
  R success(Response response) => throw UnimplementedError();
}

/// 转换选项
abstract class ConverterOptions {
  // ignore: public_member_api_docs
  const ConverterOptions({
    required this.code,
    required this.message,
    required this.data,
    required this.status,
  });

  /// 错误码
  final String code;

  /// 数据
  final String data;

  /// 错误信息
  final String message;

  /// 状态
  final ValidateT? status;
}

/// 默认数据转换
class DefaultConverter<R extends BaseResp<T>, T> extends Converter<R, T> {
  // ignore: public_member_api_docs
  const DefaultConverter({
    super.fromJsonT,
    super.options = const DefaultConverterOptions(),
  });

  @override
  R error(
    dynamic error, {
    int? code,
  }) =>
      BaseResp<T>(
        code: code ?? 400,
        message: const StringConverter().fromJson(error),
      ) as R;

  @override
  R exception(DioException exception) {
    final response = exception.response;
    if (response != null) {
      return success(response);
    }
    return error(
      exception.error ?? exception.message ?? response?.statusMessage,
      code: response?.statusCode,
    );
  }

  @override
  R success(Response response) {
    dynamic data = response.data;
    if (data is! Parameters) {
      data = _decodeData(data);
    }
    if (data is Parameters) {
      return _handleResponse(data);
    }
    return BaseResp<T>(
      code: response.statusCode,
      data: data,
      message: response.statusMessage,
      status: response.requestOptions.validateStatus(response.statusCode),
    ) as R;
  }

  /// 解码数据
  dynamic _decodeData(dynamic data) {
    try {
      return jsonDecode(data);
    } catch (e) {
      Http.shared.options.log.error(e, StackTrace.current);
      return data;
    }
  }

  /// 生成对象
  T? _generateObj(dynamic data) {
    try {
      dynamic obj;
      if (fromJsonT != null && data != null) {
        obj = fromJsonT!(data);
      } else {
        obj = data;
      }
      return obj as T?;
    } catch (e) {
      rethrow;
    }
  }

  R _handleResponse(Parameters response) {
    final code = const IntConverter().fromJson(response.getNestedValue(options.code));
    var data = response.getNestedValue(options.data);
    final message = const StringConverter().fromJson(response.getNestedValue(options.message));

    List<T>? list;
    if (data is List) {
      list = data.map(_generateObj).whereType<T>().toList();
      data = null;
    } else {
      data = _generateObj(data);
    }

    return BaseResp<T>(
      code: code,
      data: data,
      list: list,
      message: message,
      status: options.status?.call(code, response),
    ) as R;
  }
}

/// 默认选项
class DefaultConverterOptions extends ConverterOptions {
  // ignore: public_member_api_docs
  const DefaultConverterOptions({
    super.code = 'code',
    super.message = 'message',
    super.data = 'data',
    super.status,
  });
}
