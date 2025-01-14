import image from '@ohos.multimedia.image';
import fs from '@ohos.file.fs';
import common from '@ohos.app.ability.common';
import Log from '@ohos/flutter_ohos/src/main/ets/util/Log';
import {AssetInfo} from './Messages';
import  FileUtils from './FileUtils';

const TAG: string = "ImageResizer";

export default class ImageResizer {
  private readonly context: common.Context;

  constructor(context: common.Context) {
    this.context = context;
  }

  async resizeImageIfNeeded(imagePath: string, maxWidth: number, maxHeight: number, imageQuality: number, fileNamePrefix:string="origin_"):
    Promise<AssetInfo> {
    let info = new AssetInfo();
    info.identifier = imagePath;
    info.filePath = imagePath;
    info.fileType = "image/jpg";
    if (imagePath == null) {
      Log.e(TAG, "imagePath is null");
      return info;
    }

    let shouldScale: boolean = (maxWidth != null || maxHeight != null || imageQuality < 100);
    if (!shouldScale) {
      return info;
    }

    let imageFile: fs.File | null = null;
    let imageSource: image.ImageSource | null = null;
    let imagePixelMap: image.PixelMap | null = null;
    try {
      let parts: string[] = imagePath.split('/', -1);
      let imageName: string = fileNamePrefix + parts[parts.length - 1];
      let maybeLocalPathName: string = FileUtils.cacheDir(this.context) + imageName;
      if(fs.accessSync(maybeLocalPathName)){
        imageFile = fs.openSync(maybeLocalPathName);
        imageSource = image.createImageSource(imageFile.fd);
        let imageInfo: image.ImageInfo = await imageSource.getImageInfo();
        info.filePath = maybeLocalPathName;
        info.originalWidth = imageInfo.size.width;
        info.originalHeight = imageInfo.size.height;
        return info;
      }

      imageFile = fs.openSync(imagePath, fs.OpenMode.READ_ONLY);
      imageSource = image.createImageSource(imageFile.fd);
      let imageInfo: image.ImageInfo = await imageSource.getImageInfo();
      if (imageInfo.size.width == -1 || imageInfo.size.height == -1) {
        return info;
      }
      if(imageName.endsWith(".gif")){
        fs.copyFileSync(imageFile.fd, maybeLocalPathName);
        info.filePath = maybeLocalPathName;
        info.originalWidth = imageInfo.size.width;
        info.originalHeight = imageInfo.size.height;
        return info;
      }

      let targetSize: image.Size = this.calculateTargetSize(imageInfo.size.width, imageInfo.size.height, maxWidth,
        maxHeight);
      Log.d(TAG, "Start scale image, origin w:" + imageInfo.size.width + " origin h:" + imageInfo.size.width +
        " target w:" + targetSize.width + " target h:" + targetSize.height);

      imagePixelMap = await imageSource.createPixelMap({
        desiredSize: targetSize
      });

      let outFileName = await this.createImageOnExternalDirectory(imagePixelMap, imageName, imageQuality);
      // await this.exifDataCopier.copyExif(imagePath, outFileName);
      let imgSize = imagePixelMap.getImageInfoSync().size;
      info.filePath = outFileName;
      info.originalWidth = imgSize.width;
      info.originalHeight = imgSize.height;
      return info;
    } catch (e) {
      Log.e(TAG, "Resize image failed " + imagePath + " err " + e);
      return info;
    } finally {
      if (imageFile != null) {
        try {
          fs.closeSync(imageFile);
        } catch (e) {
          Log.e(TAG, "Close image failed failed " + e);
        }
      }
      if (imageSource != null) {
        await imageSource.release();
      }
      if (imagePixelMap != null) {
        await imagePixelMap.release();
      }
    }
  }

  private calculateTargetSize(originalWidth: number, originalHeight: number, maxWidth: number,
    maxHeight: number): image.Size {
    let hasMaxWidth: boolean = maxWidth != null;
    let hasMaxHeight: boolean = maxHeight != null;

    let width: number = hasMaxWidth ? Math.min(originalWidth, maxWidth) : originalWidth;
    let height: number = hasMaxHeight ? Math.min(originalHeight, maxHeight) : originalHeight;

    let shouldDownscaleWidth: boolean = hasMaxWidth && maxWidth < originalWidth;
    let shouldDownscaleHeight: boolean = hasMaxHeight && maxHeight < originalHeight;
    let shouldDownscale: boolean = shouldDownscaleWidth || shouldDownscaleHeight;

    if (shouldDownscale) {
      let downscaledWidth: number = (height / originalHeight) * originalWidth;
      let downscaledHeight: number = (width / originalWidth) * originalHeight;

      if (width < height) {
        if (!hasMaxWidth) {
          width = downscaledWidth;
        } else {
          height = downscaledHeight;
        }
      } else if (height < width) {
        if (!hasMaxHeight) {
          height = downscaledHeight;
        } else {
          width = downscaledWidth;
        }
      } else {
        if (originalWidth < originalHeight) {
          width = downscaledWidth;
        } else if (originalHeight < originalWidth) {
          height = downscaledHeight;
        }
      }
    }
    return {width, height};
  }

  public  async createImageOnExternalDirectory(imagePixelMap: image.PixelMap, imageName: string, imageQuality: number):
    Promise<string> {
    if (imageName.endsWith('.mp4')) {
      imageName = imageName.replace('.mp4','.jpg');
    }
    let imagePackerApi: image.ImagePacker | null = null;
    let outFile: fs.File | null = null;
    let outFileName: string = FileUtils.cacheDir(this.context) + imageName;
    if (fs.accessSync(outFileName)) {
      return outFileName;
    }

    try {
      let f = "image/jpeg";
      if(imageName.endsWith(".png")){
        f = "image/png";
      }
      imagePackerApi = image.createImagePacker();
      let bufferData = await imagePackerApi.packing(imagePixelMap, {
        format: f, quality: imageQuality
      });

      outFile = fs.openSync(outFileName, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE | fs.OpenMode.TRUNC);
      let writLen = fs.writeSync(outFile.fd, bufferData, {
        offset: 0
      });
      console.log("writLen",writLen);
    } finally {
      if (imagePackerApi != null) {
        await imagePackerApi.release();
      }
      if (outFile != null) {
        try {
          fs.closeSync(outFile);
        } catch (e) {
          Log.w(TAG, "Close out file failed");
        }
      }
    }
    return outFileName;
  }
}