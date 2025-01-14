import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

import 'asset.dart';
import 'channel_api.dart';
import 'cupertino_options.dart';
import 'material_options.dart';

/*
接口定义文档
https://idreamsky.feishu.cn/docs/doccnx6GVcWRSAoPLKaN003ofKd#ATnyUC
 */

//约定所有invokeMethod方法前面加editor  eg. editor.showMediaPicker
const String function_initnvs = "editor.initnvs";
const String function_destroyNvs = "editor.destroyNvs";
const String function_showMediaPicker = "editor.showMediaPicker";
const String function_pickVideoCover = "editor.pickVideoCover";
const String function_sdkDataCachePath = "editor.sdkDataCachePath";
const String function_recoverFromDraft = "editor.recoverFromDraft";
const String function_previewVideo = "editor.previewVideo";
const String function_generateVideo = "editor.generateVideo";
const String function_deleteDraft = "editor.deleteDraft";
const String function_userDataCachePath = "editor.userDataCachePath";
const String function_isDraftExist = "editor.isDraftExist";

const String arg_requestId = "requestId";
const String arg_maxImages = "maxImages";
const String arg_thumb = "thumb";
const String arg_mediaSelectTypes = "mediaSelectTypes";
const String arg_doneButtonText = "doneButtonText";
const String arg_iosOptions = "iosOptions";
const String arg_androidOptions = "androidOptions";
const String arg_defaultAsset = "defaultAsset";
const String arg_selectedAssets = "selectedAssets";
const String arg_mediaShowTypes = "mediaShowTypes";
const String arg_checkPermissionForAndroid = "checkPermission";

class MediaPicker {
  /*
  初始化美摄授权文件，目前看来iOS需求
   */
  static Future<Map<dynamic, dynamic>?> verifyLicenseFile({Map? params}) async {
    try {
      if (Platform.isIOS) {
        final Map<dynamic, dynamic>? medias =
            await channel.invokeMethod("editor.verifyLicenseFile");
        return medias;
      }
      return null;
    } on PlatformException catch (e) {
      throw e;
    }
  }

  /*
  初始化每摄SDK
   */
  static Future<Map<dynamic, dynamic>?> setupNvs({Map? params}) async {
    try {
      final Map<dynamic, dynamic>? medias =
          await channel.invokeMethod(function_initnvs);
      return medias;
    } on PlatformException catch (e) {
      throw e;
    }
  }

  /*
  销毁NvsStreamingContext类的对象
   */
  static Future destroyNvsContext() async {
    try {
      await channel.invokeMethod(function_destroyNvs);
    } on PlatformException catch (e) {
      throw e;
    }
  }

  /*
  展示编辑图片选择器
   */
  static Future<List<Asset?>> showMediaPicker({
    int maxImages = 9,
    FBMediaThumbType thumbType = FBMediaThumbType.thumb,
    String defaultAsset = "",
    FBMediaSelectType mediaSelectType = FBMediaSelectType.all,
    List<String?> selectedAssets = const [],
    String doneButtonText = '',
    FBMediaShowType mediaShowType = FBMediaShowType.all,
    CupertinoOptions cupertinoOptions = const CupertinoOptions(),
    MaterialOptions materialOptions = const MaterialOptions(),
    Map<String, String> apiReqHeader = const {},
    bool checkPermissionForAndroid = true,
  }) async {
    try {
      final List<dynamic> res = await channel.invokeMethod(
        function_showMediaPicker,
        <String, dynamic>{
          arg_maxImages: maxImages,
          arg_thumb: thumbType.nameString(),
          arg_mediaSelectTypes: mediaSelectType.nameString(),
          arg_doneButtonText: doneButtonText,
          arg_iosOptions: cupertinoOptions.toJson(),
          arg_androidOptions: materialOptions.toJson(),
          arg_defaultAsset: defaultAsset,
          arg_mediaShowTypes: mediaShowType.nameString(),
          arg_selectedAssets: selectedAssets,
          arg_checkPermissionForAndroid: checkPermissionForAndroid ? 1 : 0,
        },
      );
      List<Asset?> assets = [];
      for (var mode in res) {
        try {
          final item = Map<String, dynamic>.from(mode);
          final asset = Asset.fromJson(item);
          assets.add(asset);
        } catch (e) {
          print("media_picker error ${e.toString()}");
        }
      }
      return assets;
    } on PlatformException catch (e) {
      throw e;
    }
  }

  /*
  选择相册封面
   */
  static Future<Asset?> pickVideoCover({required String requestId}) async {
    try {
      final Map<dynamic, dynamic>? rep = await channel
          .invokeMethod(function_pickVideoCover, {arg_requestId: requestId});
      return Asset.fromJson(Map<String, dynamic>.from(rep!));
    } on PlatformException catch (e) {
      throw e;
    }
  }

  /*
  获取媒体编辑缓存路径
   */
  static Future<String?> sdkDataCachePath() async {
    try {
      final String? path =
          await channel.invokeMethod(function_sdkDataCachePath);
      return path;
    } on PlatformException catch (e) {
      throw e;
    }
  }

  /*
  用户数据缓存路径
   */
  static Future<String?> userDataCachePath() async {
    try {
      final String? path =
          await channel.invokeMethod(function_userDataCachePath);
      return path;
    } on PlatformException catch (e) {
      throw e;
    }
  }

  /*
  从草稿恢复编辑
   */
  static Future<List<Asset?>> reEditorMedia(
      {required List<String> requestIds, int index = 0}) async {
    try {
      final List<dynamic> res = await channel.invokeMethod(
          function_recoverFromDraft,
          {"requestIds": requestIds, "index": index});
      List<Asset?> assets = [];
      for (var mode in res) {
        try {
          final item = Map<String, dynamic>.from(mode);
          final asset = Asset.fromJson(item);
          assets.add(asset);
        } catch (e) {
          print("reEditorMedia error ${e.toString()}");
        }
      }
      return assets;
    } on PlatformException catch (e) {
      throw e;
    }
  }

  /*
  预览视频
   */
  static Future<void> previewVideo({required String requestId}) async {
    try {
      await channel
          .invokeMethod(function_previewVideo, {arg_requestId: requestId});
    } on PlatformException catch (e) {
      throw e;
    }
  }

  /*
  生成视频
  */
  static Future<String> generateVideo({
    required String requestId,
    ProgressCallback? progressCallback,
  }) async {
    try {
      MediaChannelApi.progressCallback = progressCallback;
      MediaChannelApi.init();
      final path = await channel
          .invokeMethod(function_generateVideo, {arg_requestId: requestId});
      return path;
    } on PlatformException catch (e) {
      throw e;
    }
  }

  /*
  给资源添加水印, 默认添加到资源的右下角
   {"user_info":{"user_id":"12123","user_avater":"local_path","user_nick":"nick"},"watermark":{"url":"local_path","x":9,"y":3,"w":12,"h":23,"align":"bottom"}}
   */
  static Future<String> mediaAddWatermark(
      {required String mediaPath, String? watermarkPath, Map? userInfo}) async {
    try {
      final path = await channel.invokeMethod("editor.mediaAddWatermark", {
        "mediaPath": mediaPath,
        "watermarkPath": watermarkPath ?? "",
        "userInfo": userInfo ?? {}
      });
      return path;
    } on PlatformException catch (e) {
      throw e;
    }
  }

  /*
  删除草稿
   */
  static Future<void> deleteDraft({required String requestId}) async {
    try {
      await channel
          .invokeMethod(function_deleteDraft, {arg_requestId: requestId});
    } on PlatformException catch (e) {
      throw e;
    }
  }

  /*
  草稿是否存在
   */
  static Future<bool> isDraftExist({required String requestId}) async {
    try {
      final bool? rep = await channel
          .invokeMethod(function_isDraftExist, {arg_requestId: requestId});
      return rep ?? false;
    } on PlatformException catch (e) {
      throw e;
    }
  }

  /*
  根据沙盒图片视频生成requestId
  filePathList： 为沙盒绝对路径
  mediaShowType： image | video
   */
  static Future<List<Asset?>> makerRequestIdFromSandboxFile({
    required List<String> filePathList,
    FBMediaShowType mediaShowType = FBMediaShowType.image,
  }) async {
    try {
      final List<dynamic> res = await channel.invokeMethod(
        "editor.makerRequestIdFromSandboxFile",
        <String, dynamic>{
          "filePathList": filePathList,
          "mediaShowType": mediaShowType.nameString(),
        },
      );
      List<Asset?> assets = [];
      for (var mode in res) {
        try {
          final item = Map<String, dynamic>.from(mode);
          final asset = Asset.fromJson(item);
          assets.add(asset);
        } catch (e) {
          print("media_picker error ${e.toString()}");
        }
      }
      return assets;
    } on PlatformException catch (e) {
      throw e;
    }
  }
}
