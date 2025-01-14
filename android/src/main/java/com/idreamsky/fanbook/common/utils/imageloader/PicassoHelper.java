package com.idreamsky.fanbook.common.utils.imageloader;

import android.graphics.Bitmap;
import android.widget.ImageView;

import com.idreamsky.multi_image_picker.R;
import com.sangcomz.fishbun.bean.Media;
import com.squareup.picasso.Picasso;

import jp.wasabeef.picasso.transformations.RoundedCornersTransformation;

public class PicassoHelper {
    
    public static final String TAG = "tag";

    public static void loadImage(final ImageView imageView, Media media) {
        load(imageView,media.getOriginPath(),0);
    }

    public static void loadImage(final ImageView imageView, String path) {
        load(imageView,path,0);
    }

    public static void loadImageWithCorner(final ImageView imageView, String path,int cornerRadius) {
        load(imageView,path,cornerRadius);
    }
    
    public static void loadImageResWithCorner(final ImageView imageView, int res,int cornerRadius) {
        
        Picasso.get()
                .load(res)
//                .resize(viewWidth,viewHeight)
//                .centerCrop()
                .transform(new RoundedCornersTransformation(cornerRadius,1, RoundedCornersTransformation.CornerType.ALL))
                .placeholder(res)
                .into(imageView);
    }
    
    private static void load(final ImageView imageView, String path, int cornerRadius) {
        if (path == null || "".equals(path)) return;
        
        int viewWidth = imageView.getWidth();
        int viewHeight = imageView.getHeight();
        if (viewWidth <= 0) {
            viewWidth = 256;
        }
        if (viewHeight <= 0) {
            viewHeight = 256;
        }
        viewWidth = Math.min(200, viewWidth);
        viewHeight= Math.min(200, viewHeight);
//        Logger.d("view大小：" + viewWidth + "/" + viewHeight);
        Picasso.get()
                .load((path.startsWith("/") ? "file://" : "") + path)
                .resize(viewWidth,viewHeight)
                .onlyScaleDown()
                .centerCrop()
                .tag(PicassoHelper.TAG)
                .error(R.drawable.ic_photo_error_16dp)
//                .memoryPolicy(MemoryPolicy.NO_CACHE,MemoryPolicy.NO_STORE)
                .noFade()
//                .noPlaceholder()
                .placeholder(android.R.color.transparent)
                .config(Bitmap.Config.RGB_565)
                .transform(new RoundedCornersTransformation(cornerRadius,1, RoundedCornersTransformation.CornerType.ALL))
                .into(imageView);
        
        
    }
}
