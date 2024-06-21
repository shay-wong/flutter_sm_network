// ignore_for_file: public_member_api_docs, sort_constructors_first
class APIPagingConfig {
  APIPagingConfig({
    this.numberKey = '',
    this.pageNumber = 1,
    this.pageSize = 10,
    this.sizeKey = '',
  });

  final String numberKey;
  final int pageNumber;
  final int pageSize;
  final String sizeKey;

  APIPagingConfig copyWith({
    String? numberKey,
    int? pageNumber,
    int? pageSize,
    String? sizeKey,
  }) {
    return APIPagingConfig(
      numberKey: numberKey ?? this.numberKey,
      pageNumber: pageNumber ?? this.pageNumber,
      pageSize: pageSize ?? this.pageSize,
      sizeKey: sizeKey ?? this.sizeKey,
    );
  }
}
