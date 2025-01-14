import { MP4Parser } from '@ohos/mp4parser';
import { common } from '@kit.AbilityKit';
import dayjs from 'dayjs';
import { Log } from '@ohos/flutter_ohos';
import fs from '@ohos.file.fs';
import { media } from '@kit.MediaKit';
import { image } from '@kit.ImageKit';
import { Unity } from './Utility';

export enum VideoQuality {
  DefaultQuality,
  LowQuality,
  MediumQuality,
  HighestQuality,
  Res640x480Quality,
  Res960x540Quality,
  Res1280x720Quality,
  Res1920x1080Quality
}

const TAG = "VideoCompress";

export class VideoCompress {
  context: common.UIAbilityContext;

  constructor(context: common.UIAbilityContext) {
    this.context = context;
  }

  deleteAllCache() {
    fs.listFileSync(this.context.tempDir).forEach(filename => {
      Log.d(TAG, 'deleteAllCache ' + filename)
      if (filename.indexOf('VID') === 0 || filename.indexOf('thumbnail_') === 0) {
        fs.unlinkSync(this.context.tempDir + "/" + filename)
      }
    })
    fs.listFileSync(this.context.cacheDir).forEach(filename => {
      Log.d(TAG, 'deleteAllCache ' + filename)
      if (filename.indexOf('VID') === 0) {
        fs.unlinkSync(this.context.cacheDir + "/" + filename)
      }
    })
    fs.listFileSync(this.context.getApplicationContext().tempDir).forEach(filename => {
      Log.d(TAG, 'deleteAllCache ' + filename)
      if (filename.indexOf('VID') === 0) {
        fs.unlinkSync(this.context.getApplicationContext().tempDir + "/" + filename)
      }
    })
  }

  compress(path: string, quality: number, toPath?: string): Promise<string> {
    let scale = 'scale=-1:1920';
    switch (quality) {
      case VideoQuality.DefaultQuality:
      case VideoQuality.HighestQuality:
        scale = 'scale=-1:1920';
        break;
      case VideoQuality.MediumQuality:
        scale = 'scale=-1:1080';
        break;
      case VideoQuality.LowQuality:
        scale = 'scale=-1:720';
        break;
      case VideoQuality.Res640x480Quality:
        scale = 'scale=640:480';
        break;
      case VideoQuality.Res960x540Quality:
        scale = 'scale=960:540';
        break;
      case VideoQuality.Res1280x720Quality:
        scale = 'scale=1280:720';
        break;
      case VideoQuality.Res1920x1080Quality:
        scale = 'scale=1920:1080';
        break;
      default:
        scale = 'scale=-1:1920';
        break;
    }
    return new Promise(resolve => {
      const sourceMP4 = path;
      let destPath: string | undefined = toPath;
      if(destPath == null || destPath == undefined){
        const localDirPath = this.context.cacheDir + "/";
        const out: string = dayjs().format('YYYY-MM-DD_HH-mm-ss');
        destPath = localDirPath + "VID_OUT_" + out + ".mp4";
      }
      const cmd = `ffmpeg -y -i ${sourceMP4} -c:a copy -vf ${scale} ${destPath}`;
      Log.d(TAG, 'cmd: ' + cmd)
      // MP4Parser.openNativeLog()
      MP4Parser.ffmpegCmd(cmd, {
        callBackResult(code: number) {
          Log.d(TAG, 'callBackResult: ' + code)
          resolve(destPath);
        }
      });
    });
  }

  async getByteThumbnail(path: string, quality: number = 70, position: number = 1) {
    const outFilePath = await this.getFileThumbnail(path, quality, position);
    let file = fs.openSync(outFilePath, fs.OpenMode.READ_WRITE);
    let buf = new ArrayBuffer(fs.statSync(outFilePath).size);
    fs.readSync(file.fd, buf);
    return buf;
  }

  getFileThumbnail(path: string, quality: number = 70, position: number = 1): Promise<string> {
    return new Promise(async resolve => {
      const sourceMP4 = path;
      // 创建AVImageGenerator对象
      let avImageGenerator: media.AVImageGenerator = await media.createAVImageGenerator();
      avImageGenerator.fdSrc = { fd: fs.openSync(sourceMP4, fs.OpenMode.READ_ONLY).fd };
      // 初始化入参
      if (position === -1) {
        position = 0;
      }
      let timeUs = position;
      let queryOption = media.AVImageQueryOptions.AV_IMAGE_QUERY_NEXT_SYNC;
      let param: media.PixelMapParams = {
        width: 300,
        height: 300
      };
      // 获取缩略图（promise模式）
      const pixelMap = await avImageGenerator.fetchFrameByTime(timeUs, queryOption, param);
      // 释放资源（promise模式）
      await avImageGenerator.release();
      const imagePackerApi = image.createImagePacker();

      const out: string = dayjs().format('YYYY-MM-DD_HH-mm-ss');
      const outPath = this.context.tempDir + "/thumbnail_" + out + ".jpg";
      const file = fs.openSync(outPath, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE);
      const packOpts: image.PackingOption = {
        format: "image/jpeg",
        quality: quality,
      }
      await imagePackerApi.packToFile(pixelMap, file.fd, packOpts);
      resolve(outPath);
    });
  }

  getFileThumbnailOld(path: string, quality: number = 70, position: number = 1): Promise<string> {
    return new Promise(resolve => {
      const sourceMP4 = path;
      // MP4Parser.openNativeLog()
      MP4Parser.setDataSource(sourceMP4, {
        callBackResult: (code: number) => {
          if (code == 0) {
            new Unity(this.context).getMediaInfoJsonByAVPlayer(sourceMP4).then(info => {
              const durationPerFrame = info.duration / info.frame_rate;
              const start = durationPerFrame * position + "";
              const end = durationPerFrame * (position + 1) + "";
              MP4Parser.getFrameAtTimeRang(start, end, MP4Parser.OPTION_CLOSEST, {
                callBackResult: async (data: ArrayBuffer, timeUs: number) => {
                  const imageSource = image.createImageSource(data)
                  const imagePixelMap = await imageSource.createPixelMap()
                  const out: string = dayjs().format('YYYY-MM-DD_HH-mm-ss');
                  const outPath = this.context.tempDir + "/thumbnail_" + out + ".jpg"
                  await this.savePixelMap(outPath, imagePixelMap, quality);
                  resolve(outPath)
                }
              });
            });
          }
        }
      });
    });
  }

  // arraybuffer 转PixelMap
  toPixelMap(buf: ArrayBuffer) {
    let source = image.createImageSource(buf)
    return source.createPixelMap()
  }

  // PixelMap 转ArrayBuffer
  toArrayBuffer(pixel: PixelMap) {
    let buf = new ArrayBuffer(pixel.getPixelBytesNumber())
    pixel.readPixelsToBuffer(buf)
  }

  async savePixelMap(path: string, pm: PixelMap, quality = 70): Promise<string> {
    const imagePackerApi: image.ImagePacker = image.createImagePacker();
    const packOpts: image.PackingOption = { format: 'image/jpeg', quality: quality };

    const data: ArrayBuffer = await imagePackerApi.packing(pm, packOpts);
    let uri: string = path;
    let file = fs.openSync(uri, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
    fs.writeSync(file.fd, data);
    fs.closeSync(file);

    return uri;
  }
}