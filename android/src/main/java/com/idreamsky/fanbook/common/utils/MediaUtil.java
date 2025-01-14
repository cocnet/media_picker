package com.idreamsky.fanbook.common.utils;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.media.ExifInterface;
import android.view.View;

import com.sangcomz.fishbun.Fishton;
import com.sangcomz.fishbun.bean.Media;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;


public class MediaUtil {

    /// 判断是不是纯图片集合
    public static boolean isImageTypeMediaCollection(ArrayList<Media> mediaList) {
        for (Media media : mediaList) {
            if (!media.getFileType().contains(Fishton.MEDIA_FILE_TYPE_IMAGH)) {
                return false;
            }
        }
        return true;
    }

    public static boolean isVideoTypeMedia(Media media) {
        return media != null && media.getFileType().contains(Fishton.MEDIA_FILE_TYPE_VIDEO);
    }

    public static ArrayList<String> getMediaPathCollection(ArrayList<Media> mediaList) {
        ArrayList<String> paths = new ArrayList<>();
        for (Media media : mediaList) {
            String path = media.getScalePath() != null ? media.getScalePath() : media.getOriginPath();
            if (path != null && !path.isEmpty()) {
                paths.add(path);
            }
        }
        return paths;
    }

    public static List<Media> getImageMedias(List<Media> mediaList) {
        List<Media> imageList = new ArrayList<>();
        if (mediaList != null && mediaList.size() > 0) {
            for (int i = 0; i < mediaList.size(); i++) {
                if (mediaList.get(i).getFileType().contains(Fishton.MEDIA_FILE_TYPE_IMAGH)) {
                    imageList.add(mediaList.get(i));
                }
            }
        }
        return imageList;
    }

    public static List<Media> getVideoMedias(List<Media> mediaList) {
        List<Media> videoList = new ArrayList<>();
        if (mediaList != null && mediaList.size() > 0) {
            for (int i = 0; i < mediaList.size(); i++) {
                if (mediaList.get(i).getFileType().contains(Fishton.MEDIA_FILE_TYPE_VIDEO)) {
                    videoList.add(mediaList.get(i));
                }
            }
        }
        return videoList;
    }


    public static boolean imageSizeOutOfBounds(int width, int height) {
        return width > max_size || height > max_size;
    }

    //编辑后：最大的宽高，大于它就缩放
    public static final int max_size = 3840;

    /**
     * 检查当前图片列表中是否有超长图或超宽图，并对其进行缩放
     */
    public static void cropInvalidateImage(ArrayList<Media> selectedList) {
        for (int i = 0; i < selectedList.size(); i++) {
            // 1. 先从media判断size是否在正常范围内
            Media imageMedia = selectedList.get(i);
            String originWidthString = imageMedia.getOriginWidth();
            String originHeightString = imageMedia.getOriginHeight();
            String originImagePath = imageMedia.getOriginPath();
            Logger.d("当前Media对象记录的宽高信息：" + originWidthString + "/" + originHeightString + " - " + originImagePath);
            double originWidth;
            double originHeight;
            try {
                originWidth = Double.parseDouble(originWidthString == null ? "0.0" : originWidthString);
                originHeight = Double.parseDouble(originHeightString == null ? "0.0" : originHeightString);
                if (!imageSizeOutOfBounds((int) originWidth, (int) originHeight)) {
                    continue;
                }
            } catch (Exception e) {
                Logger.e(e.getMessage());
            }

            // 2. 通过bitmap仅获取size的方法判断是否在正常范围内(这个步骤防止第一步的宽高不正确)
            BitmapFactory.Options optionsToSize = new BitmapFactory.Options();
            optionsToSize.inJustDecodeBounds = true;
            BitmapFactory.decodeFile(originImagePath, optionsToSize);
            Logger.d("当前Bitmap读取到的宽高信息：" + optionsToSize.outWidth + "/" + optionsToSize.outHeight);
            if (!imageSizeOutOfBounds(optionsToSize.outWidth, optionsToSize.outHeight)) {
                continue;
            }

            // 3. 通过bitmap来缩放
            Bitmap originBitmap = BitmapFactory.decodeFile(originImagePath);
            if (originBitmap == null) {
                continue;
            }

            int width = originBitmap.getWidth();
            int height = originBitmap.getHeight();

            if (width > max_size || height > max_size) {
                String cropImageName = "croped_" + imageMedia.getIdentifier() + ".jpg";
                String cropImagePath = FilePathManager.PATH_USER_CROPED_IMAGE + cropImageName;
                Logger.d("图片宽高需要进行调整，即将缩放图片，新图片地址为：" + cropImagePath);
                String orientation = getOrientation(new File(originImagePath));
                if (!"".equals(orientation)) {
                    Logger.d("读取当前图片方向成功：" + orientation);
                }

                File cropFile = new File(cropImagePath);
                if (!cropFile.exists()) {
                    Logger.d("不存在已缩放的图片，准备生成");
                    Bitmap cropBitmap = ImageUtil.scaleBitmap(originBitmap, max_size);
                    if (cropBitmap == null) {
                        Logger.e("生成新图片失败！原始图片：" + originImagePath);
                        continue;
                    } else {
                        Logger.d("生成新图片成功！宽高为：" + cropBitmap.getWidth() + "/" + cropBitmap.getHeight());
                    }

                    boolean result = ImageUtil.saveBitmapToSD(cropBitmap, cropImagePath);
                    if (result) {
                        imageMedia.setScalePath(cropImagePath);
                        Logger.d("保存图片到SD卡成功，设置media对象的图片路径为：" + cropImagePath);
                        if (!"".equals(orientation) && !"1".equals(orientation)) {
                            Logger.d("当前图片有旋转参数，准备重新设置回旋转方向 " + orientation);
                            setOrientation(new File(cropImagePath), orientation);
                        }
                    } else {
                        Logger.d("图片保存失败！");
                    }
                } else {
                    Logger.d("裁剪后图片已存在，直接使用");
                    imageMedia.setScalePath(cropImagePath);
                }

            } else {
                Logger.d("图片尺寸不超出，直接使用");
            }
        }
    }

    /**
     * 获取图片exif信息中的方向标记
     */
    private static String getOrientation(File file) {
        Logger.d("准备读取图片方向信息 " + file.getAbsolutePath());
        String orientation = "";
        try {
            if (file != null && file.isFile() && file.exists() && android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.Q) {
                ExifInterface info = new ExifInterface(file);
                if (info != null) {
                    orientation = info.getAttribute(ExifInterface.TAG_ORIENTATION);
                    Logger.d("获取当前图片 " + file.getName() + " 方向属性成功 = " + orientation);
                }
            }
        } catch (IOException e) {
            Logger.d("获取当前图片 " + file.getName() + " 方向属性异常");
            e.printStackTrace();
            return orientation;
        }
        return orientation;
    }

    private static void setOrientation(File file, String orientation) {
        Logger.d("准备设置图片方向信息为 " + orientation + " 图片：" + file.getAbsolutePath());
        try {
            if (file != null && file.isFile() && file.exists() && android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.Q) {
                ExifInterface info = new ExifInterface(file);
                if (info != null) {
                    info.setAttribute(ExifInterface.TAG_ORIENTATION, orientation);
                    info.saveAttributes();
                }
            }
        } catch (IOException e) {
            Logger.d("设置当前图片 " + file.getName() + " 方向属性异常");
            e.printStackTrace();
        }
    }

    /**
     * 检查视频大小的限制，超出则并提示
     */
    public static boolean checkVideoLimitSize(Media media, View view) {
        try {
            if (!media.getFileType().contains(Fishton.MEDIA_FILE_TYPE_VIDEO)) return true;

            Long videoCanPickLimitSize = Fishton.getInstance().getVideoCanPickLimitSize();
            if (videoCanPickLimitSize > 0 && (Long.parseLong(media.getFileSize()) > videoCanPickLimitSize)) {
                long max = videoCanPickLimitSize / 1024;
                String sizeDesc = max + "KB";
                if (max >= 1024 * 1024) {
                    sizeDesc = max / 1024 / 1024 + "GB";
                }else if (max >= 1024) {
                    sizeDesc = max / 1024 + "MB";
                }
                ToastUtil.showToast(view.getContext(), "只能选择" + sizeDesc +"以内的视频哦");
                return false;
            }

            Long videoCanPickLimitDuration = Fishton.getInstance().getVideoCanPickLimitDuration();
            if (videoCanPickLimitDuration > 0 && (Long.parseLong(media.getDuration())) > videoCanPickLimitDuration) {
                String sizeDesc = videoCanPickLimitDuration + "秒";
                if (videoCanPickLimitDuration >= 60 * 60) {
                    sizeDesc = videoCanPickLimitDuration / 60 / 60 + "小时";
                }else if (videoCanPickLimitDuration >= 60) {
                    sizeDesc = videoCanPickLimitDuration / 60 + "分钟";
                }
                ToastUtil.showToast(view.getContext(), "只能选择" + sizeDesc +"以内的视频哦");
                return false;
            }
        } catch (Exception e) {
            Logger.d("checkVideoLimitSize " + e.getMessage());
            e.printStackTrace();
        }
        return true;
    }

    /**
     * 检查图片大小和像素的限制，超出则并提示
     */
    public static boolean checkImageLimitSize(Media media, View view) {
        try {
            if (!media.getFileType().contains(Fishton.MEDIA_FILE_TYPE_IMAGH)) return true;

            Long imageCanPickLimitSize = Fishton.getInstance().getImageCanPickLimitSize();
            Long imageCanPickLimitPixel = Fishton.getInstance().getImageCanPickLimitPixel();
            Long imageCanPickLimitSide = Fishton.getInstance().getImageCanPickLimitSide();
            Long maxSize = imageCanPickLimitSize / 1024 / 1024;
            String maxSizeDesc = maxSize >= 1024 ? (maxSize / 1024) + "GB" :  maxSize + "MB";
            if (imageCanPickLimitSize > 0 && (Long.parseLong(media.getFileSize()) > imageCanPickLimitSize)) {
                if (view != null) ToastUtil.showToast(view.getContext(), "只能选择" + maxSizeDesc + "以内的图片哦");
                return false;
            }
            double width = (media.getOriginWidth() != null) ? Double.parseDouble(media.getOriginWidth()) : 0;
            double height = (media.getOriginHeight() != null) ? Double.parseDouble(media.getOriginHeight()) : 0;
            if (imageCanPickLimitPixel > 0 && ((width * height) > imageCanPickLimitPixel)) {
                String desc = "" + imageCanPickLimitPixel;
                if (imageCanPickLimitPixel >= 10000 * 10000) {
                    desc = imageCanPickLimitPixel / 10000 / 10000 + "亿";
                }else if (imageCanPickLimitPixel >= 10000) {
                    desc = imageCanPickLimitPixel / 10000 + "万";
                }

                if (view != null) ToastUtil.showToast(view.getContext(), "只能选择" + desc +"像素以内的图片哦");
                return false;
            }
            if (imageCanPickLimitSide > 0 && (width > imageCanPickLimitSide || height > imageCanPickLimitSide)) {
                if (view != null) ToastUtil.showToast(view.getContext(), "只能选择边长小于" + imageCanPickLimitSide +"的图片哦");
                return false;
            }
        } catch (Exception e) {
            Logger.d("checkImageLimitSize " + e.getMessage());
            e.printStackTrace();
        }
        return true;
    }

}
