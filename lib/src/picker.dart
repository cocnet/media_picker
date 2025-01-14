import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

const CachedImageCount = 50;

class MultiImagePicker {
  static final Map<String, Uint8List> _cacheThumbData = Map();

  static Future<List<Album>> loadAlbums() async {
    try {
      final List<dynamic> result = await channel.invokeMethod('loadAlbums');
      final data = result
          .map((e) => Album(
              e['albumId'] ?? 0,
              e['albumName'] ?? '',
              e['count'] ?? 0,
              e['thumbPath'] ?? '',
              e['thumbIdentifier'] ?? ''))
          .toList();
      return data;
    } on PlatformException catch (e) {
      throw e;
    }
  }

  /// 弹出原生选择界面,返回选择的媒体信息, [albumDetail]仅安卓起作用，用于打开指定专辑下的详情滚动页
  static Future<Map<dynamic, dynamic>?> pickImages({
    int maxImages = 9,
    FBMediaThumbType thumbType = FBMediaThumbType.thumb,
    String defaultAsset = "",
    FBMediaSelectType mediaSelectType = FBMediaSelectType.all,
    List<String> selectedAssets = const [],
    String doneButtonText = '',
    FBMediaShowType mediaShowType = FBMediaShowType.all,
    CupertinoOptions cupertinoOptions = const CupertinoOptions(),
    MaterialOptions materialOptions = const MaterialOptions(),
    int? albumId,
    bool albumDetail = false,
  }) async {
    try {
      final Map<dynamic, dynamic>? medias = await channel.invokeMethod(
        'pickImages',
        <String, dynamic>{
          'maxImages': maxImages,
          'thumb': thumbType.nameString(),
          'mediaSelectTypes': mediaSelectType.nameString(),
          'doneButtonText': doneButtonText,
          'iosOptions': cupertinoOptions.toJson(),
          'androidOptions': materialOptions.toJson(),
          'defaultAsset': defaultAsset,
          'mediaShowTypes': mediaShowType.nameString(),
          'selectedAssets': selectedAssets,
          'albumId': albumId,
          'albumDetail': albumDetail,
        },
      );
      return medias;
    } on PlatformException catch (e) {
      throw e;
    }
  }

  // 获取指定媒体信息 selectedAssets 为指定媒体的Identify
  static Future<List<Asset?>> requestMediaData(
      {bool thumb = true,
      List<String> selectedAssets = const [],
      List<Asset> defalutValue = const []}) async {
    try {
      // if (!Platform.isIOS && !Platform.isAndroid) return defalutValue;
      final List<dynamic> images = await (channel.invokeMethod(
          'requestMediaData',
          <String, dynamic>{'thumb': thumb, 'selectedAssets': selectedAssets}));
      List<Asset?> assets = [];
      for (var item in images) {
        var asset;
        final String fileType = item['fileType'] ?? "";
        final String? errorCode = item['errorCode'];
        if (fileType.isEmpty) {
          asset = Asset(item['identifier'], '', '', 0.0, 0.0, '',
              errorCode: errorCode);
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
            duration: double.parse("${item['duration']}"),
            thumbFilePath: item['thumbPath'],
            thumbName: item['thumbName'],
            thumbHeight: double.parse("${item['thumbHeight']}"),
            thumbWidth: double.parse("${item['thumbWidth']}"),
          );
        }
        _cacheThumbData.remove(item['identifier']);
        assets.add(asset);
      }
      return assets;
    } on PlatformException catch (e) {
      throw e;
    }
  }

  // 压缩指定的媒体
  // param:
  // fileType: video/mp4 image/jpg image/png image/gif
  static Future<List<Asset?>> requestCompressMedia(bool thumb,
      {String fileType = "",
      List<String> fileList = const [],
      List<Asset> defalutValue = const []}) async {
    if (!Platform.isIOS && !Platform.isAndroid) return defalutValue;
    try {
      final List<dynamic> images = await (channel.invokeMethod(
          'requestCompressMedia', <String, dynamic>{
        'thumb': thumb,
        'fileType': fileType,
        'fileList': fileList
      }));
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

  static Future<Asset?> requestTakePicture(
      {String themeColor = "0xFF00CC00"}) async {
    try {
      final dynamic item = await channel.invokeMethod(
          'requestTakePicture', <String, dynamic>{'themeColor': themeColor});
      var asset = Asset(
        item['identifier'],
        item['filePath'],
        item['name'],
        double.parse("${item['width']}"),
        double.parse("${item['height']}"),
        item['fileType'],
        checkPath: item['checkPath'],
        duration: item['duration'],
        thumbFilePath: item['thumbPath'],
        thumbName: item['thumbName'],
        thumbHeight: item['thumbHeight'],
        thumbWidth: item['thumbWidth'],
      );
      return asset;
    } on PlatformException catch (e) {
      throw e;
    } on Exception catch (e) {
      print(e);
    }
    return null;
  }

  //根据identifier来请求媒体的宽高
  static Future<dynamic> requestFileDimen(String identifier) async {
    try {
      return await channel.invokeMethod(
          'requestFileDimen', <String, dynamic>{'identifier': identifier});
    } on PlatformException catch (e) {
      throw e;
    }
  }

  ///根据identifier来请求媒体的大小
  static Future<int> requestAssetSize(String identifier) async {
    try {
      final fileSizeStr = await channel.invokeMethod(
          'requestFileSize', <String, dynamic>{'identifier': identifier});
      return int.tryParse("$fileSizeStr") ?? 0;
    } on PlatformException catch (e) {
      throw e;
    }
  }

  //是否缓存了视频在本地磁盘
  static Future<dynamic> cachedVideoPath(String url) async {
    try {
      return await channel
          .invokeMethod('cachedVideoPath', <String, dynamic>{'url': url});
    } on PlatformException catch (e) {
      throw e;
    }
  }

  //视频缓存目录在本地磁盘
  static Future<dynamic> cachedVideoDirectory() async {
    try {
      return await channel.invokeMethod('cachedVideoDirectory', null);
    } on PlatformException catch (e) {
      throw e;
    }
  }

  /// 删除视频缓存 iOS端使用原生删除视频缓存
  static Future<dynamic> deleteCacheVideo() async {
    try {
      return await channel.invokeMethod('deleteCacheVideo', null);
    } on PlatformException catch (e) {
      throw e;
    }
  }

  //获取图片视频的源文件路径
  static Future<dynamic> requestFilePath(String identifier) async {
    try {
      return await channel.invokeMethod(
          'requestFilePath', <String, dynamic>{'identifier': identifier});
    } on PlatformException catch (e) {
      throw e;
    }
  }

  //获取压缩文件存放的目录
  static Future<String?> requestThumbDirectory() async {
    try {
      return await channel.invokeMethod('requestThumbDirectory');
    } on PlatformException catch (e) {
      throw e;
    }
  }

  // 获取手机数据库中的媒体信息,或者获取指定identifier的媒体信息
  static Future<List<Asset>> fetchMediaInfo(int offset, int limit,
      {int? albumId,
      FBMediaShowType showType = FBMediaShowType.all,
      List<String> selectedAssets = const []}) async {
    try {
      final List<dynamic> images =
          await (channel.invokeMethod('fetchMediaInfo', <String, dynamic>{
        'limit': limit,
        'offset': offset,
        'mediaShowTypes': showType.nameString(),
        'selectedAssets': selectedAssets,
        'albumId': albumId,
      }));
      List<Asset> assets = [];
      for (var item in images) {
        var asset = Asset(
            item['identifier'],
            item['filePath'],
            item['name'],
            double.parse("${item['width']}"),
            double.parse("${item['height']}"),
            item['fileType'],
            duration: double.parse("${item['duration']}"));
        assets.add(asset);
      }
      return assets;
    } on PlatformException catch (e) {
      throw e;
    }
  }

  // 获取指定媒体的缩略图或者视频封面
  // fileType 设为可选参数,当fileType为空时,插件会根据identify去查询当前媒体类型
  static Future<Uint8List> fetchMediaThumbData(String identifier,
      {String fileType = "", bool thumb = true}) async {
    try {
      if (_cacheThumbData.containsKey(identifier)) {
        return _cacheThumbData[identifier] ?? Uint8List(0);
      } else {
        final retValue =
            await channel.invokeMethod('fetchMediaThumbData', <String, dynamic>{
          'identifier': identifier,
          'fileType': fileType,
          'thumb': thumb ? 'thumb' : 'origin'
        });
        Uint8List? imgData;
        if (retValue is String) {
          //鸿蒙可能返回沙盒文件路径
          final f = File(retValue);
          imgData = f.readAsBytesSync();
        } else {
          imgData = retValue as Uint8List?;
        }
        imgData ??= Uint8List(0);
        if (_cacheThumbData.length > CachedImageCount) {
          _cacheThumbData.remove(_cacheThumbData.keys.first);
        }
        if (imgData.isNotEmpty) {
          _cacheThumbData[identifier] = imgData;
        }
        return imgData;
      }
    } on PlatformException catch (e) {
      throw e;
    }
  }

  // 是否缓存了某个媒体的封面
  static bool containCacheData(String identifier) {
    return _cacheThumbData.containsKey(identifier);
  }

  // 获取缓存的某个媒体封面
  static Uint8List fetchCacheThumbData(String identifier) {
    try {
      return _cacheThumbData[identifier] ?? Uint8List(0);
    } on Exception catch (e) {
      print(e);
      return Uint8List(0);
    }
  }

  static Future<void> requestMediaPermissions() async {
    try {
      await channel.invokeMethod('requestMediaPermissions');
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
      final data =
          await channel.invokeMethod('obtainVideoCover', <String, dynamic>{
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
