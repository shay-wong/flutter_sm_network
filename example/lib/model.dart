// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter_sm_network/sm_network.dart';

abstract class APIRequest<T> with APIOptions<T>, APIDioMixin<T, BaseModel<T>> {
  @override
  BaseModel<T> createResponder(data) {
    return BaseModel.fromJson(data, (json) => parseJson(json));
  }
}

class BaseModel<T> extends APIResponder<T> {
  BaseModel({
    super.code,
    super.data,
    super.dataList,
    super.extra,
    super.message,
    super.success,
    this.serviceInfo,
  });

  final String? serviceInfo;

  factory BaseModel.fromJson(
    Map<String, dynamic> json, [
    FromJsonT<T>? fromJsonT,
  ]) {
    final responder = APIResponder.fromJson(json, fromJsonT);
    return BaseModel<T>(
      code: responder.code,
      data: responder.data,
      dataList: responder.dataList,
      extra: responder.extra,
      message: responder.message,
      success: responder.success,
      serviceInfo: json['serviceInfo'] as String? ?? '123',
    );
  }

  @override
  String toString() =>
      'BaseModel(serviceInfo: $serviceInfo)super=>${super.toString()}';
}
