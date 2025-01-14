import common from '@ohos.app.ability.common';
import fs from '@ohos.file.fs';
import util from '@ohos.util';
import Log from '@ohos/flutter_ohos/src/main/ets/util/Log';
import { cryptoFramework } from '@kit.CryptoArchitectureKit';
import { buffer } from '@kit.ArkTS';

const TAG = "FileUtils";

export default class FileUtils {
  static getSha1(content: string): string{
    //TODO md5
    let mdAlgName = 'SHA1'; // 摘要算法名
    let md = cryptoFramework.createMd(mdAlgName);
    md.updateSync({ data: new Uint8Array(buffer.from(content, 'utf-8').buffer) });
    let mdResult = md.digestSync();
    let decoder = util.TextDecoder.create('utf-8');
    let stringData = decoder.decodeWithStream(mdResult.data);
    console.log('stringData:', stringData);
    return stringData;
  }

  static cacheDir(context: common.Context): string{
    let dir = context.cacheDir + "/multi_image_pick/";
    try {
      if(!fs.accessSync(dir)){
        fs.mkdirSync(dir, true);
      }
    } catch (err) {
      console.log("error", err);
    }
    return dir;
  }

  static assetBasePath(uri: string,context: common.Context): string{
    // let uuid = FileUtils.getSha1(uri);
    // let targetDirectoryPath = FileUtils.cacheDir(context) + uuid;
    // return targetDirectoryPath;
    return FileUtils.cacheDir(context);
  }

  static videoCoverImageName(uri: string): string{
    let name = uri.substring(uri.lastIndexOf("/") + 1) + '_cover.jpg';
    return name;
  }

  static getPathFromUri(context: common.Context | null, uri: string, defExtension?: string) {
    Log.i(TAG, "getPathFromUri : " + uri);
    let inputFile: fs.File;
    try {
      inputFile = fs.openSync(uri);
    } catch (err) {
      Log.e(TAG, "open uri file failed err:" + err)
      return null;
    }
    if (inputFile == null) {return null;}
    if (!context) {return null;}

    let targetDirectoryPath = FileUtils.assetBasePath(uri,context);
      try {
        if(!fs.accessSync(targetDirectoryPath)){
          fs.mkdirSync(targetDirectoryPath, true);
          let targetDir = fs.openSync(targetDirectoryPath);
          Log.i(TAG, "mkdirSync success targetDirectoryPath:" + targetDirectoryPath + " fd: " + targetDir.fd);
          fs.closeSync(targetDir);
        }
      } catch (err) {
        Log.e(TAG, "mkdirSync failed err:" + err);
        return null;
      }

      const inputFilePath = uri.substring(uri.lastIndexOf("/") + 1);
      const inputFilePathSplits = inputFilePath.split(".");
      Log.i(TAG, "getPathFromUri inputFilePath: " + inputFilePath);
      const outputFileName = inputFilePathSplits[0];
      let extension: string;
      if (inputFilePathSplits.length >= 2) {
        extension = "." + inputFilePathSplits[inputFilePathSplits.length-1];
      } else {
        if (defExtension) {
          extension = defExtension;
        } else {
          extension = ".jpg";
        }
      }
      const outputFilePath = targetDirectoryPath + outputFileName + extension;
      if(fs.accessSync(outputFilePath)){
        return outputFilePath;
      }
      const outputFile = fs.openSync(outputFilePath, fs.OpenMode.CREATE);
      try {
        Log.i(TAG, "copyFileSync inputFile fd:" + inputFile.fd + " outputFile fd:" + outputFile.fd);
        fs.copyFileSync(inputFile.fd, outputFilePath);
      } catch (err) {
        Log.e(TAG, "copyFileSync failed err:" + err);
        return null;
      } finally {
        fs.closeSync(inputFile);
        fs.closeSync(outputFile);
      }
      return outputFilePath;

  }
}