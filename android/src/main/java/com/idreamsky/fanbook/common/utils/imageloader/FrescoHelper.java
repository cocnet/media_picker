package com.idreamsky.fanbook.common.utils.imageloader;

import android.graphics.Bitmap;
import android.graphics.drawable.Animatable;
import android.net.Uri;

import com.facebook.drawee.backends.pipeline.Fresco;
import com.facebook.drawee.controller.BaseControllerListener;
import com.facebook.drawee.interfaces.DraweeController;
import com.facebook.drawee.view.SimpleDraweeView;
import com.facebook.imagepipeline.common.ImageDecodeOptions;
import com.facebook.imagepipeline.common.ResizeOptions;
import com.facebook.imagepipeline.image.ImageInfo;
import com.facebook.imagepipeline.request.ImageRequestBuilder;
import com.idreamsky.fanbook.common.utils.Logger;
import com.idreamsky.multi_image_picker.R;
import com.sangcomz.fishbun.bean.Media;

public class FrescoHelper {

    public static void loadImage(final SimpleDraweeView imageView, final Media media) {
        loadImage(imageView,media.getOriginPath());   
    }
    
    public static void loadImage(final SimpleDraweeView imageView, final String path) {
        if (path == null || "".equals(path)) return;
        
        int viewWidth = imageView.getWidth();
        int viewHeight = imageView.getHeight();
        if (viewWidth <= 0) {
            viewWidth = 256;
        }
        if (viewHeight <= 0) {
            viewHeight = 256;
        }
//        Logger.d("view大小：" + viewWidth + "/" + viewHeight);
        ImageDecodeOptions options = ImageDecodeOptions.newBuilder()
                .setBitmapConfig(Bitmap.Config.RGB_565)
                .build();
        ImageRequestBuilder builder  = ImageRequestBuilder.newBuilderWithSource(Uri.parse((path.startsWith("/") ? "file://" : "") + path));
        builder.setResizeOptions(new ResizeOptions(viewWidth, viewHeight));
        builder.setImageDecodeOptions(options);

        DraweeController controller = Fresco.newDraweeControllerBuilder()
                .setImageRequest(builder.build())
                .setTapToRetryEnabled(true)
                .setAutoPlayAnimations(true)
//                .setOldController(imageView.getController())
                .setControllerListener(new BaseControllerListener<ImageInfo>() {
                    @Override
                    public void onFailure(String id, Throwable throwable) {
                        super.onFailure(id, throwable);
                        Logger.e("FrescoHelper onFailure:" + path);
                        throwable.printStackTrace();
                        imageView.setImageResource(R.drawable.ic_photo_error_16dp);
                    }

                    @Override
                    public void onFinalImageSet(String id, ImageInfo imageInfo, Animatable animatable) {
                        super.onFinalImageSet(id, imageInfo, animatable);
//                        Logger.d("图片加载完成：" + imageInfo.getWidth() + "/" + imageInfo.getHeight());
                    }
                })
                .build();
        imageView.setController(controller);
    }
}
