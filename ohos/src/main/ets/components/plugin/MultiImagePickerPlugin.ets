import {
  FlutterPlugin,
  FlutterPluginBinding,
  MethodCall,
  MethodCallHandler,
  MethodChannel,
  MethodResult,
} from '@ohos/flutter_ohos';

import AbilityLifecycleCallback from '@ohos.app.ability.AbilityLifecycleCallback';
import AbilityAware from '@ohos/flutter_ohos/src/main/ets/embedding/engine/plugins/ability/AbilityAware';
import common from '@ohos.app.ability.common';
import Ability from '@ohos.app.ability.Ability';
import ImagePickerDelegate from './ImagePickerDelegate';
import ImagePickerCache from './ImagePickerCache';
import ImageResizer from './ImageResizer';
import UIAbility from '@ohos.app.ability.UIAbility';
import Log from '@ohos/flutter_ohos/src/main/ets/util/Log';
import FileUtils from './FileUtils';
import { ImageSelectionOptions,VideoSelectionOptions } from './Messages';

import {
  AbilityPluginBinding
} from '@ohos/flutter_ohos/src/main/ets/embedding/engine/plugins/ability/AbilityPluginBinding';
import { BinaryMessenger } from '@ohos/flutter_ohos';
import { Permissions, abilityAccessCtrl } from '@kit.AbilityKit';
import fs from '@ohos.file.fs';

/** MultiImagePickerPlugin **/
export default class MultiImagePickerPlugin implements FlutterPlugin,AbilityAware, MethodCallHandler {
  private channel: MethodChannel | null = null;
  private static TAG = "ImagePickerPlugin";
  private pluginBinding: FlutterPluginBinding | null = null;

  private state: AbilityState | null = null;

  private context: common.UIAbilityContext | null = null;

  constructor() {}

  onDetachedFromAbility(): void {
    if (this.state != null) {
      this.state.release();
      this.state = null;
    }
  }

  getUniqueClassName(): string {
    return "MultiImagePickerPlugin"
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.pluginBinding = binding;
    this.channel = new MethodChannel(binding.getBinaryMessenger(), "multi_image_picker");
    this.channel.setMethodCallHandler(this)
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    this.pluginBinding = null;
    if (this.channel != null) {
      this.channel.setMethodCallHandler(null)
    }
  }

  onAttachedToAbility(binding: AbilityPluginBinding): void {
    Log.i(MultiImagePickerPlugin.TAG, "onAttachedToAbility");
    this.context = binding.getAbility().context;
    if (!this.pluginBinding) {
      return
    }
    this.setup(this.pluginBinding.getBinaryMessenger(), this.pluginBinding.getApplicationContext(),
      binding.getAbility(), binding);
  }

  setup(messenger: BinaryMessenger, context: common.Context, ability: UIAbility, binding: AbilityPluginBinding): void {
    this.state = new AbilityState(ability, null, messenger, binding, context);
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    if(call.method == "pickImages"){
      //打开图片选择器（系统相册）
      let maxImages = call.argument("maxImages") as number ?? 9;
      let showType = call.argument('mediaShowTypes') as string ?? "";
      this.getImagePickerDelegate()?.pickImages(maxImages, showType,result);
    }else if(call.method == 'fetchMediaThumbData'){
      // 获取指定媒体的缩略图或者视频封面， 消息发送中占位预览图片
      let selectedAssets = call.argument("identifier")  as string;
      let thumb = call.argument('thumb') as boolean ?? true;
      let delegate = this.getImagePickerDelegate();
      delegate?.setPendingOptionsAndResult(
        new ImageSelectionOptions(),
        new VideoSelectionOptions(),
        result,
      )
      delegate!.fetchMediaThumbDataV2(selectedAssets,thumb, result);
    }else if(call.method == 'obtainVideoCover'){
      // 获取视频封面，返回沙盒path
      let selectedAssets = call.argument("identifier")  as string;
      let thumb = call.argument('thumb') as boolean ?? true;
      this.getImagePickerDelegate()?.obtainVideoCover(selectedAssets,thumb, result);
    } else if(call.method == "requestMediaData"){
      // 获取指定媒体信息 selectedAssets 为指定媒体的Identify
      // 图片视频压缩，最终发送文件
      let selectedAssets = call.argument("selectedAssets") as Array<string>;
      let thumb = call.argument('thumb') as boolean ?? true;
      let delegate = this.getImagePickerDelegate();
      delegate?.setPendingOptionsAndResult(
        new ImageSelectionOptions(),
        new VideoSelectionOptions(),
        result,
      );
      delegate?.requestMediaData(selectedAssets, thumb, result);
    }else if(call.method == "fetchMediaInfo"){
      // 获取手机数据库中的媒体信息,或者获取指定identifier的媒体信息;图片视频尺寸，大小
      let selectedAssets = call.argument("selectedAssets") as Array<string> ?? [];
      this.getImagePickerDelegate()?.fetchMediaInfoV2(this.context!, result, selectedAssets);
    }else if(call.method == "requestThumbDirectory"){
      const targetDirectoryPath = FileUtils.cacheDir(this.context!);
      result.success(targetDirectoryPath);
    }else if(call.method == "requestFilePath"){
      // 通过id 获取沙盒图片的路径
      let localIdentifier = call.argument("identifier") as string ?? "";
      let path = FileUtils.getPathFromUri(this.context,localIdentifier);
      result.success(path);
    }else if(call.method == "requestFileSize"){
      let localIdentifier = call.argument("identifier") as string ?? "";
      let path = FileUtils.getPathFromUri(this.context,localIdentifier);
      let size = fs.statSync(path).size;
      result.success(size);
    } else if(call.method == 'loadAlbums'){
      // 无权限，使用需要申请READ_MEDIA权限
      this.getImagePickerDelegate()?.fetchAllAlbums(this.context!, result);
    }else if(call.method == "requestMediaPermissions"){
      const PERMISSIONS: Array<Permissions> = [
        'ohos.permission.READ_MEDIA',
        'ohos.permission.WRITE_MEDIA',
        'ohos.permission.MEDIA_LOCATION',
        'ohos.permission.MANAGE_MISSIONS'
      ];
      abilityAccessCtrl.createAtManager().requestPermissionsFromUser(getContext(this), PERMISSIONS);
      result.success(null);
    }else if(call.method == "cachedVideoPath"){
        //视频边播边下缓存路径
      const targetDirectoryPath = FileUtils.cacheDir(this.context!);
      result.success(targetDirectoryPath + "video/");
    }else if(call.method == "cachedVideoDirectory"){
      const targetDirectoryPath = FileUtils.cacheDir(this.context!);
      result.success(targetDirectoryPath + "video/");
    }else if(call.method == "deleteCacheVideo"){
      result.success(null);
    } else {
      result.notImplemented()
    }
  }

  getAbilityState(): AbilityState | null {
    return this.state;
  }

  static constructorDelegate(setupAbility: UIAbility): ImagePickerDelegate {
    let cache: ImagePickerCache = new ImagePickerCache(setupAbility.context);
    let imageResizer: ImageResizer = new ImageResizer(setupAbility.context);
    return new ImagePickerDelegate(setupAbility, imageResizer, cache);
  }

  getImagePickerDelegate(): ImagePickerDelegate | null {
    if (this.state == null || this.state.getAbility() == null) {
      return null;
    }
    return this.state.getDelegate();
  }
}

class AbilityState {
  private ability: UIAbility | null;
  private context: common.Context | null = null;
  private abilityBinding: AbilityPluginBinding | null = null;
  private messenger: BinaryMessenger | null = null;
  private delegate: ImagePickerDelegate | null = null;
  private abilityLifecycleCallback: AbilityLifecycleCallback;

  constructor(ability: UIAbility, delegate?: ImagePickerDelegate | null, messenger?: BinaryMessenger, abilityBinding?: AbilityPluginBinding, context?: common.Context) {
    this.ability = ability;
    if (context) {
      this.context = context;
    }
    if (abilityBinding) {
      this.abilityBinding = abilityBinding;
    }
    if (messenger) {
      this.messenger = messenger;
    }
    if (delegate) {
      this.delegate = delegate;
    }

    this.abilityLifecycleCallback = {
      onAbilityCreate(_ability) {
        console.log('AbilityLifecycleCallback onAbilityCreate.');
      },
      onWindowStageCreate(_ability, _windowStage) {
        console.log('AbilityLifecycleCallback onWindowStageCreate.');
      },
      onWindowStageActive(_ability, _windowStage) {
        console.log('AbilityLifecycleCallback onWindowStageActive.');
      },
      onWindowStageInactive(_ability, _windowStage) {
        console.log('AbilityLifecycleCallback onWindowStageInactive.');
      },
      onWindowStageDestroy(_ability, _windowStage) {
        console.log('AbilityLifecycleCallback onWindowStageDestroy.');
      },
      onAbilityDestroy(_ability) {
        console.log('AbilityLifecycleCallback onAbilityDestroy.');
      },
      onAbilityForeground(_ability) {
        console.log('AbilityLifecycleCallback onAbilityForeground.');
      },
      onAbilityBackground(_ability) {
        console.log('AbilityLifecycleCallback onAbilityBackground.');
      },
      onAbilityContinue(_ability) {
        console.log('AbilityLifecycleCallback onAbilityContinue.');
      }
    };
    this.delegate = MultiImagePickerPlugin.constructorDelegate(this.ability);
  }

  release(): void {
    if (this.abilityBinding != null) {
      this.abilityBinding = null;
    }
    this.ability = null;
    this.delegate = null;
  }

  getAbility(): Ability | null {
    return this.ability;
  }

  getDelegate(): ImagePickerDelegate | null {
    return this.delegate;
  }
}