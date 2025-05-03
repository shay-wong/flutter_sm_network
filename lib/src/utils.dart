import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

import 'http.dart';

/// Represents a 2-tuple, or pair.
@immutable
final class Tuple2<T1, T2> {
  /// Creates a new tuple value with the specified items.
  const Tuple2(this.item1, this.item2);

  /// Create a new tuple value with the specified list [items].
  factory Tuple2.fromList(List items) {
    if (items.length != 2) {
      throw ArgumentError('items must have length 2');
    }

    return Tuple2<T1, T2>(items[0] as T1, items[1] as T2);
  }

  /// Returns the first item of the tuple
  final T1 item1;

  /// Returns the second item of the tuple
  final T2 item2;

  @override
  int get hashCode => Object.hash(item1.hashCode, item2.hashCode);

  @override
  bool operator ==(Object other) => other is Tuple2 && other.item1 == item1 && other.item2 == item2;

  /// Creates a [List] containing the items of this [Tuple2].
  ///
  /// The elements are in item order. The list is variable-length
  /// if [growable] is true.
  List toList({bool growable = false}) => List.from([item1, item2], growable: growable);

  @override
  String toString() => '[$item1, $item2]';

  /// Returns a tuple with the first item set to the specified value.
  Tuple2<T1, T2> withItem1(T1 v) => Tuple2<T1, T2>(v, item2);

  /// Returns a tuple with the second item set to the specified value.
  Tuple2<T1, T2> withItem2(T2 v) => Tuple2<T1, T2>(item1, v);
}

@internal
final class Utils {
  factory Utils() => _instance;
  Utils._();
  static final _instance = Utils._();

  /// 单例
  static Utils get shared => _instance;

  /// json
  String jsonConverter(
    dynamic data, {
    required String Function([int]) indent,
    bool isCurl = false,
  }) {
    if (data is String) {
      try {
        data = jsonDecode(data);
      } catch (e) {
        return '${isCurl ? '' : indent()}$data';
      }
    }
    var json = JsonEncoder.withIndent(indent(isCurl ? 2 : 1)).convert(data);

    if (isCurl) {
      json = json.replaceRange(json.length - 1, null, '${indent()}}');
    } else {
      json = json.splitMapJoin(
        '\n',
        onNonMatch: (line) => indent() + line,
      );
    }

    return json;
  }

  /// 处理 request data 日志
  Tuple2<dynamic, String?>? processLogRequestData(
    dynamic data,
    ContentType? contentType,
    String Function([int]) indent, {
    bool isCurl = false,
  }) {
    if (data != null) {
      String? dataType;
      switch (contentType) {
        case ContentType.raw:
          dataType = 'Text Plain';
        case ContentType.json:
          dataType = 'Json';
        case ContentType.urlencoded:
          dataType = 'Form Urlencoded';
        case ContentType.multipart:
          dataType = 'Form Data';
        default:
          break;
      }
      if (data is FormData) {
        if (isCurl) {
          return Tuple2(
            [
              ...data.fields.map(
                (e) => '${indent()}--form \'${e.key}="${e.value}"\'',
              ),
              ...data.files.map(
                (e) => '${indent()}--form \'${e.key}=@"${e.value.filename}"\'',
              ),
            ],
            null,
          );
        } else {
          final formDataMap = <String, dynamic>{}
            ..addAll(mergeListToMap(data.fields))
            ..addEntries(
              data.files.map(
                (e) => MapEntry(
                  e.key,
                  {
                    'filename': e.value.filename,
                    'length': e.value.length,
                    'contentType': e.value.contentType?.mimeType,
                    'isFinalized': e.value.isFinalized,
                  },
                ),
              ),
            );
          return Tuple2(formDataMap, 'Request ${dataType ?? 'Form Data'}');
        }
      } else if (contentType == ContentType.urlencoded) {
        if (isCurl) {
          return Tuple2(
            // ignore: avoid_dynamic_calls
            data.entries.map(
              (MapEntry e) {
                return "${indent()}--data-urlencode '${e.key}=${e.value}'";
              },
            ),
            null,
          );
        } else {
          return Tuple2(data, 'Request ${dataType ?? 'Form Urlencoded'}');
        }
      } else {
        if (isCurl) {
          return Tuple2(
            jsonConverter(
              data,
              indent: indent,
              isCurl: isCurl,
            ),
            null,
          );
        } else {
          return Tuple2(data, 'Request ${dataType ?? 'Data'}');
        }
      }
    }
    return null;
  }

  /// 处理 request data
  Object? processRequestData({
    Object? data,
    FormFiles? files,
    ContentType? contentType,
  }) {
    // 处理 upload
    if (files != null) {
      data ??= Parameters.from({});
      if (data is Parameters) {
        data = FormData.fromMap({...data, ...files});
      } else {
        throw ArgumentError('data must be Parameters when files is not null');
      }
    }
    // 处理请求体
    if (data != null) {
      if (contentType == ContentType.json) {
        data = jsonEncode(data);
      } else if (contentType == ContentType.multipart && data is Parameters) {
        data = FormData.fromMap(data);
      }
    }
    return data;
  }

  Map<String, dynamic> mergeListToMap(List<MapEntry<String, dynamic>> inputList) {
    return inputList.fold(
      {},
      (result, entry) {
        final key = entry.key;
        final value = entry.value;

        if (result.containsKey(key)) {
          if (result[key] is List) {
            (result[key] as List).add(value);
          } else {
            result[key] = [result[key], value];
          }
        } else {
          result[key] = value;
        }

        return result;
      },
    );
  }
}
