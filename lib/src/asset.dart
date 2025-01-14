class Asset {
  /// 请求唯一标识，插件内部生成, 用于恢复草稿
  String? requestId;

  /// 资源在手机数据库中的唯一标识
  String? _identifier;

  /// 文件沙盒路径
  String? _filePath;

  /// 文件名
  String? _name;

  /// 图片或者视频的宽度
  double? _originalWidth;

  /// 图片或者视频的高度
  double? _originalHeight;

  /// 文件类型 “video/mp4” or "image/jpg" or "image/png"
  String? _fileType;

  // 送审图沙盒路径
  String? checkPath;

  /// 视频时长
  double? duration = 0.0;

  // 视频封面沙盒路径
  String? thumbFilePath = "";

  /// 视频封面名称
  String? thumbName = "";

  /// 视频封面宽度
  double? thumbWidth = 0.0;

  /// 视频封面高度
  double? thumbHeight = 0.0;

  String url = "";

  String hash = "";

  /// 如果加载不出资源的错误
  String? errorCode = "0";

  Asset(this._identifier, this._filePath, this._name, this._originalWidth,
      this._originalHeight, this._fileType,
      {this.requestId = "",
      this.thumbFilePath = "",
      this.thumbName = "",
      this.thumbWidth = 0.0,
      this.thumbHeight = 0.0,
      this.duration = 0.0,
      this.hash = "",
      this.checkPath = "",
      this.url = "",
      this.errorCode = "0"});

  /// Returns the original image width
  double? get originalWidth {
    return _originalWidth;
  }

  /// Returns the original image height
  double? get originalHeight {
    return _originalHeight;
  }

  /// Returns true if the image is landscape
  bool get isLandscape {
    return _originalWidth! > _originalHeight!;
  }

  /// Returns true if the image is Portrait
  bool get isPortrait {
    return _originalWidth! < _originalHeight!;
  }

  /// Returns the image identifier
  String? get identifier {
    return _identifier;
  }

  /// Returns the image thumb
  String? get filePath {
    return _filePath;
  }

  /// Returns the image name
  String? get name {
    return _name;
  }

  String? get fileType {
    return _fileType;
  }

  Map<String, dynamic> toJsonMap() {
    Map<String, dynamic> assetInfo = {};
    assetInfo['identifier'] = identifier;
    assetInfo['filePath'] = filePath;
    assetInfo['checkPath'] = checkPath;
    assetInfo['name'] = name;
    assetInfo['originalWidth'] = originalWidth;
    assetInfo['originalHeight'] = originalHeight;
    assetInfo['fileType'] = fileType;
    assetInfo['duration'] = duration;
    assetInfo['thumbFilePath'] = thumbFilePath;
    assetInfo['thumbHeight'] = thumbHeight;
    assetInfo['thumbWidth'] = thumbWidth;
    assetInfo['thumbName'] = thumbName;
    assetInfo['url'] = url;
    assetInfo['hash'] = hash;
    assetInfo['errorCode'] = errorCode;
    assetInfo['requestId'] = requestId;
    return assetInfo;
  }

  factory Asset.fromJson(Map<String, dynamic> srcJson) {
    return Asset(
        srcJson['identifier'] ?? '',
        srcJson['filePath'] ?? '',
        srcJson['name'] ?? '',
        srcJson['originalWidth'] ?? 0.0,
        srcJson['originalHeight'] ?? 0.0,
        srcJson['fileType'] ?? '',
        checkPath: srcJson['checkPath'] ?? '',
        duration: srcJson['duration'] ?? 0.0,
        thumbFilePath: srcJson['thumbFilePath'] ?? '',
        thumbHeight: srcJson['thumbHeight'] ?? 0.0,
        thumbWidth: srcJson['thumbWidth'] ?? 0.0,
        thumbName: srcJson['thumbName'] ?? '',
        url: srcJson['url'] ?? '',
        hash: srcJson['hash'] ?? '',
        errorCode: srcJson['errorCode'] ?? '',
        requestId: srcJson['requestId'] ?? '');
  }
}
