import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:permission_handler/permission_handler.dart';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:multi_image_picker_example/DemoLocalizations.dart';
import 'package:multi_image_picker_example/test_page.dart';

import 'DemoLocalizationsDelegate.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        DemoLocalizationsDelegate.delegate,
      ],
      supportedLocales: [
        const Locale('en'), // English
        const Locale('he', 'IL'), // Hebrew
        const Locale.fromSubtags(
            languageCode: 'zh'), // Chinese *See Advanced Locales below*
      ],
      home: new MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Asset> images = [];
  String _error = 'No Error Dectected';
  String mediaPickerString = "";

  //测试赋值
  String requestId = "08976cd4-b8b1-4d4f-b49b-a0c750f15d00";
  List<String> requestIds = [
    "039dcaf2-f47f-4ebe-bbf5-0fe44cbadb5d",
    "6192ecaf-d484-4266-9dbd-baa13864cac5",
    "0adf7c63-0875-43df-aba0-fec488ceb462",
  ];
  String? imagePreviewPath;
  String? imagePreviewInfo;
  Uint8List? imagePreviewData;

  @override
  void initState() {
    super.initState();

    MediaChannelApi.navToSendCallback = (Map p) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TestPage()),
      );
    };
    MediaChannelApi.progressCallback = (String reqId, num p) {
      print("$reqId --- $p");
    };
    MediaChannelApi.logEventCallback = (String actionId, String actionSubId,
        String? actionEventSubParam, Map? extJson) {
      print(
          "埋点日志： $actionId --- $actionSubId --- $actionEventSubParam  ---- $extJson");
    };
    MediaChannelApi.init();
  }

  Widget imagePreview() {
    if (imagePreviewPath != null) {
      File f = File(imagePreviewPath!);
      return GestureDetector(
        onTap: () {
          showDialog(
              context: context,
              builder: (c) {
                return SingleChildScrollView(
                    child: Column(children: [
                  Text(
                    "${imagePreviewInfo ?? ""}",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.amber),
                  ),
                  Image.file(
                    f,
                    fit: BoxFit.fitWidth,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(c).pop();
                    },
                    child: Text("Ok"),
                  ),
                ]));
              });
        },
        child: Container(
          width: double.infinity,
          height: 100,
          child: Image.file(
            f,
            fit: BoxFit.contain,
            height: 100,
          ),
        ),
      );
    }
    if (imagePreviewData != null) {
      return GestureDetector(
        onTap: () {
          showDialog(
              context: context,
              builder: (c) {
                return SingleChildScrollView(
                    child: Column(children: [
                  Image.memory(
                    imagePreviewData!,
                    fit: BoxFit.fitWidth,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(c).pop();
                    },
                    child: Text("Ok"),
                  ),
                ]));
              });
        },
        child: Container(
          width: double.infinity,
          height: 100,
          child: Image.memory(
            imagePreviewData!,
            fit: BoxFit.contain,
            height: 100,
          ),
        ),
      );
    }
    return SizedBox();
  }

  @override
  Widget build(BuildContext context) {

    return new Scaffold(
      appBar: new AppBar(
        title: Text(DemoLocalizations.of(context).titleBarTitle),
      ),
      body: Container(
        height: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Center(child: Text('Error: $_error')),
              Container(
                child: Wrap(
                  spacing: 10,
                  children: [
                    ElevatedButton(
                      child: Text(DemoLocalizations.of(context).imagePick),
                      onPressed: loadAssets,
                    ),
                    ElevatedButton(
                      child: Text('获取图片所有专辑列表'),
                      onPressed: loadAlbums,
                    ),
                    ElevatedButton(
                      child: Text('获取专辑下的图片'),
                      onPressed: fetchPhotoInAlbums,
                    ),
                    ElevatedButton(
                        onPressed: () async {
                          final dir =
                              await MultiImagePicker.requestThumbDirectory();
                          print('图片缓存文件夹dir: $dir');
                        },
                        child: Text('图片缓存文件夹')),
                    ElevatedButton(
                      onPressed: () async {
                        final dir =
                            await MultiImagePicker.cachedVideoDirectory();
                        print('视频缓存文件夹: $dir');
                      },
                      child: Text('视频缓存文件夹'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await MultiImagePicker.requestMediaPermissions();
                      },
                      child: Text('申请权限'),
                    ),
                    ElevatedButton(
                      child: Text("鸿蒙选择图片"),
                      onPressed: loadHarmonyAssets,
                    ),
                    ElevatedButton(
                      child: Text("获取视频封面"),
                      onPressed: obtianVideoCover,
                    ),
                  ],
                ),
              ),
              Divider(),
              Center(
                child: Text("媒体编辑（美摄SDK）",
                    style:
                        TextStyle(fontWeight: FontWeight.w500, fontSize: 25)),
              ),
              Wrap(
                direction: Axis.horizontal,
                spacing: 5,
                children: [
                  Container(
                    width: double.infinity,
                    child: Text("$requestId"),
                  ),
                  Container(
                    width: double.infinity,
                    child: Text("$mediaPickerString"),
                  ),
                  imagePreview(),
                  ElevatedButton(
                      onPressed: () async {
                        final res = await MediaPicker.setupNvs();
                        setState(() {
                          mediaPickerString = "$res";
                        });
                      },
                      child: Text("初始化美摄SDK")),
                  ElevatedButton(
                      onPressed: () async {
                        final res = await MediaPicker.showMediaPicker(
                          maxImages: 4,
                          mediaSelectType: FBMediaSelectType.video,
                          selectedAssets: [],
                          doneButtonText: "下一步",
                          thumbType: FBMediaThumbType.origin,
                          cupertinoOptions: CupertinoOptions(
                            takePhotoIcon: "chat",
                            selectionStrokeColor: "#ff198CFE",
                            selectionFillColor: "#ff198CFE",
                            videoCanPickLimitSize: 500 << 20,
                          ),
                          materialOptions: MaterialOptions(
                            allViewTitle: "All Photos",
                            selectCircleStrokeColor: "#ff198CFE",
                            videoCanPickLimitSize: 500 << 20,
                          ),
                        );
                        res.forEach((r) => print("媒体编辑完成：${r!.requestId}"));
                        setState(() {
                          mediaPickerString = "$res";
                        });
                      },
                      child: Text('选择视频4张')),
                  ElevatedButton(
                      onPressed: () async {
                        final res = await MediaPicker.showMediaPicker(
                          maxImages: 5,
                          mediaSelectType: FBMediaSelectType.image,
                          selectedAssets: [],
                          doneButtonText: "下一步",
                          thumbType: FBMediaThumbType.origin,
                          cupertinoOptions: CupertinoOptions(
                              takePhotoIcon: "chat",
                              selectionStrokeColor: "#ff198CFE",
                              selectionFillColor: "#ff198CFE"),
                          materialOptions: MaterialOptions(
                              allViewTitle: "All Photos",
                              selectCircleStrokeColor: "#ff198CFE"),
                        );
                        print('打开媒体编辑: $res');
                        if (res.isNotEmpty) {
                          final f = res.first;
                          print(
                              'getChat first: ${f!.originalWidth} - ${f.originalHeight} - ${f.thumbWidth}');
                        }
                        setState(() {
                          mediaPickerString = "$res";
                        });
                      },
                      child: Text('选择图片--5张')),
                  ElevatedButton(
                      onPressed: () async {
                        final res = await MediaPicker.showMediaPicker(
                          maxImages: 6,
                          mediaSelectType: FBMediaSelectType.singleType,
                          selectedAssets: [],
                          doneButtonText: "下一步",
                          thumbType: FBMediaThumbType.origin,
                          cupertinoOptions: CupertinoOptions(
                            takePhotoIcon: "chat",
                            selectionStrokeColor: "#ff198CFE",
                            selectionFillColor: "#ff198CFE",
                            videoCanPickLimitSize: 100 * 1024 * 1024,
                            imageCanPickLimitSize: 100 * 1024 * 1024,
                            imageCanPickLimitPixel: 100000000,
                          ),
                          materialOptions: MaterialOptions(
                              allViewTitle: "All Photos",
                              selectCircleStrokeColor: "#ff198CFE",
                              videoCanPickLimitSize: 1 * 1024 * 1024,
                              imageCanPickLimitSize: 100 * 1024 * 1024,
                              imageCanPickLimitPixel: 10000 * 10000),
                        );
                        print('打开媒体编辑: $res');
                        if (res.isNotEmpty) {
                          final path = await MediaPicker.userDataCachePath();
                          print('getChat 草稿目录：$path');
                          res.forEach((e) {
                            print('getChat filePath：${e?.filePath}');
                            print(
                                'getChat 大小：${File(path! + e!.filePath!).lengthSync() / 1024 / 1024}');
                          });
                        }

                        setState(() {
                          mediaPickerString = "$res";
                        });
                      },
                      child: Text('单选视频或图片6张-限制')),
                  ElevatedButton(
                      onPressed: () async {
                        final res = await MediaPicker.showMediaPicker(
                          maxImages: 9,
                          mediaSelectType: FBMediaSelectType.all,
                          selectedAssets: [],
                          doneButtonText: "下一步",
                          thumbType: FBMediaThumbType.origin,
                          cupertinoOptions: CupertinoOptions(
                              takePhotoIcon: "chat",
                              selectionStrokeColor: "#ff198CFE",
                              selectionFillColor: "#ff198CFE"),
                          materialOptions: MaterialOptions(
                              allViewTitle: "All Photos",
                              selectCircleStrokeColor: "#ff198CFE"),
                        );
                        print('打开媒体编辑: $res');
                        if (res.isNotEmpty) {
                          final f = res.first;
                          print(
                              'getChat first -- ${f!.originalWidth} - ${f.originalHeight} - ${f.thumbWidth}');
                        }
                        final path = await MediaPicker.userDataCachePath();
                        if (res.first?.fileType?.contains("image") ?? false) {
                          imagePreviewPath = path! + res.first!.filePath!;
                          imagePreviewInfo =
                              "宽: ${res.first!.originalWidth} - 高： ${res.first?.originalHeight}";
                        }
                        //用户草稿恢复
                        requestIds.clear();
                        res.forEach((element) {
                          requestIds.add(element!.requestId!);
                        });
                        setState(() {
                          requestId = res.first!.requestId!;
                          mediaPickerString = "$res";
                        });
                      },
                      child: Text('选择视频和图片9')),
                  ElevatedButton(
                    onPressed: () async {
                      final res = await MediaPicker.userDataCachePath();
                      setState(() {
                        mediaPickerString = "$res";
                      });
                    },
                    child: Text("用户缓存路径"),
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        final res = await MediaPicker.pickVideoCover(
                            requestId: requestId);
                        setState(() {
                          mediaPickerString = "$res";
                        });
                      },
                      child: Text('选择视频封面')),
                  ElevatedButton(
                    onPressed: () async {
                      await MediaPicker.previewVideo(requestId: requestId);
                    },
                    child: Text("预览视频"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final res =
                          await MediaPicker.generateVideo(requestId: requestId);
                      setState(() {
                        mediaPickerString = "$res";
                      });
                    },
                    child: Text("生成视频"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final res = await MediaPicker.reEditorMedia(
                          requestIds: requestIds,
                          index: Random().nextInt(requestIds.length));
                      setState(() {
                        mediaPickerString =
                            "${res.map((e) => e?.toJsonMap()).toList()}";
                      });

                      final path = await MediaPicker.userDataCachePath();
                      if (res.first?.fileType?.contains("image") ?? false) {
                        imagePreviewPath = path! + res.first!.filePath!;
                        setState(() {});
                      }
                    },
                    child: Text("从草稿恢复"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      requestIds.forEach((element) {
                        MediaPicker.deleteDraft(requestId: element);
                      });
                      await MediaPicker.deleteDraft(requestId: requestId);
                    },
                    child: Text("删除草稿"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final rep =
                          await MediaPicker.isDraftExist(requestId: requestId);
                      setState(() {
                        mediaPickerString = "isDraftExist： $rep";
                      });
                    },
                    child: Text("草稿是否存在"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final res = await MultiImagePicker.fetchMediaInfo(0, 10,
                          showType: FBMediaShowType.video);
                      setState(() {
                        mediaPickerString =
                            "${res.map((e) => e.toJsonMap()).toList()}";
                      });
                    },
                    child: Text("获取图片信息"),
                  ),
                  // ElevatedButton(
                  //   onPressed: () async {
                  //     final res = await MediaPicker.sandboxMediaEdit(
                  //         filePathList: [""],
                  //         mediaShowType: FBMediaShowType.image);
                  //     res.forEach((r) => print("媒体编辑完成：${r.requestId}"));
                  //     setState(() {
                  //       requestId = res.first.requestId;
                  //       mediaPickerString = "$res";
                  //     });
                  //   },
                  //   child: Text("沙盒资源编辑"),
                  // ),
                  ElevatedButton(
                    onPressed: () async {
                      final res =
                          await MediaPicker.makerRequestIdFromSandboxFile(
                              filePathList: [""],
                              mediaShowType: FBMediaShowType.image);
                      res.forEach((r) => print("媒体编辑完成：${r?.requestId}"));
                      setState(() {
                        requestId = res.first!.requestId!;
                        mediaPickerString = "$res";
                      });
                    },
                    child: Text("沙盒资源生成草稿"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final result = await MultiImagePicker.pickImages(
                        maxImages: 2,
                        defaultAsset: "",
                        selectedAssets: [],
                        doneButtonText: "发送",
                        thumbType: FBMediaThumbType.thumb,
                        mediaShowType: FBMediaShowType.all,
                        cupertinoOptions: CupertinoOptions(
                            takePhotoIcon: "chat",
                            selectionStrokeColor: "#ff198CFE",
                            selectionFillColor: "#ff198CFE"),
                        materialOptions: MaterialOptions(
                            allViewTitle: "All Photos",
                            selectCircleStrokeColor: "#ff198CFE",
                            videoCanPickLimitSize: 5 * 1024 * 1024),
                      );
                      print(result);
                    },
                    child: Text("老版本-pickImages"),
                  ),
                ],
              ),
              // buildGridView(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildGridView() {
    return GridView.count(
      crossAxisCount: 3,
      children: List.generate(images.length, (index) {
        Asset asset = images[index];
        // return Image.network('https://upfile.asqql.com/2009pasdfasdfic2009s305985-ts/2020-6/2020679131113978.gif');
        return Image.file(File(asset.filePath!));
      }),
    );
  }

  Future<void> obtianVideoCover() async {
    final result = await MultiImagePicker.pickImages(
      maxImages: 9,
      defaultAsset: "",
      selectedAssets: [],
      doneButtonText: "发送",
      thumbType: FBMediaThumbType.thumb,
      mediaShowType: FBMediaShowType.all,
    );
    print(result);
    if (result?.isEmpty ?? true) return;
    final ids = (result?['identifiers'] as List).cast<String>();
    bool thumb = result!['thumb'] as bool? ?? true;
    debugPrint("$thumb");
    setState(() {
      mediaPickerString = "正在获取媒体缩略图";
    });
    try {
      final path = await MultiImagePicker.obtainVideoCover(ids.first);
      setState(() {
        mediaPickerString = "获取视频封面$path";
        imagePreviewData = null;
        imagePreviewPath = path;
      });
    } catch (e) {
      setState(() {
        mediaPickerString = "获取媒体缩略图错误 ${e.toString()}";
      });
    }
  }

  Future<void> loadHarmonyAssets() async {
    final result = await MultiImagePicker.pickImages(
      maxImages: 9,
      defaultAsset: "",
      selectedAssets: [],
      doneButtonText: "发送",
      thumbType: FBMediaThumbType.thumb,
      mediaShowType: FBMediaShowType.all,
    );
    print(result);
    if (result?.isEmpty ?? true) return;
    final ids = (result?['identifiers'] as List).cast<String>();
    bool thumb = result!['thumb'] as bool? ?? true;
    setState(() {
      mediaPickerString = "正在获取媒体缩略图";
    });
    try {
      final data = await MultiImagePicker.fetchMediaThumbData(ids.first);
      setState(() {
        mediaPickerString = "获取到媒体缩略图长度 ${data.length}";
        imagePreviewData = data;
        imagePreviewPath = null;
      });
    } catch (e) {
      setState(() {
        mediaPickerString = "获取媒体缩略图错误 ${e.toString()}";
      });
    }

    setState(() {
      mediaPickerString = "正在资源基本信息";
    });
    final xx = await MultiImagePicker.fetchMediaInfo(0, ids.length,
        selectedAssets: ids);
    setState(() {
      mediaPickerString = "${xx.first.toJsonMap()}";
    });

    setState(() {
      mediaPickerString = "正在压缩图";
    });
    try {
      final rep1 = await MultiImagePicker.requestMediaData(
        thumb: thumb,
        selectedAssets: ids,
      );
      if (rep1.isEmpty) return;
      setState(() {
        mediaPickerString = jsonEncode(rep1.first!.toJsonMap());
      });
      final path = rep1.first!.filePath!;
      if (rep1.first!.duration != 0 && rep1.first!.duration != null) {
        imagePreviewPath = rep1.first!.thumbFilePath!;
      } else {
        imagePreviewPath = path;
      }
      imagePreviewData = null;
      setState(() {});
    } catch (e, t) {
      setState(() {
        mediaPickerString = "正在压缩图 ${e.toString()},$t";
      });
    }
  }

  Future<void> loadAssets() async {
    await Permission.photos.request();
    await Permission.storage.request();
    List<Asset> resultList = [];
    String error = 'No Error Dectected';
    try {
      // "29B30966-7BC9-481C-9AA4-BE0A675112D3/L0/001"
      // "A4FE7B79-7CF7-4E22-B55E-936A22CE22F7/L0/001"
      // "573E487B-9ABA-4BE0-B219-C2FF8C1B1B9E/L0/001"
      // "EC0BC104-AD12-46EB-B84A-3DA224099BBE/L0/001"
      // "7630B37C-CEBA-485A-8347-17B517AEA999/L0/001"
      // "4FC8A835-B8DD-4648-9E90-5C7F894DE9A1/L0/001"

      // final preSelectMedias = [
      //   '4D1A6122-2B8D-4B19-807E-9FDDB28748C2/L0/001',
      //   '9EF3E2D4-398D-4EAA-B1AB-404C278A8AC7/L0/001',
      //   'B983761E-101D-4CA6-AEE6-ED7149664B06/L0/001',
      //   '20E2BC98-4677-4D80-A699-0F34AFF5D134/L0/001'
      // ];
      // final preSelectMedia = 'B983761E-101D-4CA6-AEE6-ED7149664B06/L0/001';
      // final preSelectMedias = ["120818", "120817", "120816"];
      // final preSelectMedia = '1960634';

// '24E7EFE4-2D3A-4C27-A96C-0F1AC085AAB9/L0/001'
      final result = await MultiImagePicker.pickImages(
        maxImages: 9,
        defaultAsset: "",
        selectedAssets: [],
        doneButtonText: "发送",
        thumbType: FBMediaThumbType.thumb,
        mediaShowType: FBMediaShowType.all,
        cupertinoOptions: CupertinoOptions(
          takePhotoIcon: "chat",
          selectionStrokeColor: "#ff198CFE",
          selectionFillColor: "#ff198CFE",
          videoCanPickLimitSize: 500 << 20,
          mediaCanDownloadFromiCloud: 1,
        ),
        materialOptions: MaterialOptions(
          allViewTitle: "All Photos",
          selectCircleStrokeColor: "#ff198CFE",
          videoCanPickLimitSize: 500 << 20,
        ),
      );
      print(result);

      // final list = [
      //   "29B30966-7BC9-481C-9AA4-BE0A675112D3/L0/001",
      //   "A4FE7B79-7CF7-4E22-B55E-936A22CE22F7/L0/001",
      //   "573E487B-9ABA-4BE0-B219-C2FF8C1B1B9E/L0/001",
      //   "EC0BC104-AD12-46EB-B84A-3DA224099BBE/L0/001",
      //   "7630B37C-CEBA-485A-8347-17B517AEA999/L0/001",
      //   "4FC8A835-B8DD-4648-9E90-5C7F894DE9A1/L0/001"
      // ];

      // final preSelectMedias = [
      //   '2B9C5D27-2767-45FE-9C51-EE598DFA2730/L0/001',
      //   '270DD1E8-8DE5-4FEC-A3DA-E8B569D2FA8D/L0/001',
      //   'CDFD2F31-3AAF-4A95-85D9-AD14F746AD46/L0/001',
      //   '4EEE33AB-2C0A-4639-844A-C76FEE518D1A/L0/001',
      //   'BC0FC2EA-73B9-4800-A271-77A111DEC1EB/L0/001',
      //   '955B5A81-55F1-4F20-9A8F-DA4609727896/L0/001'
      // ];

      // print('123');

      // final fileSize = await MultiImagePicker.requestFileSize(
      //     'F9D725E8-BF01-4FF2-A61C-3EC033C181C1/L0/001');
      // if (double.parse(fileSize) > 1024 * 1024 * 8) {}
      // print(fileSize);
      // final List<String> identifers = [];
      // result['identifiers']
      //     .forEach((element) => identifers.add(element.toString()));
      // final result1 =
      //     await MultiImagePicker.requestFilePath(identifers[0].toString());
      // print("result1: $result1");

      final ids = (result?['identifiers'] as List).cast<String>();
      // print('请求 requestAssetSize');
      // final fileSize = await MultiImagePicker.requestAssetSize(ids.first);
      // print('文件大小MB ------>>>>> $fileSize, ${fileSize / 1024 / 1024} MB');

      // MultiImagePicker.requestMediaData(
      //         thumb: true,
      //         selectedAssets: (result['identifiers'] as List).cast<String>())
      //     .then((xx) {
      //   xx.forEach((element) {
      //     print(
      //         '结果： ${element.name} ${element.thumbFilePath}, ${element.filePath}, ${element.checkPath}');
      //     print('大小1：${File(element.filePath).lengthSync() / 1024 / 1024}');
      //     print('大小2：${File(element.checkPath).lengthSync() / 1024 / 1024}');
      //   });
      // });

      // final result = await MultiImagePicker.
      // for (var item in assets) {
      //   print(item.filePath);
      //   print(item.checkPath);
      // }

      final dir = await MultiImagePicker.requestThumbDirectory();

      String path = "${dir}big_jpg.JPG";
      // final t1 = await MultiImagePicker.requestCompressMedia(true,
      //     fileType: "image", fileList: [path]);
      // print(t1[0].toJsonMap());
      path =  "${dir}gif.GIF";
      final t2 = await MultiImagePicker.requestCompressMedia(true,
          fileType: "image", fileList: [path]);

      print(t2[0]?.toJsonMap());
      // path = dir + "heic.HEIC";
      // final t3 = await MultiImagePicker.requestCompressMedia(true,
      //     fileType: "image", fileList: [path]);
      // print(t3[0].toJsonMap());
      // path = dir + "IMG_1582.GIF";
      // final t4 = await MultiImagePicker.requestCompressMedia(true,
      //     fileType: "image", fileList: [path]);
      // print(t4[0].toJsonMap());
      // path = dir + "jpg.JPG";
      // final t5 = await MultiImagePicker.requestCompressMedia(true,
      //     fileType: "image", fileList: [path]);
      // print(t5[0].toJsonMap());
      // path = dir + "mp4.mp4";
      // final t6 = await MultiImagePicker.requestCompressMedia(true,
      //     fileType: "video", fileList: [path]);
      // print(t6[0].toJsonMap());
      // path = dir + "png.PNG";
      // final t7 = await MultiImagePicker.requestCompressMedia(true,
      //     fileType: "image", fileList: [path]);
      // print(t7[0].toJsonMap());

      // print(resultList);
      // print(resultList[0].toJsonMap());
      // print(resultList[1].toJsonMap());
      // print(resultList[2].toJsonMap());
      // print(resultList[3].toJsonMap());
      // print(resultList[4].toJsonMap());

      // await MultiImagePicker.fetchMediaInfo(50, 31);
      // MultiImagePicker.fetchMediaInfo(0, 10, selectedAssets: list)
      //     .then((value) {
      //   print(value);
      //   print('123');
      // });

      // for (var item in list) {
      //   print(await MultiImagePicker.requestFileDimen(item));
      // }

      // final result = await MultiImagePicker.requestFileDimen('2004950');
      // print(result);

      // Asset asset =
      //     await MultiImagePicker.requestTakePicture(themeColor: "#ff198CFE");
      // resultList.add(asset);
      // print(asset);

      // print(await MultiImagePicker.requestThumbDirectory());
      // for (var asset in assets) {
      //   print(asset.identifier);
      // }
      // print(assets);

      // final fileSize = await MultiImagePicker.requestFileSize(
      //     "334D2E75-7DFD-4D76-B8E3-BB2B5A84B533/L0/001");
      // if (double.parse(fileSize) > 1024 * 1024 * 8) {}
      // print(fileSize);

      setState(() {
        mediaPickerString = "正在获取媒体缩略图";
      });
      try {
        final data = await MultiImagePicker.fetchMediaThumbData(ids.first);

        setState(() {
          imagePreviewData = data;
          imagePreviewPath = null;
          mediaPickerString = "获取到媒体缩略图长度 ${data.length}";
        });
      } catch (e) {
        setState(() {
          mediaPickerString = "获取媒体缩略图错误 ${e.toString()}";
        });
      }

      final assets = await MultiImagePicker.requestMediaData(
          thumb: false, selectedAssets: ids);
      debugPrint("$assets");
      // Uint8List data1 = await MultiImagePicker.fetchMediaThumbData("53F55494-C4C0-4FB7-8365-8326BBC0693D/L0/001");
      // print(data);
    } on Exception catch (e) {
      print(e);
      error = e.toString();
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      images = resultList;
      _error = error;
    });
  }

  Future<void> loadAlbums() async {
    final result = await MultiImagePicker.loadAlbums();
    result.forEach((element) {
      print(
          "${element.albumId} ${element.albumName} ${element.count} ${element.thumbIdentifier}");
    });
    print("获取专辑下面的第一个资源");
    final selectedAssets = result
        .map((album) => album.thumbIdentifier)
        .where((identifier) => identifier.isNotEmpty)
        .toList();
    final assets = await MultiImagePicker.fetchMediaInfo(
      0,
      result.length,
      selectedAssets: selectedAssets,
    );

    assets.forEach((element) {
      print("${element.identifier} ${element.name} ${element.fileType}");
    });
  }

  Future<void> fetchPhotoInAlbums() async {
    var result = await MultiImagePicker.fetchMediaInfo(0, 5, albumId: 0);
    result.forEach((element) {
      print(element.toJsonMap());
    });
    print("------------------------------------");

    result = await MultiImagePicker.fetchMediaInfo(0, 5, albumId: 1);
    result.forEach((element) {
      print(element.toJsonMap());
    });
    print("------------------------------------");

    result = await MultiImagePicker.fetchMediaInfo(0, 5, albumId: 2);
    result.forEach((element) {
      print(element.toJsonMap());
    });
    print("------------------------------------");

    result = await MultiImagePicker.fetchMediaInfo(0, 5, albumId: 3);
    result.forEach((element) {
      print(element.toJsonMap());
    });
    print("------------------------------------");
  }
}
