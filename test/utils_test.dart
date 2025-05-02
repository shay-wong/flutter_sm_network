import 'package:flutter_test/flutter_test.dart';
import 'package:sm_network/sm_network.dart';
import 'package:sm_network/src/utils.dart';

void main() {
  final utils = Utils.shared;
  Object? data;
  FormFiles? files;

  test(
    'test process data when files is not null',
    () async {
      data = {'age': 25};
      files = {
        'file': await MultipartFile.fromFile(
          './assets/upload.txt',
          filename: 'upload.txt',
        ),
      };
      final result = utils.processData(
        data: data,
        files: files,
      );
      expect(result, isA<FormData>());
    },
  );

  test(
    'test process data when data is not null',
    () async {
      data = {
        'age': 25,
        'file': await MultipartFile.fromFile(
          './assets/upload.txt',
          filename: 'upload.txt',
        ),
      };
      final result = utils.processData(
        data: data,
        contentType: ContentType.multipart,
      );
      expect(result, isA<FormData>());
    },
  );
}
