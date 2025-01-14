import 'dart:async';

import 'package:flutter/services.dart';

const MethodChannel channel = const MethodChannel('multi_image_picker');

enum FBMediaShowType { image, video, all }

enum FBMediaSelectType { all, video, image, singleType }

enum FBMediaThumbType { origin, thumb, file }

extension FBMediaShowTypeValue on FBMediaShowType {
  String nameString() {
    switch (this) {
      case FBMediaShowType.video:
        return "video";
      case FBMediaShowType.image:
        return "image";
      case FBMediaShowType.all:
        return "all";
      default:
        return "";
    }
  }
}

extension FBMediaSelectTypeValue on FBMediaSelectType {
  String nameString() {
    switch (this) {
      case FBMediaSelectType.all:
        return "selectAll";
      case FBMediaSelectType.image:
        return "selectImage";
      case FBMediaSelectType.video:
        return "selectVideo";
      case FBMediaSelectType.singleType:
        return "selectSingleType";
      default:
        return "";
    }
  }
}

extension FBMediaThumbTypeValue on FBMediaThumbType {
  String nameString() {
    switch (this) {
      case FBMediaThumbType.thumb:
        return "thumb";
      case FBMediaThumbType.origin:
        return "origin";
      case FBMediaThumbType.file:
        return "file";
      default:
        return "";
    }
  }
}

typedef NavToSendCallback = Function(Map params);
typedef ProgressCallback = Function(String requestId, num progress);
typedef LogEventCallback = Function(String actionId, String actionSubId,
    String? actionEventSubParam, Map? extJson);

class MediaChannelApi {
  static NavToSendCallback? navToSendCallback;
  static ProgressCallback? progressCallback;
  static LogEventCallback? logEventCallback;

  static bool _isInit = false;
  static Future<void> init(
      {ProgressCallback? progress, LogEventCallback? logEvent}) async {
    if (progress != null) MediaChannelApi.progressCallback = progress;
    if (logEvent != null) MediaChannelApi.logEventCallback = logEvent;

    if (_isInit) return;
    _isInit = true;
    channel.setMethodCallHandler((MethodCall call) async {
      if (call.method == "showCircleSendPage") {
        //TO DO
        navToSendCallback?.call({});
      } else if (call.method == "generateVideoProgress") {
        final arg = call.arguments as Map;
        progressCallback?.call(arg['requestId'], arg['progress']);
      } else if (call.method == "upLogEvent") {
        final arg = call.arguments as Map;
        final actionId = arg['actionId'];
        final actionSubId = arg['actionSubId'];
        final actionEventSubParam = arg['actionEventSubParam'] ?? '';
        final extJson = arg['extJson'];
        logEventCallback?.call(
            actionId, actionSubId, actionEventSubParam, extJson);
      }
    });
  }

  static void clear() {
    progressCallback = null;
    logEventCallback = null;
    channel.setMethodCallHandler(null);
    _isInit = false;
  }
}
