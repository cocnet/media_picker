package com.idreamsky.fanbook.common.utils;

import android.content.ContentResolver;
import android.content.Context;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.provider.MediaStore;
import android.text.TextUtils;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;

public class FileUtils {

    public static String fileCacheDir(Context context) {
        return context.getCacheDir() + "/media_editor";
    }

    public static String getFilePath(Context context, String fileName) {
        String path = null;
        File dataDir = context.getApplicationContext().getExternalFilesDir(null);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            dataDir = context.getApplicationContext().getFilesDir();
        }
        if (dataDir != null) {
            path = dataDir.getAbsolutePath() + File.separator + fileName;
        }
        return path;
    }

    public static String getExternalFilePath(Context context, String fileName) {
        File compileDir = new File(Environment.getExternalStorageDirectory(), fileName);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            compileDir = context.getApplicationContext().getExternalFilesDir(fileName);
        }
        if (!compileDir.exists() && !compileDir.mkdirs()) {
            Logger.d("TAG", "Failed to make Compile directory");
            return null;
        }
        return compileDir.getAbsolutePath();
    }

    /**
     * content路径转绝对路径
     *
     * @param contentResolver
     * @param path
     * @return
     */
    public static String contentPath2AbsPath(ContentResolver contentResolver, String path) {
        Uri uri = Uri.parse(path);
        return getFilePathFromContentUri(uri, contentResolver);
    }


    public static String getFilePathFromContentUri(Uri selectedVideoUri,
                                                   ContentResolver contentResolver) {
        String filePath;
        String[] filePathColumn = {MediaStore.MediaColumns.DATA};

        Cursor cursor = contentResolver.query(selectedVideoUri, filePathColumn, null, null, null);
        cursor.moveToFirst();

        int columnIndex = cursor.getColumnIndex(filePathColumn[0]);
        filePath = cursor.getString(columnIndex);
        cursor.close();
        return filePath;

    }

    public static boolean isContent(String url) {
        if (TextUtils.isEmpty(url)) {
            return false;
        }
        return url.startsWith("content://");
    }


    public static void JPG2PNG(String path) {
        Bitmap bitmap = openImage(path);
        savePNG_After(bitmap, path);
    }

    /**
     * 将本地图片转成Bitmap
     *
     * @param path 已有图片的路径
     * @return
     */
    private static Bitmap openImage(String path) {
        Bitmap bitmap = null;
        try {
            //1.无压缩
            BufferedInputStream bis = new BufferedInputStream(new FileInputStream(path));
            bitmap = BitmapFactory.decodeStream(bis);

            //2.压缩
//            BitmapFactory.Options options = new BitmapFactory.Options();
//
//            options.inPreferredConfig = Bitmap.Config.RGB_565;
//
//            options.inSampleSize = 2;
//
//            bitmap = BitmapFactory.decodeFile(path,options);

            bis.close();
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
        return bitmap;

    }

    public static String bitmapSavePath(Context context, String suffix) {
        String fileName = "fanbook_" + System.currentTimeMillis() + "." + suffix;
        return fileCacheDir(context) + "/" + fileName;
    }

    public static String saveBitmap(Bitmap bitmap, String filePath) {
        if (bitmap == null) return null;
        if (filePath == null || filePath.isEmpty()) return null;
        File file = new File(filePath);
        file.getParentFile().mkdirs();
        boolean ret = ImageUtil.saveBitmapToSD(bitmap, filePath);
        if (ret) {
            return filePath;
        } else {
            if (file.exists()) file.delete();
            return null;
        }
    }

    private static void savePNG_After(Bitmap bitmap, String name) {
        name = name.replace("jpg", "png");
        File file = new File(name);
        try {
            FileOutputStream out = new FileOutputStream(file);
            //质量压缩，不改变bitmap大小，只牵涉到磁盘文件大小。100表示不压缩
            if (bitmap.compress(Bitmap.CompressFormat.PNG, 100, out)) {
                out.flush();
                out.close();
            }
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    /// ContentUri转AbsPath
    public static String getAbsPathByContentUri(Context context, String filePath) {
        String absPath = filePath;
        if (FileUtils.isContent(filePath) && context != null) {
            absPath = FileUtils.contentPath2AbsPath(context.getContentResolver(), filePath);
        }
        return absPath;
    }

    /// ContentUri转AbsPath 带是否生效控制
    public static String getAbsPathByContentUri(Context context, boolean applyFlag, String filePath) {
        if (!applyFlag || context == null) return filePath;
        return getAbsPathByContentUri(context, filePath);
    }

    /// 删除文件
    public static boolean deleteFile(String filePath) {
        boolean status;
        SecurityManager checker = new SecurityManager();
        File file = new File(filePath);
        if (file.exists()) {
            checker.checkDelete(file.toString());
            if (file.isFile()) {
                try {
                    file.delete();
                    status = true;
                } catch (SecurityException se) {
                    se.printStackTrace();
                    status = false;
                }
            } else
                status = false;
        } else
            status = false;
        return status;
    }

    /// 判断指定文件是否存在
    public static boolean fileIsExists(String filePath) {
        try {
            File file = new File(filePath);
            return file.exists();
        } catch (Exception e) {
            return false;
        }
    }

    /// 将文件转成byte数组
    public static byte[] assetsFile2Bytes(String filePath) {
        byte[] result = new byte[0];
        if (filePath == null || filePath.isEmpty()) return result;
        try {
            FileInputStream fileInputStream = new FileInputStream(filePath);
            BufferedInputStream buf = new BufferedInputStream(fileInputStream);
            int len = buf.available();
            byte[] bytes = new byte[len];
            buf.read(bytes, 0, bytes.length);
            buf.close();
            return bytes;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }

    /**
     * 将文件从filePath 复制到 targetFile
     */
    public static boolean copyFile(String filePath, String targetFile) {
        if (filePath == null || filePath.isEmpty() || targetFile == null || targetFile.isEmpty())
            return false;
        try {
            int index = targetFile.lastIndexOf(File.separator);
            File directory = new File(targetFile.substring(0, index + 1));
            if (!directory.exists()) directory.mkdirs();

            FileInputStream fileInputStream = new FileInputStream(filePath);
            FileOutputStream fileOutputStream = new FileOutputStream(targetFile);
            byte[] buffer = new byte[1024 * 1024];
            int len;
            while ((len = fileInputStream.read(buffer)) != -1) {
                fileOutputStream.write(buffer, 0, len);
            }
            fileInputStream.close();
            fileOutputStream.close();
//            Logger.d("getChat copyFile filePath：" + filePath);
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
        return true;
    }
}
