class CupertinoOptions {
  final String selectionStrokeColor;
  final String selectionFillColor;
  final String selectionTextColor;
  final String selectionCharacter;
  final String takePhotoIcon;
  final int videoCanPickLimitSize;
  final int videoCanPickLimitDuration;

  ///图片大小限制
  final int imageCanPickLimitSize;

  ///图片像素限制
  final int imageCanPickLimitPixel;

  ///图片边长限制
  final int imageCanPickLimitSide;

  ///是否需要从iCloud下载
  final int mediaCanDownloadFromiCloud;

  const CupertinoOptions(
      {this.selectionFillColor = "",
      this.selectionStrokeColor = "",
      this.selectionTextColor = "",
      this.selectionCharacter = "",
      this.takePhotoIcon = "",
      this.mediaCanDownloadFromiCloud = 0,
      this.videoCanPickLimitSize = 50 << 30,
      this.videoCanPickLimitDuration = 0,
      this.imageCanPickLimitSize = 100 << 20,
      this.imageCanPickLimitPixel = 10000 * 10000,
      this.imageCanPickLimitSide = 0});

  Map<String, String> toJson() {
    return {
      "selectionFillColor": selectionFillColor,
      "selectionStrokeColor": selectionStrokeColor,
      "selectionTextColor": selectionTextColor,
      "selectionCharacter": selectionCharacter,
      "takePhotoIcon": takePhotoIcon,
      "mediaCanDownloadFromiCloud": "$mediaCanDownloadFromiCloud",
      "videoCanPickLimitSize": "$videoCanPickLimitSize",
      "videoCanPickLimitDuration": "$videoCanPickLimitDuration",
      "imageCanPickLimitSize": "$imageCanPickLimitSize",
      "imageCanPickLimitPixel": "$imageCanPickLimitPixel",
      "imageCanPickLimitSide": "$imageCanPickLimitSide"
    };
  }
}
