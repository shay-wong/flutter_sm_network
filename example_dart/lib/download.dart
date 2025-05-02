import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:example_dart/example.dart';
import 'package:sm_network/sm_network.dart';

// In this example we download a image and listen the downloading progress.
void main() async {
  configHttp(headers: {
    // Assure the value of total argument of onReceiveProgress is not -1.
    'HttpHeaders.acceptEncodingHeader': '*',
  });

  final url = 'https://pub.dev/static/hash-rhob5slb/img/pub-dev-logo.svg';
  await download1(url, './download/pub-dev-logo.svg');
  await download1(url, (headers) => './download/pub-dev-logo-1.svg');
  await download1(url, (headers) async => './download/pub-dev-logo-2.svg');
  // await download2(url, './download/pub-dev-logo-3.svg');
  // await download1(url, (headers) => './download/pub-dev-logo-4.svg');
  // await download1(url, (headers) async => './download/pub-dev-logo-5.svg');
}

Future download1(String url, savePath) async {
  final cancelToken = CancelToken();
  try {
    final resp = await Http.download(
      path: url,
      savePath: savePath,
      onReceiveProgress: showDownloadProgress,
      cancelToken: cancelToken,
    );
    print(resp);
  } catch (e) {
    print(e);
  }
}

//Another way to downloading small file
Future download2(String url, String savePath) async {
  try {
    final response = await Http.get<Uint8List>(
      path: url,
      onReceiveProgress: showDownloadProgress,
      //Received data with List<int>
      options: HttpOptions(
        responseType: ResponseType.bytes,
        followRedirects: false,
        receiveTimeout: Duration.zero,
      ),
    );
    // print(response.data?.headers);
    final file = File(savePath);
    final raf = file.openSync(mode: FileMode.write);
    // response.data is List<int> type
    if (response.data != null) {
      raf.writeFromSync(response.data!);
    }
    await raf.close();
  } catch (e) {
    print(e);
  }
}

void showDownloadProgress(int received, int total) {
  if (total <= 0) {
    return;
  }
  print('percentage: ${(received / total * 100).toStringAsFixed(0)}%');
}
