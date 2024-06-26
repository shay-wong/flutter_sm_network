import 'package:cross_file/cross_file.dart';
import 'package:sm_logger/sm_logger.dart';

import '../tencent_cos/tencent_cos.dart';

class CosAPIModel {
  CosAPIModel({this.tmpSecretId, this.tmpSecretKey, this.sessionToken});

  CosAPIModel.fromJson(Map<String, dynamic> json) {
    tmpSecretId = json['tmpSecretId'];
    tmpSecretKey = json['tmpSecretKey'];
    sessionToken = json['sessionToken'];
  }

  String? sessionToken;
  String? tmpSecretId;
  String? tmpSecretKey;

  bool get isAvailable {
    return tmpSecretId?.isNotEmpty == true &&
        tmpSecretKey?.isNotEmpty == true &&
        sessionToken?.isNotEmpty == true;
  }
}

class CosManager {
  CosManager(
      {required this.tempId, required this.tempKey, required this.token});

  static const _bucketName = '';
  static const _fileName = '';
  static const _folderName = '';
  static const _region = '';

  final String tempId;
  final String tempKey;
  final String token;

  Future<String?> uploadImage(XFile file,
      {String folder = _folderName, String fileName = _fileName}) async {
    final imageData = await file.readAsBytes();
    final imageType = file.name.split('.').last;
    logger
        .d('[🐧🐧🐧 CosManager] 🏞️ ⬆️ ${file.toString()} name = ${file.name}');
    final fileName_ =
        '${fileName}_${DateTime.now().millisecondsSinceEpoch}-${file.name}';
    final cosPath = await COSClient(
      COSConfig(
        tempId,
        tempKey,
        _bucketName,
        _region,
      ),
    ).putObjectWithFileData(
      '$folder/$fileName_',
      imageData,
      contentType: 'image/$imageType',
      token: token,
    );
    if (cosPath?.isNotEmpty == true) {
      logger.i('[🐧🐧🐧 CosManager] 上传图片成功 $cosPath');
    }
    return cosPath;
  }

  Future<List<String>> uploadImages(List<XFile> files,
      [String folder = _folderName]) async {
    List<String> pathList = [];
    for (final file in files) {
      final filePath = await uploadImage(file, folder: folder);
      if (filePath != null) {
        pathList.add(filePath);
      }
    }
    return pathList;
  }
}
