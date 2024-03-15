import 'package:cross_file/cross_file.dart';
import 'package:flutter_sm_logger/sm_logger.dart';

import '../tencent_cos/tencent_cos.dart';
import 'api_session.dart';
import 'api_session_map.dart';

class CosAPI extends APISessionMap<CosAPIModel> {
  @override
  String get path => '/baseInfo/cosToken';

  @override
  CosAPIModel toObject(Parameters p) {
    return CosAPIModel.fromJson(p);
  }
}

class CosAPIModel {
  String? tmpSecretId;
  String? tmpSecretKey;
  String? sessionToken;

  CosAPIModel({this.tmpSecretId, this.tmpSecretKey, this.sessionToken});

  CosAPIModel.fromJson(Map<String, dynamic> json) {
    tmpSecretId = json['tmpSecretId'];
    tmpSecretKey = json['tmpSecretKey'];
    sessionToken = json['sessionToken'];
  }

  bool get isAvailable {
    return tmpSecretId?.isNotEmpty == true && tmpSecretKey?.isNotEmpty == true && sessionToken?.isNotEmpty == true;
  }
}

class CosManager {
  static const _bucketName = 'box-service-p-1303977104';
  static const _region = 'ap-hongkong';
  static const _folderName = 'activity/dynamic';
  static const _fileName = 'user_avatar';

  final String tempId;
  final String tempKey;
  final String token;

  CosManager({required this.tempId, required this.tempKey, required this.token});

  Future<String?> uploadImage(XFile file, {String folder = _folderName, String fileName = _fileName}) async {
    final imageData = await file.readAsBytes();
    final imageType = file.name.split('.').last;
    logger.d('[🐧🐧🐧 CosManager] 🏞️ ⬆️ ${file.toString()} name = ${file.name}');
    final fileName_ = '${fileName}_${DateTime.now().millisecondsSinceEpoch}-${file.name}';
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

  Future<List<String>> uploadImages(List<XFile> files, [String folder = _folderName]) async {
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
