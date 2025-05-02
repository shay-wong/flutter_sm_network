import 'dart:convert';
import 'dart:io';

import 'package:example_dart/example.dart';
import 'package:sm_network/io.dart';
import 'package:sm_network/sm_network.dart';

/// FormData will create readable "multipart/form-data" streams.
/// It can be used to submit forms and file uploads to http server.
void main() async {
  configHttp(
    baseUrl: 'http://localhost:3000/',
    httpClientAdapter: IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.findProxy = (uri) {
          // Proxy all request to localhost:8888
          return 'PROXY localhost:8888';
        };
        client.badCertificateCallback = (cert, host, port) => true;
        return client;
      },
    ),
  );
  BaseResp response;

  final data1 = await formData1();
  final data2 = await formData2();
  final bytes1 = await data1.readAsBytes();
  final bytes2 = await data2.readAsBytes();
  assert(bytes1.length == bytes2.length);

  final data3 = await formData3();
  print(utf8.decode(await data3.readAsBytes()));

  response = await Http.post(
    path: 'http://localhost:3000/upload',
    data: data3,
    onSendProgress: (sent, total) {
      if (total <= 0) {
        return;
      }
      print('percentage: ${(sent / total * 100).toStringAsFixed(0)}%');
    },
  );
  print(response);
}

Future<FormData> formData1() async {
  return FormData.fromMap({
    'name': 'wendux',
    'age': 25,
    'file': await MultipartFile.fromFile(
      '../assets/xx.png',
      filename: 'xx.png',
    ),
    'files': [
      await MultipartFile.fromFile(
        '../assets/upload.txt',
        filename: 'upload.txt',
      ),
      MultipartFile.fromFileSync(
        '../assets/upload.txt',
        filename: 'upload.txt',
      ),
    ],
  });
}

Future<FormData> formData2() async {
  final formData = FormData();

  formData.fields
    ..add(
      const MapEntry(
        'name',
        'wendux',
      ),
    )
    ..add(
      const MapEntry(
        'age',
        '25',
      ),
    );

  formData.files.add(
    MapEntry(
      'file',
      await MultipartFile.fromFile(
        '../assets/xx.png',
        filename: 'xx.png',
      ),
    ),
  );

  formData.files.addAll([
    MapEntry(
      'files',
      await MultipartFile.fromFile(
        '../assets/upload.txt',
        filename: 'upload.txt',
      ),
    ),
    MapEntry(
      'files',
      MultipartFile.fromFileSync(
        '../assets/upload.txt',
        filename: 'upload.txt',
      ),
    ),
  ]);
  return formData;
}

Future<FormData> formData3() async {
  return FormData.fromMap({
    'file': await MultipartFile.fromFile(
      '../assets/upload.txt',
      filename: 'uploadfile',
    ),
  });
}
