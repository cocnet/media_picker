package com.idreamsky.fanbook.common.utils;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Matrix;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.VectorDrawable;

import androidx.annotation.DrawableRes;
import androidx.core.content.ContextCompat;
import androidx.vectordrawable.graphics.drawable.VectorDrawableCompat;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;


public class ImageUtil {
    private static final String TAG = "ImageUtil";

    public static boolean saveBitmap(Bitmap bitmap, String dstPath) {
        if (bitmap == null || dstPath == null || dstPath.isEmpty()) {
            return false;
        }
        File file = new File(dstPath);
        try {
            FileOutputStream out = new FileOutputStream(file);
            bitmap.compress(Bitmap.CompressFormat.JPEG, 100, out);
            out.flush();
            out.close();
            return true;
        } catch (IOException e) {
            e.printStackTrace();
        }
        return false;
    }

    public static Bitmap getBitmapFromDrawable(Context context, @DrawableRes int drawableId, int size) {
        Drawable drawable = ContextCompat.getDrawable(context, drawableId);

        if (drawable instanceof BitmapDrawable) {
            Bitmap bitmap = ((BitmapDrawable) drawable).getBitmap();
            return Bitmap.createScaledBitmap(bitmap, size, size, true);

        } else if (drawable instanceof VectorDrawable || drawable instanceof VectorDrawableCompat) {
            Bitmap bitmap = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888);
            Canvas canvas = new Canvas(bitmap);
            drawable.setBounds(0, 0, size, size);
            drawable.draw(canvas);

            return bitmap;
        } else {
            throw new IllegalArgumentException("unsupported drawable type");
        }
    }

    public static Bitmap centerSquareScaleBitmap(Bitmap bitmap, int size) {
        if (null == bitmap || size <= 0) {
            return null;
        }

        Bitmap result = bitmap;
        int widthOrg = bitmap.getWidth();
        int heightOrg = bitmap.getHeight();
        Logger.d(TAG, "centerSquareScaleBitmap: " + widthOrg + " " + heightOrg);

        int minSizeOrg = Math.min(widthOrg, heightOrg);
        int clipSize = Math.min(minSizeOrg, size);

//        if (widthOrg > clipSize && heightOrg > clipSize) {
        /*
         * 压缩到一个最小长度是edgeLength的bitmap
         * Compressed to a bitmap with a minimum length of edgeLength
         * */
        float wRemainder = widthOrg / (float) clipSize;
        float hRemainder = heightOrg / (float) clipSize;

        int scaledWidth;
        int scaledHeight;
        if (wRemainder > hRemainder) {
            scaledWidth = (int) (widthOrg / hRemainder);
            scaledHeight = (int) (heightOrg / hRemainder);
        } else {
            scaledWidth = (int) (widthOrg / wRemainder);
            scaledHeight = (int) (heightOrg / wRemainder);
        }

        Bitmap scaledBitmap;
        try {
            scaledBitmap = Bitmap.createScaledBitmap(bitmap, scaledWidth, scaledHeight, true);
        } catch (Exception e) {
            return null;
        }

        /*
         * 从图中截取正中间的部分。
         * Take the middle part from the figure.
         * */
        int xTopLeft = (scaledWidth - clipSize) / 2;
        int yTopLeft = (scaledHeight - clipSize) / 2;

        try {
            result = Bitmap.createBitmap(scaledBitmap, xTopLeft, yTopLeft, clipSize, clipSize);
            scaledBitmap.recycle();
        } catch (Exception e) {
            return null;
        }
//        }

        return result;
    }

    public static Bitmap centerCropBitmap(Bitmap bitmap, int width, int height) {
        if (bitmap == null || width <= 0 || height <= 0) return null;
        int newWidth = width;
        int newHeight = height;
        int originWidth = bitmap.getWidth();
        int originHeight = bitmap.getHeight();
        if (newWidth > originWidth) {
            newWidth = originWidth;
        }
        if (newHeight > originHeight) {
            newHeight = originHeight;
        }

        int xTopLeft = (originWidth - newWidth) / 2;
        int yTopLeft = (originHeight - newHeight) / 2;

        Bitmap result;
        try {
            result = Bitmap.createBitmap(bitmap, xTopLeft, yTopLeft, newWidth, newHeight);
//            bitmap.recycle();
        } catch (Exception e) {
            return null;
        }
        return result;

    }

    /**
     * 缩放图片尺寸(宽或搞)到规定的大小
     * originWidth originHeight: 原始尺寸
     * finalMaxSize：最终的最大尺寸
     */
    public static Bitmap scaleBitmapByOrigin(Bitmap bitmap, int originWidth, int originHeight, int finalMaxSize) {
        int width = bitmap.getWidth();
        int height = bitmap.getHeight();
        int modifyMaxSize = Math.max(width, height);
        int originMaxSize = Math.max(originWidth, originHeight);
        float scaleW = ((float) finalMaxSize) / width;
        float scaleH = ((float) finalMaxSize) / height;
        float scaleOriginW = ((float) originWidth) / width;
        float scaleOriginH = ((float) originHeight) / height;

//        Logger.d("getChat scale -- modifyMaxSize:" + modifyMaxSize + " originMaxSize:" + originMaxSize);
        float radio = 1;
        if (modifyMaxSize > finalMaxSize) {
            //缩小
            if (originMaxSize > finalMaxSize) {
                radio = Math.min(scaleW, scaleH);
            } else if (originMaxSize <= finalMaxSize) {
                radio = Math.min(scaleOriginW, scaleOriginH);
            }
        } else if (modifyMaxSize < finalMaxSize) {
            //放大或还原
            if (originMaxSize > finalMaxSize) {
                radio = Math.min(scaleW, scaleH);
            } else if (originMaxSize <= finalMaxSize) {
                radio = Math.min(scaleOriginW, scaleOriginH);
            }
        }
        Logger.d("getChat radio -- radio:" + radio);
        if (radio <= 0) {
            radio = 1;
        }
        Matrix matrix = new Matrix();
        matrix.postScale(radio, radio);
        return Bitmap.createBitmap(bitmap, 0, 0, width, height, matrix, true);
    }

    /**
     * 缩放图片尺寸(宽或搞)到规定的大小
     */
    public static Bitmap scaleBitmap(Bitmap bitmap, int maxSize) {
        int width = bitmap.getWidth();
        int height = bitmap.getHeight();
        float scaleW = ((float) maxSize) / width;
        float scaleH = ((float) maxSize) / height;
        //取宽高最小比例来缩放图片
        float min = Math.min(scaleW, scaleH);
        Matrix matrix = new Matrix();
        matrix.postScale(min, min);
        return Bitmap.createBitmap(bitmap, 0, 0, width, height, matrix, true);
    }

    /**
     * 将bitmap保存到SD卡
     * ca
     * Save bitmap to SD card
     */
    public static boolean saveBitmapToSD(Bitmap bt, String target_path) {
        if (bt == null || target_path == null || target_path.isEmpty()) {
            return false;
        }
        File file = new File(target_path);
        file.getParentFile().mkdirs();
        if (file.exists()) file.delete();
        try {
            file.createNewFile();
            FileOutputStream out = new FileOutputStream(file);
            bt.compress(Bitmap.CompressFormat.JPEG, 100, out);
            out.flush();
            out.close();
            return true;
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
        return false;
    }

    //获取图片真实的宽高
    public static int[] getImageSize(String imagePath) {
        try {
            BitmapFactory.Options options = new BitmapFactory.Options();
            options.inJustDecodeBounds = true;
            BitmapFactory.decodeFile(imagePath, options);
            return new int[]{options.outWidth, options.outHeight};
        } catch (Exception e) {
            return null;
        }
    }

}

