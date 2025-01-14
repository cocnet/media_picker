import ArrayList from '@ohos.util.ArrayList';
import Want from '@ohos.app.ability.Want';
import Log from '@ohos/flutter_ohos/src/main/ets/util/Log';
import fs from '@ohos.file.fs'
import common from '@ohos.app.ability.common';
import wantConstant from '@ohos.ability.wantConstant';
import bundleManager from '@ohos.bundle.bundleManager';
import ImagePickerCache, { CacheType } from './ImagePickerCache'
import FileUtils from './FileUtils'
import StartOptions from '@ohos.app.ability.StartOptions';
import {
  ImageSelectionOptions,
  VideoSelectionOptions,
  CacheRetrievalResult,
  CacheRetrievalResultBuilder,
  MediaSelectionOptions,
  GeneralOptions,
  AssetInfo,
} from './Messages'
import ImageResizer from './ImageResizer';
import HashMap from '@ohos.util.HashMap';
import UIAbility from '@ohos.app.ability.UIAbility';
import abilityAccessCtrl from '@ohos.abilityAccessCtrl';
import { BusinessError } from '@ohos.base';
import { dataSharePredicates } from '@kit.ArkData';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import ImagePickerUtils from './ImagePickerUtils';
import { media } from '@kit.MediaKit';
import {MethodResult} from '@ohos/flutter_ohos';
import util from '@ohos.util'
import { image } from '@kit.ImageKit';
// import { VideoCompress,VideoQuality } from './video/VideoCompress';

export default class ImagePickerDelegate implements photoAccessHelper.MediaAssetDataHandler<ArrayBuffer>{
  readonly REQUEST_CODE_CHOOSE_IMAGE_FROM_GALLERY = 2342;
  readonly REQUEST_CODE_TAKE_IMAGE_WITH_CAMERA = 2343;
  readonly REQUEST_CAMERA_IMAGE_PERMISSION = 2345;
  readonly REQUEST_CODE_CHOOSE_MULTI_IMAGE_FROM_GALLERY = 2346;
  readonly REQUEST_CODE_CHOOSE_MEDIA_FROM_GALLERY = 2347;
  readonly REQUEST_CODE_CHOOSE_VIDEO_FROM_GALLERY = 2352;
  readonly REQUEST_CODE_TAKE_VIDEO_WITH_CAMERA = 2353;
  readonly REQUEST_CAMERA_VIDEO_PERMISSION = 2355;
  private static TAG = "ImagePickerDelegate";
  public  imageResizer: ImageResizer;
  private cache: ImagePickerCache;
  private pendingCameraMediaUri: string | null = null;
  private pendingCallState: PendingCallState | null = null;
  private context: common.UIAbilityContext | null = null;
  private phAccessHelper: photoAccessHelper.PhotoAccessHelper | null = null;

  // private videoCompress: VideoCompress | null = null;

  constructor(ability: UIAbility, imageResizer: ImageResizer, cache: ImagePickerCache, context?: common.UIAbilityContext,
    pendingImageOptions?: ImageSelectionOptions, pendingVideoOptions?: VideoSelectionOptions,
    result?:MethodResult) {
    this.imageResizer = imageResizer;
    if (result != null) {
      this.pendingCallState = new PendingCallState(pendingImageOptions ?? null, pendingVideoOptions ?? null, result);
    }
    this.cache = cache;
    this.context = ability.context;

    this.phAccessHelper = photoAccessHelper.getPhotoAccessHelper(this.context);
    // this.videoCompress = new VideoCompress(this.context);
  }

  onDataPrepared(data: ArrayBuffer, map?: Map<string, string> | undefined): void {
    this.pendingCallState?.result.success(data);
  }

  async pickImages(maxImages: number, showType: string, result: MethodResult): Promise<void> {
    const photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
    photoSelectOptions.isOriginalSupported = true;
    photoSelectOptions.maxSelectNumber = maxImages; // 选择媒体文件的最大数目
    if(showType == "image"){
      photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE; // 过滤选择媒体文件类型为IMAGE
    }else if(showType == 'video'){
      photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.VIDEO_TYPE;
    }else{
      photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_VIDEO_TYPE;
    }
    let uris: Array<string> = [];
    const photoViewPicker = new photoAccessHelper.PhotoViewPicker();
    photoViewPicker.select(photoSelectOptions).then((photoSelectResult: photoAccessHelper.PhotoSelectResult) => {
      uris = photoSelectResult.photoUris;
      let isOriginal = photoSelectResult.isOriginalPhoto;
      let ids: Array<string> = new Array();
      for (let path of uris) {
        ids.push(path);
      }
      result.success({
        "identifiers": ids,
        "thumb": !isOriginal,
      });

      console.info('photoViewPicker.select to file succeed and uris are:' + uris);
    }).catch((err: BusinessError) => {
      console.error(`Invoke photoViewPicker.select failed, code is ${err.code}, message is ${err.message}`);
    })
  }

  /*
  发送资源最终信息，压缩图片、视频、送审图的路径
  *thumb = false 相册选中了原图
   */
  async requestMediaData(identifiers: Array<string>, thumb:boolean = true, result: MethodResult): Promise<void> {
    //压缩图片+视频
    let retList: Array<Map<string, Object>> = new Array();
    for (let uri of identifiers) {
      let isImage = ImagePickerUtils.isImageUri(uri);
      if (isImage) {
        // 缩略图
        let  p: Map<string, Object> = new Map();
        p.set("identifier", uri);
        let localPath = FileUtils.getPathFromUri(this.context, uri);
        if (localPath == null) continue;
        // 送审图
        let thumbInfo = await this.imageResizer.resizeImageIfNeeded(uri, 300,300,100,'check_');
        // 发送图
        let fileNamePrefix = 'origin_' + (thumb? "1_": "0_");
        let assetInfo = await this.imageResizer.resizeImageIfNeeded(uri, 4000, 4000, thumb ? 70 : 90, fileNamePrefix);
        let imageFile: fs.File = fs.openSync(assetInfo.filePath);
        let imageSource: image.ImageSource = image.createImageSource(imageFile.fd);
        let imageInfo: image.ImageInfo = await imageSource.getImageInfo();

        let path = assetInfo.filePath ?? localPath;
        p.set("filePath",path);
        p.set("width", imageInfo.size.width);
        p.set("height", imageInfo.size.height);
        p.set("size", fs.statSync(assetInfo.filePath ?? localPath).size);
        p.set("name",this._relativeName(path));
        p.set("checkPath", thumbInfo.filePath ?? '');
        p.set("fileType", "image/jpeg");
        retList.push(p);
      }else{
        //视频
        let localPath = FileUtils.getPathFromUri(this.context, uri);
        if (localPath == null) continue;
        //压缩视频
        // let name = uri.substring(uri.lastIndexOf("/") + 1);
        // let compressVideoPath = FileUtils.assetBasePath(uri, this.context!) + "video" + name;
        // let compressResultPath = await this.videoCompress?.compress(localPath, VideoQuality.MediumQuality, compressVideoPath);
        let compressResultPath = localPath; // 压缩速度太慢，暂时不压缩视频
        let videoFile: fs.File = fs.openSync(compressResultPath);
        let s = fs.statSync(compressResultPath);
        let size = s.size;
        // 获取视频元数据
        let avMetadataExtractor: media.AVMetadataExtractor = await media.createAVMetadataExtractor()
        avMetadataExtractor.fdSrc = videoFile;
        let data = await avMetadataExtractor.fetchMetadata();
        let videoHeight = data.videoHeight;
        let videoWidth = data.videoWidth;
        let duration = data.duration;
        await avMetadataExtractor.release();
        let p: Map<string, Object> = new Map();
        p.set("identifier", uri);
        p.set("filePath", compressResultPath!);
        p.set("width", Number(videoWidth ?? 0));
        p.set("height", Number(videoHeight ?? 0));
        p.set("name", this._relativeName(compressResultPath));
        p.set("duration",Number(duration ?? 0) / 1000);
        p.set("fileType", "video");
        p.set("size", size);
        let avImageGenerator: media.AVImageGenerator = await media.createAVImageGenerator()
        avImageGenerator.fdSrc = videoFile
        // 初始化入参
        let timeUs = 0
        let queryOption = media.AVImageQueryOptions.AV_IMAGE_QUERY_NEXT_SYNC
        let param: media.PixelMapParams = {
          width : Number(videoWidth ?? 0),
          height : Number(videoHeight ?? 0)
        }

        // 获取视频封面图
        let pixelMap = await avImageGenerator.fetchFrameByTime(timeUs, queryOption, param);
        let imagePath = await this.imageResizer.createImageOnExternalDirectory(pixelMap, FileUtils.videoCoverImageName(uri), 90.0)
        // 释放资源（promise模式）
        avImageGenerator.release()
        //封面图信息
        p.set("thumbPath", imagePath);
        p.set("thumbName", this._relativeName(imagePath));
        p.set("thumbHeight", videoHeight ?? 0);
        p.set("thumbWidth", videoWidth ?? 0);
        retList.push(p);
      }
    }
    result.success(retList);
  }

  _relativeName(path: string): string{
    return path.substring(path.lastIndexOf("/")+1);
  }

  /*
  资源基本信息，宽高，大小
   */
  async fetchMediaInfoV2(
    context: common.UIAbilityContext ,result: MethodResult,
    selectedAssets: Array<string> = [],
  ): Promise<void> {
    if(selectedAssets.length <= 0) {
      return result.success(null);
    }
    let photoList: Array<Map<string, Object>> = [];
    for(let uri of selectedAssets) {
      // 判断是图片还是视频
      let isImage = ImagePickerUtils.isImageUri(uri);
      if (isImage) {
        let localPath = FileUtils.getPathFromUri(context, uri);
        if (localPath == null) continue;
        let imageFile: fs.File = fs.openSync(localPath);
        let imageSource: image.ImageSource = image.createImageSource(imageFile.fd);
        let imageInfo: image.ImageInfo = await imageSource.getImageInfo();

        let p: Map<string, Object> = new Map();
        p.set("identifier", uri);
        p.set("filePath", localPath!);
        p.set("width", imageInfo.size.width);
        p.set("height", imageInfo.size.height);
        p.set("fileType", "image/jpeg");
        p.set("name", this._relativeName(localPath));
        p.set("duration",0);
        p.set("size", fs.statSync(localPath).size);
        photoList.push(p);
      } else {
        let localPath = FileUtils.getPathFromUri(context, uri);
        if (localPath == null) continue;
        let videoFile: fs.File = fs.openSync(localPath);
        let s = fs.statSync(localPath);
        let size = s.size;
        let avMetadataExtractor: media.AVMetadataExtractor = await media.createAVMetadataExtractor()
        avMetadataExtractor.fdSrc = videoFile;
        // 获取元数据
        let data = await avMetadataExtractor.fetchMetadata();
        let videoHeight = data.videoHeight;
        let videoWidth = data.videoWidth;
        let duration = data.duration;
        await avMetadataExtractor.release();
        let p: Map<string, Object> = new Map();
        p.set("identifier", uri);
        p.set("filePath", localPath!);
        p.set("width", Number(videoWidth ?? 0));
        p.set("height", Number(videoHeight ?? 0));
        p.set("fileType", "video");
        p.set("name",  this._relativeName(localPath));
        p.set("duration",Number(duration ?? 0) / 1000);
        p.set("size", size);
        photoList.push(p);
      }
    }
    result.success(photoList);
  }

  async fetchMediaThumbDataV2(identifier: string, _thumb:boolean = false, result: MethodResult): Promise<void> {
    try {
      let isImage = ImagePickerUtils.isImageUri(identifier);
      if (isImage) {
        let assetInfo = await this.imageResizer.resizeImageIfNeeded(identifier, 2000, 2000, 70, 'preview_');
        result.success(assetInfo.filePath);
        // let imageFile = fs.openSync(assetInfo.filePath);
        // let imageSource = image.createImageSource(imageFile.fd);
        // let imagePixelMap = await imageSource.createPixelMap({
        //   desiredSize: {
        //     width:assetInfo.originalWidth,
        //     height:assetInfo.originalHeight
        //   }
        // });
        // const imagePackerApi = image.createImagePacker();
        // const packOptions: image.PackingOption = {
        //   format: 'image/jpeg',
        //   quality: 100,
        // }
        // let uint8Array: Uint8Array = new Uint8Array(await imagePackerApi.packing(imagePixelMap, packOptions));
        // imagePixelMap.release();
        // result.success(uint8Array);
      } else {
        //视频
        let localPath = FileUtils.getPathFromUri(this.context, identifier);
        let videoFile: fs.File = fs.openSync(localPath);
        // 获取元数据
        let avMetadataExtractor: media.AVMetadataExtractor = await media.createAVMetadataExtractor()
        avMetadataExtractor.fdSrc = videoFile;
        let data = await avMetadataExtractor.fetchMetadata();
        let videoHeight = data.videoHeight;
        let videoWidth = data.videoWidth;
        await avMetadataExtractor.release();
        let avImageGenerator: media.AVImageGenerator = await media.createAVImageGenerator()
        avImageGenerator.fdSrc = videoFile

        // 初始化入参
        let timeUs = 0
        let queryOption = media.AVImageQueryOptions.AV_IMAGE_QUERY_NEXT_SYNC
        let param: media.PixelMapParams = {
          width : Number(videoWidth ?? -1),
          height : Number(videoHeight ?? -1)
        }
        // 获取缩略图
        let pixelMap = await avImageGenerator.fetchFrameByTime(timeUs, queryOption, param)
        let image = await this.imageResizer.createImageOnExternalDirectory(pixelMap,FileUtils.videoCoverImageName(identifier),90.0)
        let assetInfo = await this.imageResizer.resizeImageIfNeeded(image, 2000, 2000, 80, 'preview_');
        result.success(assetInfo.filePath);
      }
    }catch (e){

    }
  }

  async obtainVideoCover(identifier: string, _thumb:boolean = false, result: MethodResult): Promise<void> {
    try {
      let isImage = ImagePickerUtils.isImageUri(identifier);
      if (isImage) {
        let assetInfo = await this.imageResizer.resizeImageIfNeeded(identifier, 2000, 2000, 80, 'preview_');
        result.success(assetInfo.filePath);
      } else {
        //视频
        let localPath = FileUtils.getPathFromUri(this.context, identifier);
        let videoFile: fs.File = fs.openSync(localPath);
        // 获取视频封面
        let avImageGenerator: media.AVImageGenerator = await media.createAVImageGenerator()
        avImageGenerator.fdSrc = videoFile
        let timeUs = 0
        let queryOption = media.AVImageQueryOptions.AV_IMAGE_QUERY_NEXT_SYNC
        let param: media.PixelMapParams = {
          width : -1,
          height : -1,
        }
        // 获取缩略图
        let pixelMap = await avImageGenerator.fetchFrameByTime(timeUs, queryOption, param)
        let image = await this.imageResizer.createImageOnExternalDirectory(pixelMap,FileUtils.videoCoverImageName(identifier),90.0)
        let assetInfo = await this.imageResizer.resizeImageIfNeeded(image, 2000, 2000, 80, 'preview_');
        result.success(assetInfo.filePath);
      }
    }catch (e){

    }
  }

  saveStateBeforeResult(): void {
    let localImageOptions: ImageSelectionOptions | null;

    if (this.pendingCallState == null) {
      return;
    }
    localImageOptions = this.pendingCallState.imageOptions;

    this.cache.saveType(localImageOptions != null ? CacheType.IMAGE : CacheType.VIDEO);
    if (localImageOptions != null) {
      this.cache.saveDimensionWithOutputOptions(localImageOptions);
    }

    let localPendingCameraMediaUri = this.pendingCameraMediaUri;
    if (localPendingCameraMediaUri != null) {
      this.cache.savePendingCameraMediaUriPath(localPendingCameraMediaUri);
    }
  }

  async retrieveLostImage(): Promise<CacheRetrievalResult | null> {
    let cacheMap: HashMap<string, ESObject | null> = await this.cache.getCacheMap()
    if (cacheMap.isEmpty()) {
      return null;
    }
    let result = new CacheRetrievalResultBuilder(null, null, null, null);
    let type: ESObject = cacheMap.get(ImagePickerCache.MAP_KEY_TYPE);
    if (type != null && result.setType) {
      result.setType(type);
    }
    if (result.setError) {
      result.setError(cacheMap.get(ImagePickerCache.MAP_KEY_ERROR));
    }

    let pathList: ArrayList<string> = cacheMap.get(ImagePickerCache.MAP_KEY_PATH_LIST) as ArrayList<string>;
    if (pathList != null) {
      let newPathList: ArrayList<string> = new ArrayList();
      for (let path of pathList) {
        let maxWidth: number = cacheMap.get(ImagePickerCache.MAP_KEY_MAX_WIDTH) as number;
        let maxHeight: number = cacheMap.get(ImagePickerCache.MAP_KEY_MAX_HEIGHT) as number;
        let boxedImageQuality: number = cacheMap.get(ImagePickerCache.MAP_KEY_IMAGE_QUALITY) as number;
        let imageQulity: number = boxedImageQuality == null ? 100 : boxedImageQuality;

        newPathList.add(await this.imageResizer.resizeImageIfNeeded(path, maxWidth, maxHeight, imageQulity)
          .then((fileName) => {
            return fileName.filePath;
          })
        );
      }
      if (result.setPaths) {
        result.setPaths(newPathList);
      }

    }
    this.cache.clear();
    return result.build ? result.build() : null;
  }

  chooseMediaFromGallery(options: MediaSelectionOptions, generalOptions: GeneralOptions,
    result: MethodResult): void {
    if (!this.setPendingOptionsAndResult(options.getImageSelectionOptions(), null, result)) {
      this.finishWithAlreadyActiveError(result);
      return;
    }
    this.launchPickMediaFromGalleryWant(generalOptions);
  }

  launchPickMediaFromGalleryWant(generalOptions: GeneralOptions): void {
    let config: Want = {
      action: 'ohos.want.action.photoPicker',
      type: generalOptions.getAllowMultiple() ? 'multipleselect' : 'singleselect',
      parameters: {
        uri: generalOptions.getAllowMultiple() ? 'multipleselect' : 'singleselect',
        maxSelectCount: generalOptions.getAllowMultiple() ? 9 : 1,
        filterMediaType: 'FILTER_MEDIA_TYPE_ALL'
      }
    };
    let options: StartOptions = {
      displayId: 0,
    };
    if (!this.context) {
      return
    }
    this.context.startAbilityForResult(config, options).then(result => {
      if (result && result.want && result.want.parameters) {
        let uris: Array<string> = result.want.parameters['select-item-list'] as Array<string>;
        let code = result["resultCode"] as number;
        Log.i(ImagePickerDelegate.TAG, "startAbilityForResult : " + JSON.stringify(result.want.parameters));
        this.handleChooseMediaResult(code, uris);
      }
    });
  }

  handleChooseMediaResult(code: number, uris: Array<string>, isOriginal: boolean=true): void {
    let localResult:MethodResult | null = null;
    if (this.pendingCallState != null) {
      localResult = this.pendingCallState.result;
    }
    if(localResult == null) return;

    if(code!=0){
      localResult.success(null);
      return;
    }
    let ids: Array<string> = new Array();
    for (let path of uris) {
      ids.push(path);
    }
    localResult.success({
      "identifiers": ids,
      "thumb": !isOriginal,
    });
  }

  async getAllImg(): Promise<photoAccessHelper.PhotoAsset[]> {
    let photoList: Array<photoAccessHelper.PhotoAsset> = [];
    if (this.phAccessHelper === null) {
      return photoList;
    }
    let predicates: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    let fetchOptions: photoAccessHelper.FetchOptions = {
      fetchColumns: [],
      predicates: predicates
    };

    try {
      let fetchResult: photoAccessHelper.FetchResult<photoAccessHelper.PhotoAsset> =
        await this.phAccessHelper.getAssets(fetchOptions);
      if (fetchResult != undefined) {
        let photoAsset: Array<photoAccessHelper.PhotoAsset> = await fetchResult.getAllObjects();
        if (photoAsset != undefined && photoAsset.length > 0) {
          for (let i = 0; i < photoAsset.length; i++) {
            if (photoAsset[i].photoType === 1) {
              photoList.push(photoAsset[i]);
            }
          }
        }
      }
    } catch (err) {
      console.error('getAssets failed, message = ', err);
    }
    console.error('photoList success');
    return photoList;
  }

  async fetchMediaInfo(
    context: common.UIAbilityContext ,result: MethodResult,
    limit: number = -1,
    offset: number = -1,
    mediaShowTypes:string = 'all',
    selectedAssets: Array<string> = [],
    albumId: string|null=null,
  ): Promise<void> {
    let photoList: Array<Map<string, Object>> = [];
    if (this.phAccessHelper === null) {
      return result.success(null);
    }
    if(selectedAssets.length > 0) {
      for(let s of selectedAssets){
        let predicates: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
        predicates.equalTo(photoAccessHelper.PhotoKeys.URI, s);
        let fetchOptions: photoAccessHelper.FetchOptions = {
          fetchColumns: ['uri', 'media_type', "display_name", "size", "duration", "width", "height", "title"],
          predicates: predicates
        };
        try {
          let fetchResult: photoAccessHelper.FetchResult<photoAccessHelper.PhotoAsset> =
            await this.phAccessHelper.getAssets(fetchOptions);
          if (fetchResult != undefined) {
            let a: photoAccessHelper.PhotoAsset = await fetchResult.getFirstObject();
            if (a != undefined) {
              let  p: Map<string, Object> = new Map();
              p.set("identifier", a.uri);
              p.set("filePath", "");
              p.set("width", (a.get('width') as number) * 1.0);
              p.set("height", (a.get('height') as number) * 1.0 );
              p.set("duration", (a.get('duration') as number ?? 0) * 1.0);
              p.set("size", (a.get('size') as number) / 1024);
              p.set("name", a.get("display_name"));
              if(a.photoType == photoAccessHelper.PhotoType.VIDEO){
                p.set("fileType", "video");
              }else{
                //TODO gif
                p.set("fileType", "image/jpeg");
              }
              photoList.push(p);
            }
            fetchResult.close();
          }
        } catch (err) {
          console.error('qqqgetAssethhs failed, message = ', err);
        }
      }
      result.success(photoList);
      return;
    }
    let predicates: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    if(albumId != null){
      predicates.equalTo("album_name", albumId);
    }
    if(mediaShowTypes == 'image'){
      predicates.equalTo(photoAccessHelper.PhotoKeys.PHOTO_TYPE, photoAccessHelper.PhotoType.IMAGE);
    }else if(mediaShowTypes = 'video'){
     predicates.equalTo(photoAccessHelper.PhotoKeys.PHOTO_TYPE, photoAccessHelper.PhotoType.VIDEO);
    }
    let fetchOptions: photoAccessHelper.FetchOptions = {
      fetchColumns: ['uri', 'media_type', "display_name", "size", "duration", "width", "height", "title"],
      predicates: predicates
    };

    try {
      let fetchResult: photoAccessHelper.FetchResult<photoAccessHelper.PhotoAsset> =
        await this.phAccessHelper.getAssets(fetchOptions);
      if (fetchResult != undefined) {
        let photoAsset: Array<photoAccessHelper.PhotoAsset> = await fetchResult.getAllObjects();
        if (photoAsset != undefined && photoAsset.length > 0) {
          let resultCount =  photoAsset.length;
          if(limit == -1 && offset == -1){
            offset = 0;
            limit = resultCount;
          }else{
            if(offset > resultCount) offset = resultCount;
            if(limit > resultCount) limit = resultCount;
          }

          for (let i = offset; i < limit; i++) {
            if (photoAsset[i].photoType === 1) {
              let  a = photoAsset[i];
              let  p: Map<string, Object> = new Map();
              p.set("identifier", a.uri);
              p.set("filePath", "");
              p.set("width", (a.get('width') as number) * 1.0);
              p.set("height", (a.get('height') as number) * 1.0 );
              p.set("duration", (a.get('duration') as number ?? 0) * 1.0);
              p.set("size", (a.get('size') as number) / 1024);
              p.set("name", a.get("display_name"));
              if(a.photoType == photoAccessHelper.PhotoType.VIDEO){
                p.set("fileType", "video");
              }else{
                //TODO gif
                p.set("fileType", "image/jpeg");
              }
              photoList.push(p);
            }
          }
        }
        fetchResult.close();
      }
    } catch (err) {
      console.error('qqqgetAssethhs failed, message = ', err);
      result.error("-1","getAssethhs failed", err);
    }
    console.error('photoList success');
    result.success(photoList);
  }

  async fetchAllAlbums(context: common.UIAbilityContext ,result: MethodResult): Promise<void> {
    try {
      let albumList: Array<Map<string, Object>> = new Array();
      //1. 系统相册
      let frSys = await this.phAccessHelper!.getAlbums(photoAccessHelper.AlbumType.SYSTEM, photoAccessHelper.AlbumSubtype.ANY);
      let predicates: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
      let fetchOption: photoAccessHelper.FetchOptions = {
        fetchColumns: [],
        predicates: predicates
      };
      if(frSys != undefined){
        let al = await frSys.getAllObjects();
        for (let album of al) {
          let  p: Map<string, Object> = new Map();
          p.set("albumId", album.albumUri);
          p.set("albumName", album.albumName);
          p.set("count", album.count);
          p.set("thumbPath",album.coverUri);
          p.set("thumbIdentifier", "");

          let albumFetchResult =  await album.getAssets(fetchOption);
          if(albumFetchResult != undefined){
            console.info('album getAssets successfully, getCount: ' + albumFetchResult.getCount());
          }
          albumList.push(p);
        }
        frSys.close();
      }
      //1. 用户相册
      let frUser = await this.phAccessHelper!.getAlbums(photoAccessHelper.AlbumType.USER, photoAccessHelper.AlbumSubtype.ANY);
      if(frUser != undefined){
        let al = await frUser.getAllObjects();
        for (let album of al) {
          let  p: Map<string, Object> = new Map();
          p.set("albumId", album.albumUri);
          p.set("albumName", album.albumName);
          p.set("count", album.count);
          p.set("thumbPath",album.coverUri);
          p.set("thumbIdentifier", "");
          albumList.push(p);
        }
        frUser.close();
      }
      result.success(albumList);
    } catch (err) {
      result.success(null);
      console.error(`getAlbumDemo failed with error: ${err.code}, ${err.message}`);
    }
  }

  async fetchMediaThumbData(identifier: string, result: MethodResult): Promise<void> {
    try{
      let predicates: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
      predicates.equalTo("uri", identifier);
      let fetchOption: photoAccessHelper.FetchOptions = {
        fetchColumns: ['uri', 'media_type', "display_name", "size", "duration", "width", "height", "title"],
        predicates: predicates
      };
      let fetchResult: photoAccessHelper.FetchResult<photoAccessHelper.PhotoAsset> = await this.phAccessHelper!.getAssets(fetchOption);
      let asset: photoAccessHelper.PhotoAsset = await fetchResult.getFirstObject();
      console.info('asset displayName = ', asset.displayName);
      let w = asset.get('width') as number;
      let h = asset.get('height') as number;
      let size: image.Size = { width: 720, height: 720 };
      let pixelMap = await asset.getThumbnail(size);
      if(pixelMap == undefined) result.error("-1", "错误", "");

      let pixelBytesNumber: number = pixelMap.getPixelBytesNumber();
      //let pixelBytesNumber2 = w * h * 4;
      const readBuffer: ArrayBuffer = new ArrayBuffer(pixelBytesNumber);
      pixelMap.readPixelsToBufferSync(readBuffer);

      // let x = new Uint8Array(readBuffer);
      //let base64 = new util.Base64Helper;
      //let arrayStr = base64.encodeToStringSync(new Uint8Array(readBuffer))
      // result.success(arrayStr);

      const uuid = util.generateRandomUUID();
      let p = await this.imageResizer.createImageOnExternalDirectory(pixelMap,"thumb_" + uuid + '.jpg',1.0);
      fetchResult.close();
      result.success(p);

      // let info = pixelMap.getImageInfoSync();
      // pixelMap.writeBufferToPixelsSync(readBuffer);
      // let xxx = readBuffer.byteLength;

      // resolve(`data:${format};base64,${arrayStr}`)

      // let x = new Uint8Array(readBuffer);
      // let base64 = new util.Base64Helper
      // let arrayStr = base64.encodeToStringSync(x)
      // result.success(arrayStr);
      // result.success(new Uint8Array(readBuffer));
    } catch (err) {
      result.error("-1", "错误",err);
      console.error(`getThumbnail fail with error: ${err.code}, ${err.message}`);
    }
  }

  async handleMediaResultTwo(uris: Array<string>): Promise<void> {
    let localImageOptions: ImageSelectionOptions | null = null;
    if (this.pendingCallState != null) {
      localImageOptions = this.pendingCallState.imageOptions;
    }
    let pathList: ArrayList<string> = new ArrayList();
    if (localImageOptions != null && localImageOptions != undefined) {
      for (let path of uris) {
        if (path.search("video") < 0 && this.pendingCallState) {
          let assetInfo = await this.getResizedImagePath(path, this.pendingCallState.imageOptions!);
          // path = assetInfo.filePath;
        }
        let realPath = FileUtils.getPathFromUri(this.context, path);
        Log.i(ImagePickerDelegate.TAG, "getPathFromUri : " + realPath);
        pathList.add(realPath);
      }
    } else {
      for (let path of uris) {
        let realPath = FileUtils.getPathFromUri(this.context, path);
        pathList.add(realPath);
      }
    }
    this.finishWithListSuccess(pathList);
  }

  chooseVideoFromGallery(options: VideoSelectionOptions, usePhotoPicker: boolean, result: MethodResult): void {
    if (!this.setPendingOptionsAndResult(null, options, result)) {
      this.finishWithAlreadyActiveError(result);
      return;
    }

    this.launchPickVideoFromGalleryWant(usePhotoPicker);
  }

  async launchPickVideoFromGalleryWant(usePhotoPicker: boolean): Promise<void> {
    Log.i(ImagePickerDelegate.TAG, "launchPickVideoFromGalleryWant enter");
    let config: Want = {
      action: 'ohos.want.action.photoPicker',
      type: 'singleselect',
      parameters: {
        uri: 'singleselect',
        maxSelectCount: 1,
        filterMediaType: 'FILTER_MEDIA_TYPE_VIDEO'
      }
    };

    let options: StartOptions = {
      displayId: 0,
    };
    let result: ESObject = null
    if (this.context) {
      result = await this.context.startAbilityForResult(config, options);
    }

    if (result && result.want && result.want.parameters) {
      let uris = result.want.parameters['select-item-list'] as Array<string>;
      let code = result.resultCode as number;
      this.handleChooseVideoResult(code, uris);
    }

  }

  handleChooseVideoResult(code: number, uris: Array<string>): void {
    if (code == 0) {
      let realPath = FileUtils.getPathFromUri(this.context, uris[0]);
      this.handleVideoResult(realPath as string, false);
    } else {
      this.finishWithSuccess(null);
    }
  }

  takeVideoWithCamera(options: VideoSelectionOptions, result: MethodResult): void {
    if (!this.setPendingOptionsAndResult(null, options, result)) {
      this.finishWithAlreadyActiveError(result);
      return;
    }

    Log.i(ImagePickerDelegate.TAG, "launchTakeVideoWithCameraWant duration: " + options.getMaxDurationSeconds());
    this.launchTakeVideoWithCameraWant(options.getMaxDurationSeconds());
  }

  async launchTakeVideoWithCameraWant(duration: number): Promise<void> {
    let want: Want = {
      "action": wantConstant.Action.ACTION_VIDEO_CAPTURE,
      parameters: {
        callBundleName: "flutter_embedding",
        "supportMultiMode": false,
        durationLimit: duration
      }
    }
    abilityAccessCtrl.createAtManager()
      .requestPermissionsFromUser(this.context, ['ohos.permission.READ_MEDIA'])
      .then(async (permission) => {
        if(permission.authResults[0] !== 0){
          return
        }
        let result: ESObject = null;
        if (this.context) {
          result = await this.context.startAbilityForResult(want);
        }
        if (result && result.want && result.want.parameters) {
          let uri = result["want"]["parameters"].resourceUri as string;
          let code = result["resultCode"] as number;
          this.handlerCaptureImageResult(code, uri);
        }

      });
  }

  async chooseImageFromGallery(options: ImageSelectionOptions, usePhotoPicker: boolean, result: MethodResult): Promise<void> {
    Log.i(ImagePickerDelegate.TAG, "chooseImageFromGallery enter");
    if (!this.setPendingOptionsAndResult(options, null, result)) {
      this.finishWithAlreadyActiveError(result);
      return;
    }

    await this.launchPickImageFromGalleryWant(usePhotoPicker);
  }

  async launchPickImageFromGalleryWant(usePhotoPicker: boolean): Promise<void> {
    Log.i(ImagePickerDelegate.TAG, "launchPickImageFromGalleryWant enter");
    let config: Want = {
      action: 'ohos.want.action.photoPicker',
      type: 'singleselect',
      parameters: {
        uri: 'singleselect',
        maxSelectCount: 1,
        filterMediaType: 'FILTER_MEDIA_TYPE_IMAGE'
      }
    };

    let options: StartOptions = {
      displayId: 0,
    };
    let result: ESObject = null;
    if (this.context) {
      result = await this.context.startAbilityForResult(config, options);
    }
    if (result && result.want && result.want.parameters) {
      let uris = result?.want?.parameters['select-item-list'] as Array<string>;
      let code = result.resultCode as number;
      this.handleChooseImageResult(code, uris);
    }
  }

  handleChooseImageResult(code: number, uris: Array<string>): void {
    if (code == 0) {
      let realPath = FileUtils.getPathFromUri(this.context, uris[0]);
      this.handleImageResult(realPath as string, false);
    } else {
      this.finishWithSuccess(null);
    }
  }

  chooseMultiImagesFromGallery(options: ImageSelectionOptions, usePhotoPicker: boolean, result: MethodResult): void {
    if (!this.setPendingOptionsAndResult(options, null, result)) {
      this.finishWithAlreadyActiveError(result);
      return;
    }

    this.launchMultiPickImageFromGalleryWant(usePhotoPicker);
  }

  async launchMultiPickImageFromGalleryWant(usePhotoPicker: boolean): Promise<void> {
    let config: Want = {
      action: 'ohos.want.action.photoPicker',
      type: 'multipleselect',
      parameters: {
        uri: 'multipleselect',
        maxSelectCount: 9,
        filterMediaType: 'FILTER_MEDIA_TYPE_IMAGE'
      }
    };

    let options: StartOptions = {
      displayId: 0,
    };
    let result: ESObject = null;
    if (this.context) {
      result = await this.context.startAbilityForResult(config, options);
    }
    if (result && result.want && result.want.parameters) {
      let uris = result?.want?.parameters['select-item-list'] as Array<string>;
      let isOriginal =  result.want.parameters['isOriginal'] as boolean;
      let resultCode = result.resultCode as number;
      this.handleChooseMediaResult(resultCode, uris,isOriginal);

    }

  }

  takeImageWithCamera(options: ImageSelectionOptions, result: MethodResult): void {
    if (!this.setPendingOptionsAndResult(options, null, result)) {
      this.finishWithAlreadyActiveError(result);
      return;
    }
    this.launchTakeImageWithCameraWant();
  }

  async launchTakeImageWithCameraWant(): Promise<void> {
    let bundleFlags = bundleManager.BundleFlag.GET_BUNDLE_INFO_DEFAULT;
    let bundleName = ""
    try {
      let t = await bundleManager.getBundleInfoForSelf(bundleFlags)
      bundleName = t.name
    } catch (err) {
      let message = (err as BusinessError).message;
      Log.e('getBundleInfoForSelf failed: %{public}s', message);
    }

    let want: Want = {
      "action": wantConstant.Action.ACTION_IMAGE_CAPTURE,
      parameters: {
        callBundleName: bundleName || "flutter_embedding",
        "supportMultiMode": false
      }
    }
    let result: ESObject = null
    if (this.context) {
      result = await this.context.startAbilityForResult(want);
    }

    if (!result) {
      return
    }
    let uri = result["want"]["parameters"].resourceUri as string;
    let code = result["resultCode"] as number;
    this.pendingCameraMediaUri = uri;
    this.handlerCaptureImageResult(code, uri);
  }
  
  setPendingOptionsAndResult(imageOptions: ImageSelectionOptions | null, videoOptions: VideoSelectionOptions | null,
    result: MethodResult): boolean {
    this.pendingCallState = new PendingCallState(imageOptions, videoOptions, result);
    this.cache.clear();
    return true;
  }

  finishWithAlreadyActiveError(result: MethodResult) {
    result.error("already_active", "Image picker is already active", null);
  }

  handlerCaptureImageResult(code: number, path: string): void {
    if (code == 0 || code == -1) {
      Log.e(ImagePickerDelegate.TAG, "startAbilityForResult for taking image success");
      this.handleImageResult(path, true);
    } else {
      this.finishWithSuccess(null);
    }
  }

  handlerCaptureVideoResult(code: number, path: string): void {
    if (code == 0 || code == -1) {
      Log.e(ImagePickerDelegate.TAG, "startAbilityForResult for taking video success");
      this.handleVideoResult(path, false);
    }
    else {
      this.finishWithSuccess(null);
    }
  }

  async handleImageResult(path: string, shouldDeleteOriginalIfScaled: boolean): Promise<void> {
    Log.i(ImagePickerDelegate.TAG, 'handleImageResult enter');
    let localImageOptions: ImageSelectionOptions | null = null;
    if (this.pendingCallState != null) {
      localImageOptions = this.pendingCallState.imageOptions;
    }

    if (localImageOptions != null) {
      let info = await this.getResizedImagePath(path, localImageOptions);
      if (info != null && info.filePath != path && shouldDeleteOriginalIfScaled) {
        fs.unlink(path);
      }
      this.finishWithSuccess(info.filePath);
    } else {
      this.finishWithSuccess(path);
    }
  }

  async handleMediaResult(paths: Array<string>) {
    let localImageOptions: ImageSelectionOptions | null = null;
    if (this.pendingCallState != null) {
      localImageOptions = this.pendingCallState.imageOptions;
    }

    if (localImageOptions != null) {
      for (let i: number = 0; i < paths.length; i++) {
        let path = paths[i];
        Log.i("yjm 0801 path" + i, ":" + path);
        let info = await this.getResizedImagePath(path, localImageOptions).then((path) => {
          return path;
        });
        if (info != null && info.filePath == path) {
          fs.unlink(path);
        }
        this.finishWithSuccess(info.filePath);
      }
    }
  }

  handleVideoResult(path: string | null, shouldDeleteOriginalIfScaled: boolean): void {
    this.finishWithSuccess(path);
  }

  finishWithSuccess(path: string | null): void {

    Log.i(ImagePickerDelegate.TAG, path);
    let pathList: ArrayList<string> = new ArrayList();
    if (path != null) {
      let realPath = FileUtils.getPathFromUri(this.context as Context, path);
      Log.i(ImagePickerDelegate.TAG, "realPath :" + realPath);
      let file = fs.openSync(realPath, fs.OpenMode.READ_ONLY);
      if (realPath != null) {
        path = realPath;
      }
      pathList.add(realPath)
      pathList.add(file.fd.toString());
    }

    let localResult: MethodResult | null = null;

    if (this.pendingCallState !== null) {
      localResult = this.pendingCallState.result;
    }
    this.pendingCallState = null;

    if (localResult == null) {
      if (!pathList.isEmpty()) {
        this.cache.saveResult(pathList, null, null);
      }
    } else {
      Log.i(ImagePickerDelegate.TAG, pathList[0]);
      localResult.success(pathList);
    }
  }

  finishWithListSuccess(path: ArrayList<string> | null): void {
    let localResult:MethodResult | null = null;
    if (this.pendingCallState != null) {
      localResult = this.pendingCallState.result;
    }
    this.pendingCallState = null;

    if (localResult == null) {
      this.cache.saveResult(path as ArrayList<string>, null, null);
    } else if (path) {

      Log.i(ImagePickerDelegate.TAG, path[0]);
      let pathList: ArrayList<string> = new ArrayList();
      for (let i = 0; i < path.length; i++) {
        const element: string = path[i];
        let file = fs.openSync(element);
        pathList.add(element);
        pathList.add(file.fd.toString());
      }
      localResult.success(pathList as ArrayList<string>);
    }
  }

  async getResizedImagePath(path: string, outputOptions: ImageSelectionOptions): Promise<AssetInfo> {
    return this.imageResizer.resizeImageIfNeeded(path, outputOptions.getMaxWidth(), outputOptions.getMaxHeight(),
      outputOptions.getQuality());
  }
}

class PendingCallState {
  imageOptions: ImageSelectionOptions | null;
  videoOptions: VideoSelectionOptions | null;
  result:MethodResult;

  constructor(imageOptions: ImageSelectionOptions | null, videoOptions: VideoSelectionOptions  | null,
    result: MethodResult) {
    this.imageOptions = imageOptions;
    this.videoOptions = videoOptions;
    this.result = result;
  }
}

export enum CameraDevice {
  REAR,
  FRONT
}