package com.idreamsky.multi_image_picker;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.text.TextUtils;

import androidx.core.content.ContextCompat;
import androidx.annotation.NonNull;

import com.facebook.cache.disk.DiskCacheConfig;
import com.facebook.common.internal.Supplier;
import com.facebook.common.util.ByteConstants;
import com.facebook.drawee.backends.pipeline.Fresco;
import com.facebook.imagepipeline.cache.MemoryCacheParams;
import com.facebook.imagepipeline.core.ImagePipelineConfig;
import com.idreamsky.fanbook.common.utils.FilePathManager;
import com.idreamsky.fanbook.common.utils.Logger;
import com.sangcomz.fishbun.AlbumType;
import com.sangcomz.fishbun.FishBun;
import com.sangcomz.fishbun.FishBunCreator;
import com.sangcomz.fishbun.Fishton;
import com.idreamsky.fanbook.common.utils.imageloader.GlideHelper;
import com.sangcomz.fishbun.bean.Album;
import com.sangcomz.fishbun.util.DisplayAlbum;
import com.sangcomz.fishbun.util.MediaInfoData;
import com.sangcomz.fishbun.util.PermissionCheck;
import com.sangcomz.fishbun.util.DisplayImage;
import com.sangcomz.fishbun.util.MediaCompress;
import com.sangcomz.fishbun.util.MediaThumbData;
import com.sangcomz.fishbun.util.ProxyCacheUtils;
import com.sangcomz.fishbun.util.QueryResult;
import com.squareup.picasso.Picasso;

import java.io.File;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;


/**
 * MultiImagePickerPlugin
 */
public class MultiImagePickerPlugin implements FlutterPlugin, ActivityAware, MethodCallHandler, PluginRegistry.ActivityResultListener {
    private static final String CHANNEL_NAME = "multi_image_picker";

    private static final String function_pickImages = "pickImages";
    private static final String function_loadAlbums = "loadAlbums";
    private static final String function_requestMediaData = "requestMediaData";
    private static final String function_requestCompressMedia = "requestCompressMedia";
    private static final String function_requestFilePath = "requestFilePath";
    private static final String function_requestFileSize = "requestFileSize";
    private static final String function_requestFileDimen = "requestFileDimen";
    private static final String function_requestThumbDirectory = "requestThumbDirectory";
    private static final String function_fetchMediaThumbData = "fetchMediaThumbData";
    private static final String function_fetchMediaInfo = "fetchMediaInfo";
    private static final String function_fetchCachedVideoPath = "cachedVideoPath";
    private static final String function_fetchCachedVideoDirectory = "cachedVideoDirectory";

    private static final String arg_maxImages = "maxImages";
    private static final String arg_thumb = "thumb";
    private static final String arg_identifier = "identifier";
    private static final String arg_fileType = "fileType";
    private static final String arg_limit = "limit";
    private static final String arg_offset = "offset";

    private static final String arg_albumId = "albumId";
    private static final String arg_album_detail = "albumDetail";
    private static final String arg_selectedAssets = "selectedAssets";
    private static final String arg_defaultAsset = "defaultAsset";
    private static final String arg_mediaSelectTypes = "mediaSelectTypes";
    private static final String arg_mediaShowTypes = "mediaShowTypes";
    private static final String arg_doneButtonText = "doneButtonText";
    private static final String arg_androidOptions = "androidOptions";

    private static final String error_permissionError = "PERMISSION_PERMANENTLY_DENIED";
    private static final String error_permissionDesc = "NO PERMISSION";
    private static final String error_getFailed = "GET FAILED";
    private static final String error_newPickerComeIn = "TIME OUT NEW PICKER COME IN";

    private static final int requestcode_pick_media = 1001;
    public static final int requestcode_pick_media_for_add_clip = 1005;

    public final static String intent_param_position = "position";
    public final static String intent_param_album = "album";
    public final static String intent_param_album_id = "album_id";
    public final static String intent_param_result = "result";
    public final static String intent_param_thumb = "thumb";

    private Activity activity;
    public static Context context;
    private MethodChannel channel;
    private static Result currentResult;
    public static MultiImagePickerPlugin sPluginInstance;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), CHANNEL_NAME);
        channel.setMethodCallHandler(this);
        context = flutterPluginBinding.getApplicationContext();
        sPluginInstance = this;
        FilePathManager.initPath(context);
        initPicasso();
        initFresco();
    }

    private void initPicasso() {
        Picasso.Builder builder = new Picasso.Builder(context);
        builder.listener(new Picasso.Listener() {
            @Override
            public void onImageLoadFailed(Picasso picasso, Uri uri, Exception exception) {
                Logger.e("Picasso onImageLoadFailed : " + uri);
                exception.printStackTrace();
            }
        });
        try {
            Picasso.setSingletonInstance(builder.build());
        } catch (IllegalStateException e) {
            e.printStackTrace();
            Logger.e("Picasso 初始化异常");
        }
    }

    private void initFresco() {
        /*
         * 一级缓存参数 config, >=5.0 in java memory, <5.0 in native memeory.
         */
        Supplier<MemoryCacheParams> memoryCacheConfigL1 = new Supplier<MemoryCacheParams>() {
            @Override
            public MemoryCacheParams get() {
                return new MemoryCacheParams(
                        /* 已解码图片缓存最大值,以字节为单位 */
                        30 * ByteConstants.MB,
                        /* 已解码缓存图片最大数量 */
                        256,
                        /* 缓存中准备清除但尚未被删除的容器大小(驱逐器) */
                        15 * ByteConstants.MB,
                        /* 驱逐器中的图片数量 */
                        Integer.MAX_VALUE,
                        /* 缓存中单个图片最大值 */
                        Integer.MAX_VALUE);
            }
        };
        /*
         * 二级缓存参数 config, in native memory.
         */
        Supplier<MemoryCacheParams> memoryCacheConfigL2 = new Supplier<MemoryCacheParams>() {
            @Override
            public MemoryCacheParams get() {
                return new MemoryCacheParams(
                        /* 未解码图片缓存最大值,以字节为单位 */
                        10 * ByteConstants.MB,
                        /* 未解码缓存图片最大数量 */
                        Integer.MAX_VALUE,
                        /* 缓存中准备清除但尚未被删除的容器大小(驱逐器) */
                        10 * ByteConstants.MB,
                        /* 驱逐器中的图片数量 */
                        Integer.MAX_VALUE,
                        /* 缓存中单个图片最大值 */
                        8 * ByteConstants.MB);
            }
        };

        /**
         *三级缓存--参数
         */
        DiskCacheConfig diskCacheConfig = DiskCacheConfig.newBuilder(context)
                .setBaseDirectoryPath(Environment.getExternalStorageDirectory().getAbsoluteFile())// 缓存图片基路径
                /* 缓存文件夹名 */
                .setBaseDirectoryName("fanbook_image_cache")
                /* 默认缓存的最大值 */
                .setMaxCacheSize(100 * ByteConstants.MB)
                /* 低磁盘空间时，缓存的最大值 */
                .setMaxCacheSizeOnLowDiskSpace(100 / 2 * ByteConstants.MB)
                /* 非常低磁盘空间时，缓存的最大值 */
                .setMaxCacheSizeOnVeryLowDiskSpace(100 / 3 * ByteConstants.MB)
                /* 磁盘配置的版本 */
                .setVersion(1).build();

        ImagePipelineConfig.Builder builder = ImagePipelineConfig.newBuilder(context)
                .setDownsampleEnabled(true)
                /* 一级缓存配置 */
                .setBitmapMemoryCacheParamsSupplier(memoryCacheConfigL1)
                /* 二级缓存配置 */
                .setEncodedMemoryCacheParamsSupplier(memoryCacheConfigL2)
                /* 三级缓存配置(磁盘) */
                .setMainDiskCacheConfig(diskCacheConfig)
                .setBitmapsConfig(Bitmap.Config.RGB_565);

        ImagePipelineConfig config = builder.build();
        Fresco.initialize(context, config);
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
        sPluginInstance = null;
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        activity = binding.getActivity();
        binding.addActivityResultListener(this);
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity();
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        onAttachedToActivity(binding);
    }

    @Override
    public void onDetachedFromActivity() {
        activity = null;
    }

    @Override
    public void onMethodCall(final MethodCall call, final Result result) {
        try {
            switch (call.method) {
                case function_pickImages: {//老版本图片选择
                    if (checkPermission(false, false, true)) {
                        if (currentResult != null)
                            currentResult.error(error_newPickerComeIn, "", null);
                        currentResult = result;
                        presentPicker(call);
                    } else {
                        if (currentResult != null) {
                            currentResult.error(error_permissionError, error_permissionDesc, null);
                            currentResult = null;
                        } else {
                            result.error(error_permissionError, error_permissionDesc, null);
                        }
                    }
                    break;
                }
                case function_loadAlbums: {
                    if (checkPermission(false, false, true)) {
                        if (currentResult != null)
                            currentResult.error(error_newPickerComeIn, "", null);
                        currentResult = result;
                        DisplayAlbum displayAlbum = new DisplayAlbum(context.getString(R.string.str_all_view), "all", context);
                        displayAlbum.setListener(new DisplayAlbum.DisplayAlbumListener() {
                            @Override
                            public void OnDisplayAlbumDidSelectFinish(ArrayList albums) {
                                List<Album> albumList = albums;
                                List<HashMap<String, Object>> data = new ArrayList<>();
                                for (Album album : albumList) {
                                    data.add(album.toMap());
                                }
                                result.success(data);
                                currentResult = null;
                            }
                        });
                        displayAlbum.execute();
                    } else {
                        if (currentResult != null) {
                            currentResult.error(error_permissionError, error_permissionDesc, null);
                            currentResult = null;
                        } else {
                            result.error(error_permissionError, error_permissionDesc, null);
                        }
                    }
                    break;
                }
                case function_fetchMediaInfo: {
                    if (checkPermission(false, false, true)) {
                        int limit = call.argument(arg_limit);
                        int offset = call.argument(arg_offset);
                        int albumId = 0;
                        if (call.argument(arg_albumId) != null) {
                            albumId = call.argument(arg_albumId);
                        }

                        String showMediaType = call.argument(arg_mediaShowTypes);
                        showMediaType = TextUtils.isEmpty(showMediaType) ? "all" : showMediaType;
                        ArrayList<String> selectMedias = call.argument(arg_selectedAssets);
                        selectMedias = selectMedias == null ? new ArrayList<String>() : selectMedias;
                        DisplayImage displayImage = new DisplayImage((long) albumId, selectMedias, showMediaType, activity);
                        displayImage.setRequestHashMap(true);
                        displayImage.setLimit(limit);
                        displayImage.setOffset(offset);
                        displayImage.setRequestVideoDimen(!selectMedias.isEmpty());
                        displayImage.setListener(new DisplayImage.DisplayImageListener() {
                            @Override
                            public void OnDisplayImageDidSelectFinish(QueryResult qr) {
                                result.success(qr.medias);
                            }
                        });
                        displayImage.execute();
                    } else {
                        result.error(error_permissionError, error_permissionDesc, null);
                    }
                    break;
                }
                case function_requestFilePath: {
                    String identify = call.argument(arg_identifier);
                    ArrayList<String> selectMedias = new ArrayList<>();
                    selectMedias.add(identify);
                    DisplayImage displayImage = new DisplayImage((long) 0, selectMedias, "all", activity);
                    displayImage.setRequestHashMap(true);
                    displayImage.setRequestVideoDimen(false);
                    displayImage.setListener(new DisplayImage.DisplayImageListener() {
                        @Override
                        public void OnDisplayImageDidSelectFinish(QueryResult qr) {
                            if (qr.medias.size() > 0) {
                                HashMap hashMap = new HashMap();
                                hashMap.put("filePath", ((HashMap) qr.medias.get(0)).get("filePath"));
                                result.success(hashMap);
                            } else {
                                result.error(error_getFailed, error_getFailed, "get media failed");
                            }
                        }
                    });
                    displayImage.execute();
                    break;
                }
                case function_fetchMediaThumbData: {
                    if (checkPermission(false, false, true)) {
                        String identify = call.argument(arg_identifier);
                        String fileType = call.argument(arg_fileType);
                        boolean origin = call.argument(arg_thumb).toString() == "origin";
                        MediaThumbData mediaThumbData = new MediaThumbData(identify, fileType, !origin, activity);
                        mediaThumbData.setListener(new MediaThumbData.MediaThumbDataListener() {
                            @Override
                            public void mediaThumbDataDidFinish(byte[] bytes) {
                                result.success(bytes);
                            }
                        });
                        mediaThumbData.execute();
                    } else {
                        result.error(error_permissionError, error_permissionDesc, null);
                    }
                    break;
                }
                case function_requestFileSize: {
                    if (checkPermission(false, false, true)) {
                        String identify = call.argument(arg_identifier);
                        MediaInfoData mediaInfoData = new MediaInfoData(identify, activity);
                        mediaInfoData.setListener(new MediaInfoData.MediaInfoDataListener() {
                            @Override
                            public void mediaInfoDataDidFinish(HashMap hashMap) {
                                result.success(hashMap.get("size"));
                            }
                        });
                        mediaInfoData.execute();
                    } else {
                        result.error(error_permissionError, error_permissionDesc, null);
                    }
                    break;
                }
                case function_requestFileDimen: {
                    if (checkPermission(false, false, true)) {
                        String identify = call.argument(arg_identifier);
                        MediaInfoData mediaInfoData = new MediaInfoData(identify, activity);
                        mediaInfoData.setListener(new MediaInfoData.MediaInfoDataListener() {
                            @Override
                            public void mediaInfoDataDidFinish(HashMap hashMap) {
                                result.success(hashMap);
                            }
                        });
                        mediaInfoData.execute();
                    } else {
                        result.error(error_permissionError, error_permissionDesc, null);
                    }
                    break;
                }
                case function_requestThumbDirectory: {
                    result.success(context.getCacheDir().getAbsolutePath() + "/multi_image_pick/thumb/");
                    break;
                }
                case function_requestCompressMedia: {
                    if (checkPermission(false, false, true)) {
                        boolean thumb = call.argument("thumb");
                        String fileType = call.argument("fileType");
                        List<String> selectMedias = call.argument("fileList");
                        MediaCompress mediaCompress = new MediaCompress(thumb, selectMedias, fileType, activity);
                        mediaCompress.setListener(new MediaCompress.MediaCompressListener() {
                            @Override
                            public void mediaCompressDidFinish(ArrayList<HashMap> results) {
                                result.success(results);
                            }
                        });
                        mediaCompress.execute();
                    } else {
                        result.error(error_permissionError, error_permissionDesc, null);
                    }
                    break;
                }
                case function_requestMediaData: {
                    if (checkPermission(false, false, true)) {
                        boolean thumb = call.argument("thumb");
                        List<String> selectMedias = call.argument("selectedAssets");
                        MediaCompress mediaCompress = new MediaCompress(thumb, selectMedias, activity);
                        mediaCompress.setListener(new MediaCompress.MediaCompressListener() {
                            @Override
                            public void mediaCompressDidFinish(ArrayList<HashMap> results) {
                                result.success(results);
                            }
                        });
                        mediaCompress.execute();
                    } else {
                        result.error(error_permissionError, error_permissionDesc, null);
                    }
                    break;
                }
                case function_fetchCachedVideoPath: {
                    try {
                        String url = call.argument("url");
                        if (!TextUtils.isEmpty(url)) {
                            result.success(getVideoCacheDir(context, url).getAbsolutePath());
                        } else {
                            result.success("");
                        }
                    } catch (Exception e) {
                        result.success("");
                    }
                    break;
                }
                case function_fetchCachedVideoDirectory: {
                    try {
                        File file = new File(context.getExternalCacheDir(), "video-cache");
                        result.success(file.getAbsolutePath());
                    } catch (Exception e) {
                        result.success("");
                    }
                    break;
                }
            }
        } catch (Exception e) {
            if (currentResult != null) {
                try {
                    currentResult.error(e.getMessage(), e.toString(), null);
                } catch (Exception e1) {
                    e1.printStackTrace();
                }
                currentResult = null;
            } else {
                result.error(e.getMessage(), e.toString(), null);
            }
        }
    }

    public File getVideoCacheDir(Context context, String url) {
        return new File(new File(context.getExternalCacheDir(), "video-cache"), generate(url));
    }

    public String generate(String url) {
        String extension = getExtension(url);
        String name = ProxyCacheUtils.computeMD5(url);
        return TextUtils.isEmpty(extension) ? name : name + "." + extension;
    }

    private String getExtension(String url) {
        int dotIndex = url.lastIndexOf('.');
        int slashIndex = url.lastIndexOf('/');
        return dotIndex != -1 && dotIndex > slashIndex && dotIndex + 2 + 4 > url.length() ?
                url.substring(dotIndex + 1, url.length()) : "";
    }

    private void presentPicker(MethodCall call) {
        final HashMap<String, String> options = call.argument(arg_androidOptions);
        int albumId = 0;
        if (call.argument(arg_albumId) != null) {
            albumId = call.argument(arg_albumId);
        }
        boolean albumDetail = false;
        if (call.argument(arg_album_detail) != null) {
            albumDetail = call.argument(arg_album_detail);
        }

        int maxImages = call.argument(arg_maxImages);
        String thumb = call.argument(arg_thumb);
        ArrayList<String> selectMedias = call.argument(arg_selectedAssets);
        selectMedias = selectMedias == null ? new ArrayList<String>() : selectMedias;
        String defaultAsset = call.argument(arg_defaultAsset);
        defaultAsset = TextUtils.isEmpty(defaultAsset) ? "" : defaultAsset;

        String selectType = call.argument(arg_mediaSelectTypes);
        selectType = TextUtils.isEmpty(selectType) ? "" : selectType;
        String doneButtonText = call.argument(arg_doneButtonText);
        doneButtonText = TextUtils.isEmpty(doneButtonText) ? "" : doneButtonText;

        String showMediaType = call.argument(arg_mediaShowTypes);
        showMediaType = TextUtils.isEmpty(showMediaType) ? "all" : showMediaType;

        String actionBarTitle = options.get("actionBarTitle");
        String allViewTitle = options.get("allViewTitle");
        String selectCircleStrokeColor = options.get("selectCircleStrokeColor");
        String selectionLimitReachedText = options.get("selectionLimitReachedText");
        String textOnNothingSelected = options.get("textOnNothingSelected");
        String backButtonDrawable = options.get("backButtonDrawable");
        String okButtonDrawable = options.get("okButtonDrawable");

        Long videoCanPickLimitSize = -1l;
        if (options.get("videoCanPickLimitSize") != null) {
            videoCanPickLimitSize = Long.parseLong(options.get("videoCanPickLimitSize"));
        }
        Long videoCanPickLimitDuration = -1l;
        if (options.get("videoCanPickLimitDuration") != null) {
            videoCanPickLimitDuration = Long.parseLong(options.get("videoCanPickLimitDuration"));
        }
        Long imageCanPickLimitSize = -1l;
        if (options.get("imageCanPickLimitSize") != null) {
            imageCanPickLimitSize = Long.parseLong(options.get("imageCanPickLimitSize"));
        }
        Long imageCanPickLimitPixel = -1l;
        if (options.get("imageCanPickLimitPixel") != null) {
            imageCanPickLimitPixel = Long.parseLong(options.get("imageCanPickLimitPixel"));
        }
        Long imageCanPickLimitSide = -1l;
        if (options.get("imageCanPickLimitSide") != null) {
            imageCanPickLimitSide = Long.parseLong(options.get("imageCanPickLimitSide"));
        }

        FishBunCreator fishBunCreator = FishBun.with(MultiImagePickerPlugin.this.activity)
                .setImageAdapter(new GlideHelper())
                .setMaxCount(maxImages)
                .setThumb(thumb.equalsIgnoreCase("thumb"))
                .setHiddenThumb(thumb.equalsIgnoreCase("file"))
                .setPreSelectMedia(defaultAsset)
                .setPreSelectMedias(selectMedias)
                .setShowMediaType(showMediaType)
                .setSelectType(selectType)
                .setDoneButtonText(doneButtonText);

        if (selectType.equals(Fishton.MEDIA_SELECT_TYPE_IMAGE)) {//目前业务flutter传递选择类型为image时就屏蔽拍摄tab，只保留选择页面
            fishBunCreator.setOnlySelectMode(true);
            fishBunCreator.setSelectTabShowType(Fishton.SELECT_TAB_SHOW_TYPE_IMAGE);
        } else {
            fishBunCreator.setOnlySelectMode(false);
            fishBunCreator.setSelectTabShowType(Fishton.SELECT_TAB_SHOW_TYPE_BOTH);
        }

        if (!textOnNothingSelected.isEmpty()) {
            fishBunCreator.textOnNothingSelected(textOnNothingSelected);
        }

        if (!backButtonDrawable.isEmpty()) {
            int id = context.getResources().getIdentifier(backButtonDrawable, "drawable", context.getPackageName());
            fishBunCreator.setHomeAsUpIndicatorDrawable(ContextCompat.getDrawable(context, id));
        }

        if (!okButtonDrawable.isEmpty()) {
            int id = context.getResources().getIdentifier(okButtonDrawable, "drawable", context.getPackageName());
            fishBunCreator.setDoneButtonDrawable(ContextCompat.getDrawable(context, id));
        }

        if (actionBarTitle != null && !actionBarTitle.isEmpty()) {
            fishBunCreator.setActionBarTitle(actionBarTitle);
        }

        if (selectionLimitReachedText != null && !selectionLimitReachedText.isEmpty()) {
            fishBunCreator.textOnImagesSelectionLimitReached(selectionLimitReachedText);
        }

        if (selectCircleStrokeColor != null && !selectCircleStrokeColor.isEmpty()) {
            fishBunCreator.setSelectCircleStrokeColor(Color.parseColor(selectCircleStrokeColor));
        }

        if (allViewTitle != null && !allViewTitle.isEmpty()) {
            fishBunCreator.setAllViewTitle(allViewTitle);
        }
        if (videoCanPickLimitDuration > 0) {
            fishBunCreator.setVideoCanPickLimitDuration(videoCanPickLimitDuration);
        }
        if (videoCanPickLimitSize > 0) {
            fishBunCreator.setVideoCanPickLimitSize(videoCanPickLimitSize);
        }
        if (imageCanPickLimitSize > 0) {
            fishBunCreator.setImageCanPickLimitSize(imageCanPickLimitSize);
        }
        if (imageCanPickLimitPixel > 0) {
            fishBunCreator.setImageCanPickLimitPixel(imageCanPickLimitPixel);
        }
        if (imageCanPickLimitSide > 0) {
            fishBunCreator.setImageCanPickLimitSide(imageCanPickLimitSide);
        }
        fishBunCreator.setRequestCode(requestcode_pick_media);
        fishBunCreator.startAlbum(AlbumType.DEFAULT, null, albumId, albumDetail);
    }

    @Override
    public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
        try {
            switch (requestCode) {
                case requestcode_pick_media: {
                    if (resultCode == Activity.RESULT_OK) {
                        if (currentResult != null) {
                            Serializable result = data.getSerializableExtra(intent_param_result);
                            currentResult.success(result != null ? result : new HashMap());
                        }
                    } else if (resultCode == Activity.RESULT_CANCELED) {
                        if (currentResult != null) {
                            ArrayList result = data != null ? data.getParcelableArrayListExtra(intent_param_result) : new ArrayList();
                            Boolean thumb = data != null ? data.getBooleanExtra(intent_param_thumb, true) : true;
                            HashMap<String, Object> hashMap = new HashMap<>();
                            hashMap.put("assets", result);
                            hashMap.put("thumb", thumb);
                            currentResult.error("CANCELLED", "", hashMap);
                            currentResult = null;
                        }
                    } else {
                        if (currentResult != null)
                            currentResult.error("result code error", "result code:" + resultCode, null);
                    }
                    break;
                }
                default: {
                    if (currentResult != null)
                        currentResult.error("request code error", "requset code:" + requestCode, null);
                    break;
                }
            }
        } catch (Exception e) {
            if (currentResult != null) currentResult.error("exception error", e.toString(), null);
        }
        currentResult = null;
        return true;
    }

    boolean checkPermission(boolean checkCamera, boolean checkRecord, boolean checkStorage) {
        PermissionCheck permissionCheck = new PermissionCheck(activity);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            boolean result = true;
            if (checkCamera) result = result && permissionCheck.CheckCameraPermission();
            if (checkRecord) result = result && permissionCheck.CheckRecordAudioPermission();
            if (checkStorage) result = result && permissionCheck.CheckStoragePermission();
            return result;
        } else {
            return true;
        }
    }
}