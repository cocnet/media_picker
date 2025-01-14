import { Log } from '@ohos/flutter_ohos';
import fs from '@ohos.file.fs';
import media from '@ohos.multimedia.media';
import { common } from '@kit.AbilityKit';

interface AVPlayerMediaInfo {
  track_index: number;
  track_type: number;
  codec_mime: string;
  duration: number;
  bitrate: number;
  width: number;
  height: number;
  frame_rate: number;
  channel_count: number;
  sample_rate: number;
}

export const TAG: string = "VideoCompressPlugin"

export class Unity {
  context: common.UIAbilityContext;

  constructor(context: common.UIAbilityContext) {
    this.context = context;
  }

  /**
   * https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/avmetadataextractor-0000001813575908-V5
   * @param path
   * @returns
   */
  async getMediaInfoJson(path: string): Promise<Record<string, string | boolean | number>> {
    Log.i(TAG, `getMediaInfoJson ` + path)
    let file = fs.openSync(path, 0o0);
    let fileSize: number = fs.statSync(path).size;
    let avMetadataExtractor: media.AVMetadataExtractor = await media.createAVMetadataExtractor()
    avMetadataExtractor.fdSrc = file
    let metadata = await avMetadataExtractor.fetchMetadata()
    Log.d(TAG, `get meta data, ${JSON.stringify(metadata)}`)
    await avMetadataExtractor.release()

    const title = metadata.title
    const author = metadata.author
    const duration = metadata.duration ? Number(metadata.duration) : 0;
    const width = metadata.videoWidth ? Number(metadata.videoWidth) : 0;
    const height = metadata.videoHeight ? Number(metadata.videoHeight) : 0;

    const result = {
      'path': path,
      'title': title,
      'author': author,
      'width': width,
      'height': height,
      'duration': duration,
      'filesize': fileSize,
      'orientation': '',
    } as Record<string, string | boolean | number>

    Log.d(TAG, `get meta data result, ${JSON.stringify(result)}`)

    return result
  }

  /**
   * 由于AVMetadataExtractor获取到的信息不全，用AVPlayer获取
   * @param _path
   * @returns
   */
  getMediaInfoJsonByAVPlayer(_path: string): Promise<AVPlayerMediaInfo> {
    return new Promise(async resolve => {
      // 创建avPlayer实例对象
      let avPlayer: media.AVPlayer = await media.createAVPlayer();
      avPlayer.on('stateChange', async (state: string, reason: media.StateChangeReason) => {
        if (state === 'initialized') {
          avPlayer.prepare();
        } else if (state === 'prepared') {
          const trackList = await avPlayer.getTrackDescription()
          Log.d(TAG, JSON.stringify(trackList))
          const videoTrack = trackList.find((track) => track['track_type'] === 1)!
          const r = {
            'track_index': videoTrack['track_index'] as number,
            'track_type': videoTrack['track_type'] as number,
            'codec_mime': videoTrack['codec_mime'] as string,
            'duration': avPlayer.duration,
            'bitrate': videoTrack['bitrate'] as number,
            'width': videoTrack['width'] as number,
            'height': videoTrack['height'] as number,
            'frame_rate': videoTrack['frame_rate'] as number,
            'channel_count': videoTrack['channel_count'] as number,
            'sample_rate': videoTrack['sample_rate'] as number,
          } as AVPlayerMediaInfo;
          avPlayer.stop(); //调用播放结束接口
          avPlayer.release();
          resolve(r);
        } else if (state === 'playing') {
          avPlayer.stop(); //调用播放结束接口
          avPlayer.release();
        }
      })
      let fdPath = 'fd://';
      // 通过UIAbilityContext获取沙箱地址filesDir，以Stage模型为例
      // let pathDir = this.context.filesDir;
      // let path = pathDir + _path;
      // 打开相应的资源文件地址获取fd，并为url赋值触发initialized状态机上报
      Log.d(TAG, `get meta data 2 path, ${_path}`)
      let file = await fs.open(_path);
      fdPath = fdPath + '' + file.fd;
      Log.d(TAG, `get meta data 2 fdPath, ${fdPath}`)
      avPlayer.url = fdPath;
    });
  }
}