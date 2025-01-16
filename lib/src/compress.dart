import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:multi_image_picker/media_compress.dart';


const CachedImageCount = 50;

class MediaCompress {
  static final Map<String, Uint8List> _cacheThumbData = Map();

  // 压缩指定的媒体
  // param:
  // fileType: video/mp4 image/jpg image/png image/gif
  static Future<List<Asset?>> requestCompressMedia(bool thumb,
      {String fileType = "",
      List<String> fileList = const [],
      List<Asset> defalutValue = const []}) async {
    if (!Platform.isIOS && !Platform.isAndroid) return defalutValue;
    try {
      final List<dynamic> images = await (channel.invokeMethod('requestCompressMedia',
          <String, dynamic>{'thumb': thumb, 'fileType': fileType, 'fileList': fileList}));
      List<Asset?> assets = [];
      for (var item in images) {
        var asset;
        final String? errorCode = item['errorCode'];
        if ((errorCode?.isNotEmpty ?? false) && errorCode != "0") {
          asset = Asset('', '', '', 0.0, 0.0, '', errorCode: errorCode);
        } else if (fileType.contains('image')) {
          asset = Asset(
            item['identifier'],
            item['filePath'],
            item['name'],
            double.parse("${item['width']}"),
            double.parse("${item['height']}"),
            item['fileType'],
            checkPath: item['checkPath'],
          );
        } else if (fileType.contains('video')) {
          asset = Asset(
            item['identifier'],
            item['filePath'],
            item['name'],
            double.parse("${item['width']}"),
            double.parse("${item['height']}"),
            item['fileType'],
            duration: item['duration'],
            thumbFilePath: item['thumbPath'],
            thumbName: item['thumbName'],
            thumbHeight: item['thumbHeight'],
            thumbWidth: item['thumbWidth'],
          );
        }
        assets.add(asset);
      }
      return assets;
    } on PlatformException catch (e) {
      throw e;
    }
  }

  /*
  鸿蒙系统使用
   */
  static Future<String?> obtainVideoCover(String identifier,
      {String fileType = "", bool thumb = true}) async {
    try {
      final data = await channel.invokeMethod('obtainVideoCover', <String, dynamic>{
        'identifier': identifier,
        'fileType': fileType,
        'thumb': thumb ? 'thumb' : 'origin'
      });
      return data;
    } on PlatformException catch (e) {
      throw e;
    }
  }
}
