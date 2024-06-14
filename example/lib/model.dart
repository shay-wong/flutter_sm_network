// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:sm_network/sm_network.dart';

part 'model.g.dart';

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

  @override
  bool get isSuccess => success ?? code == 1;

  factory BaseModel.fromJson(
    Map<String, dynamic> json, {
    FromJsonT<T>? fromJsonT,
    ParseJsonT<T>? parseJsonT,
  }) {
    final responder = APIResponder.fromJson(json,
        fromJsonT: fromJsonT, parseJsonT: parseJsonT);
    return BaseModel<T>(
      code: responder.code,
      data: responder.data,
      dataList: responder.dataList,
      extra: responder.extra,
      message: responder.message,
      success: json['code'] == 1,
      serviceInfo: json['serviceInfo'] as String?,
    );
  }

  final String? serviceInfo;

  @override
  String toString() =>
      'BaseModel(serviceInfo: $serviceInfo)super=>${super.toString()}';
}

@JsonSerializable()
class Person {
  Person(
    this.age,
    this.gender,
    this.name,
    this.friends,
    this.birthday,
    this.adulthood,
  );

  factory Person.fromJson(Map<String, dynamic> srcJson) =>
      _$PersonFromJson(srcJson);

  @JsonKey(name: 'age')
  num? age;

  @JsonKey(name: 'birthday')
  @StringDateTimeConverter()
  DateTime? birthday;

  @JsonKey(name: 'friends')
  List<Person>? friends;

  @JsonKey(name: 'gender')
  String? gender;

  @JsonKey(name: 'student')
  @BoolConverter()
  bool? isStudent;

  @JsonKey(name: 'name')
  String? name;

  @JsonKey(name: 'adulthood')
  @MilliEpochDateTimeConverter()
  DateTime? adulthood;

  @override
  String toString() {
    return 'Person( age: $age, gender: $gender, name: $name, birthday: $birthday, adulthood: $adulthood, isStudent: $isStudent, friends: $friends,)';
  }

  Map<String, dynamic> toJson() => _$PersonToJson(this);
}
