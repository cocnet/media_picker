class MaterialOptions {
  final String actionBarColor;
  final String statusBarColor;
  final bool lightStatusBar;
  final String actionBarTitleColor;
  final String allViewTitle;
  final String actionBarTitle;
  final bool startInAllView;
  final bool useDetailsView;
  final String selectCircleStrokeColor;
  final String selectionLimitReachedText;
  final String textOnNothingSelected;
  final String backButtonDrawable;
  final String okButtonDrawable;
  final bool autoCloseOnSelectionLimit;

  ///视频大小限制
  final int videoCanPickLimitSize;

  ///视频时长限制
  final int videoCanPickLimitDuration;

  ///图片大小限制
  final int imageCanPickLimitSize;

  ///图片像素限制
  final int imageCanPickLimitPixel;

  ///图片边长限制
  final int imageCanPickLimitSide;

  const MaterialOptions({
    this.actionBarColor = "",
    this.actionBarTitle = "",
    this.lightStatusBar = false,
    this.statusBarColor = "",
    this.actionBarTitleColor = "",
    this.allViewTitle = "",
    this.startInAllView = false,
    this.useDetailsView = false,
    this.selectCircleStrokeColor = "",
    this.selectionLimitReachedText = "",
    this.textOnNothingSelected = "",
    this.backButtonDrawable = "",
    this.okButtonDrawable = "",
    this.autoCloseOnSelectionLimit = false,
    this.videoCanPickLimitSize = 50 << 30,
    this.videoCanPickLimitDuration = 0,
    this.imageCanPickLimitSize = 0,
    this.imageCanPickLimitPixel = 10000 * 10000,
    this.imageCanPickLimitSide = 0,
  });

  Map<String, String> toJson() {
    return {
      "actionBarColor": actionBarColor,
      "actionBarTitle": actionBarTitle,
      "actionBarTitleColor": actionBarTitleColor,
      "allViewTitle": allViewTitle,
      "lightStatusBar": lightStatusBar ? "true" : "false",
      "statusBarColor": statusBarColor,
      "startInAllView": startInAllView ? "true" : "false",
      "useDetailsView": useDetailsView ? "true" : "false",
      "selectCircleStrokeColor": selectCircleStrokeColor,
      "selectionLimitReachedText": selectionLimitReachedText,
      "textOnNothingSelected": textOnNothingSelected,
      "backButtonDrawable": backButtonDrawable,
      "okButtonDrawable": okButtonDrawable,
      "autoCloseOnSelectionLimit": autoCloseOnSelectionLimit ? "true" : "false",
      "videoCanPickLimitSize": "$videoCanPickLimitSize",
      "videoCanPickLimitDuration": "$videoCanPickLimitDuration",
      "imageCanPickLimitSize": "$imageCanPickLimitSize",
      "imageCanPickLimitPixel": "$imageCanPickLimitPixel",
      "imageCanPickLimitSide": "$imageCanPickLimitSide",
    };
  }
}
