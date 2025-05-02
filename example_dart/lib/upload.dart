import 'package:example_dart/example.dart';
import 'package:sm_network/sm_network.dart';

Future<void> main(List<String> args) async {
  configHttp(baseUrl: 'https://httpbin.org/');

  // Create a Fileds
  final fileds = {'age': 25};

  // Create a Files
  final files = {
    'file': await MultipartFile.fromFile(
      '../assets/upload.txt',
      filename: 'upload.txt',
    ),
  };
  // Send FormData
  Http.upload(
    path: '/test',
    fields: fileds,
    files: files,
  );
}
