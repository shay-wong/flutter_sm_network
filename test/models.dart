class Extra {
  Extra({
    this.responseData,
    this.response,
    this.status = true,
    this.statusCode,
  });

  final dynamic response;
  final dynamic responseData;
  final bool status;
  final int? statusCode;

  Map<String, dynamic> toJson() => {
        'response_data': responseData,
        'response': response,
        'status': status,
        'statusCode': statusCode,
      };
}

class Person {
  Person(this.name, this.age);

  factory Person.fromJson(Map<String, dynamic> srcJson) => Person(
        srcJson['name'] as String?,
        srcJson['age'] as num?,
      );

  final num? age;
  final String? name;

  Map<String, dynamic> toJson() => {
        'age': age,
        'name': name,
      };
}
