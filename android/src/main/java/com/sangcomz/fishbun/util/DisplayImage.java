package com.sangcomz.fishbun.util;

import android.content.ContentResolver;
import android.content.Context;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.media.ExifInterface;
import android.media.MediaMetadataRetriever;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.provider.MediaStore;
import android.text.TextUtils;

import com.idreamsky.fanbook.common.utils.Logger;
import com.sangcomz.fishbun.Fishton;
import com.sangcomz.fishbun.bean.Media;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Iterator;

/**
 * 查询本地媒体数据库
 */
public class DisplayImage {
    //分页Size
    public static final int pageSize = 100;

    /**
     * 查询本地媒体数据库的回调接口
     */
    public interface DisplayImageListener {
        void OnDisplayImageDidSelectFinish(QueryResult qr);
    }

    private Long bucketId;
    private ContentResolver resolver;
    private String expectType;
    private DisplayImageListener listener;
    private MediaMetadataRetriever retriever = new MediaMetadataRetriever();

    private Context context;
    private int limit = -1;
    private int offset = -1;
    private ArrayList<String> selectMedias = new ArrayList<>();
    private boolean requestHashMap = false;
    private boolean isInvertedPhotos = false;
    private boolean requestVideoDimen = false;
    private boolean fetchSpecialPhotos = false;

    public void setLimit(int limit) {
        this.limit = limit;
    }

    public void setOffset(int offset) {
        this.offset = offset;
    }

    public void setRequestVideoDimen(boolean requestVideoDimen) {
        this.requestVideoDimen = requestVideoDimen;
    }

    public void setRequestHashMap(boolean requestHashMap) {
        this.requestHashMap = requestHashMap;
    }

    public void setListener(DisplayImageListener listener) {
        this.listener = listener;
    }

    public void setInvertedPhotos(boolean invertedPhotos) {
        isInvertedPhotos = invertedPhotos;
    }

    public DisplayImage(Long bucketId, ArrayList<String> selectMedias, String expectType, Context context) {
        this.bucketId = bucketId;
        this.selectMedias = selectMedias;
        this.expectType = expectType;
        this.resolver = context.getContentResolver();
        this.context = context;
        this.fetchSpecialPhotos = selectMedias != null && !selectMedias.isEmpty();
    }

    public void execute() {
        output.clear();
        new Thread(new Runnable() {
            @Override
            public void run() {
                final QueryResult result = getAllMediaThumbnailsPath(bucketId, -1, false);
                if (Looper.myLooper() != Looper.getMainLooper()) {
                    Handler mainThread = new Handler(Looper.getMainLooper());
                    mainThread.post(new Runnable() {
                        @Override
                        public void run() {
                            if (listener != null) {
                                listener.OnDisplayImageDidSelectFinish(result);
                            }
                        }
                    });
                } else {
                    if (listener != null) {
                        listener.OnDisplayImageDidSelectFinish(result);
                    }
                }
            }
        }).start();
    }

    /**
     * 分页查询
     * curOffset: -1 不分页；大于-1 分页
     */
    public void executePageQuery(final int curOffset, final boolean switchBucket) {
        Logger.d("executePageQuery - curOffset: " + curOffset + " switchBucket:" + switchBucket);
        if (!workThreads.isEmpty()) {
            return;
        }
        output.clear();
        new Thread(new Runnable() {
            @Override
            public void run() {
                final QueryResult qr = getAllMediaThumbnailsPath(bucketId, curOffset, switchBucket);
                if (Looper.myLooper() != Looper.getMainLooper()) {
                    Handler mainThread = new Handler(Looper.getMainLooper());
                    mainThread.post(new Runnable() {
                        @Override
                        public void run() {
                            if (listener != null) {
                                listener.OnDisplayImageDidSelectFinish(qr);
                            }
                        }
                    });
                } else {
                    if (listener != null) {
                        listener.OnDisplayImageDidSelectFinish(qr);
                    }
                }
            }
        }).start();
    }

    private QueryResult getAllMediaThumbnailsPath(long id, int curOffset, boolean switchBucket) {
        String bucketId = String.valueOf(id);
        Cursor c;
        Uri mediaUri = MediaStore.Files.getContentUri("external");
        String selection;
        if (expectType.equalsIgnoreCase("image")) {
            selection = "(" + MediaStore.Files.FileColumns.MEDIA_TYPE + "="
                    + MediaStore.Files.FileColumns.MEDIA_TYPE_IMAGE + ")";
        } else if (expectType.equalsIgnoreCase("video")) {
            selection = "(" + MediaStore.Files.FileColumns.MEDIA_TYPE + "="
                    + MediaStore.Files.FileColumns.MEDIA_TYPE_VIDEO + ")";
        } else {
            selection = "(" + MediaStore.Files.FileColumns.MEDIA_TYPE + "="
                    + MediaStore.Files.FileColumns.MEDIA_TYPE_IMAGE
                    + " OR "
                    + MediaStore.Files.FileColumns.MEDIA_TYPE + "="
                    + MediaStore.Files.FileColumns.MEDIA_TYPE_VIDEO + ")";
        }

        if (!"0".equals(bucketId))
            selection = selection + " AND " + MediaStore.MediaColumns.BUCKET_ID + " = " + bucketId;
        if (fetchSpecialPhotos)
            selection = selection + " AND " + MediaStore.MediaColumns._ID + " in (" + TextUtils.join(",", selectMedias) + ")";

        Logger.d("getAllMediaThumbnailsPath curOffset: " + curOffset + " limit:" + limit + " SDK_INT: " + Build.VERSION.SDK_INT + " offset:" + offset);

        if (Build.VERSION.SDK_INT > Build.VERSION_CODES.Q/*29*/) {
            final Bundle bundle = new Bundle();
            bundle.putString(ContentResolver.QUERY_ARG_SQL_SELECTION, selection);
            bundle.putStringArray(ContentResolver.QUERY_ARG_SQL_SELECTION_ARGS, new String[]{});
            bundle.putStringArray(ContentResolver.QUERY_ARG_SORT_COLUMNS, new String[]{MediaStore.Files.FileColumns.DATE_MODIFIED});
            bundle.putInt(ContentResolver.QUERY_ARG_SORT_DIRECTION, ContentResolver.QUERY_SORT_DIRECTION_DESCENDING);
            if (limit >= 0) bundle.putInt(ContentResolver.QUERY_ARG_LIMIT, limit);
            if (curOffset >= 0) {
                bundle.putInt(ContentResolver.QUERY_ARG_OFFSET, curOffset);
            } else if (offset >= 0) {
                bundle.putInt(ContentResolver.QUERY_ARG_OFFSET, offset);
            }
            try {
                c = resolver.query(mediaUri, null, bundle, null);
            } catch (Exception e) {
                e.printStackTrace();
                return new QueryResult(new ArrayList(), 0, switchBucket);
            }
        } else {
            String sort = MediaStore.Files.FileColumns.DATE_MODIFIED + " DESC ";
            if (limit >= 0 && curOffset >= 0) {
                sort = sort + " LIMIT " + limit + " OFFSET " + curOffset;
            } else if (limit >= 0 && offset >= 0) {
                sort = sort + " LIMIT " + limit + " OFFSET " + offset;
            }
            try {
                c = resolver.query(mediaUri, null, selection, null, sort);
            } catch (Exception e) {
                e.printStackTrace();
                return new QueryResult(new ArrayList(), 0, switchBucket);
            }
        }
        ArrayList medias = new ArrayList<>();
        int queryCount = 0;
        if (c != null) {
            try {
                queryCount = c.getCount();
                if (c.moveToFirst()) {
                    int MIME_TYPE = c.getColumnIndex(MediaStore.Files.FileColumns.MIME_TYPE);
                    int BUCKET_DISPLAY_NAME = c.getColumnIndex(MediaStore.Files.FileColumns.BUCKET_DISPLAY_NAME);
                    int DATA = c.getColumnIndex(MediaStore.Files.FileColumns.DATA);
                    int DISPLAY_NAME = c.getColumnIndex(MediaStore.Files.FileColumns.DISPLAY_NAME);
                    int WIDTH = c.getColumnIndex(MediaStore.Files.FileColumns.WIDTH);
                    int HEIGHT = c.getColumnIndex(MediaStore.Files.FileColumns.HEIGHT);
                    int FILESIZE = c.getColumnIndex(MediaStore.Files.FileColumns.SIZE);
                    int _ID = c.getColumnIndex(MediaStore.Files.FileColumns._ID);

                    String bucketName = c.getString(BUCKET_DISPLAY_NAME);
                    int index = 0;
                    do {
                        try {
                            String mimeType = c.getString(MIME_TYPE);
                            long fileSize = c.getLong(FILESIZE);
                            if (mimeType.contains("image") && fileSize > 1024 * 1024 * 100)
                                continue;
                            String imgId = c.getString(_ID);
                            String filePath = c.getString(DATA);
                            String displayName = c.getString(DISPLAY_NAME);
                            float width = 0;
                            float height = 0;
                            //过滤掉svg格式图片
                            if (filePath != null && filePath.toLowerCase().endsWith("svg")) {
                                continue;
                            }
                            try {
                                width = c.getFloat(WIDTH);
                                height = c.getFloat(HEIGHT);
                            } catch (Exception e) {
                                e.printStackTrace();
                            }
                            paramTransferQuene(index, imgId, bucketId, bucketName, filePath, mimeType, height, width, displayName, fileSize);
                            index++;
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    } while (c.moveToNext());

                    do {
                        Iterator<Thread> iterable = workThreads.iterator();
                        while (iterable.hasNext()) {
                            if (iterable.next().getState() == Thread.State.TERMINATED) {
                                iterable.remove();
                            }
                        }
                        if (workThreads.size() == 0) {
                            break;
                        } else {
                            Thread.sleep(10);
                        }
                    } while (true);

                    medias = sortOutput();
                }
            } catch (Exception e) {
                e.printStackTrace();
            } finally {
                if (!c.isClosed()) c.close();
            }
        }
        return new QueryResult(medias, queryCount, switchBucket);
    }

    private ArrayList<Thread> workThreads = new ArrayList<>();
    private HashMap<Integer, Object> output = new HashMap();

    private synchronized void addOutputResult(int index, Object object) {
        output.put(index, object);
    }

    private void paramTransferQuene(final int index, final String imgId, final String bucketId, final String bucketName, final String filePath, final String mimeType, final float height, final float width, final String displayName, final long fileSize) {
        if (workThreads.size() >= 10) {
            do {
                Iterator<Thread> iterable = workThreads.iterator();
                while (iterable.hasNext()) {
                    if (iterable.next().getState() == Thread.State.TERMINATED) {
                        iterable.remove();
                    }
                }
                if (Build.VERSION.SDK_INT >= 33) {
                    try {
                        Thread.sleep(1);
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
                if (workThreads.size() < 10) {
                    break;
                }
            } while (true);
        }
        Thread thread = new Thread(new Runnable() {
            @Override
            public void run() {
                if (requestHashMap) {
                    HashMap hashMap = addMedia(imgId, filePath, mimeType, height, width, displayName, fileSize);
                    if (hashMap != null) addOutputResult(index, hashMap);
                } else {
                    Media media = addMedia(imgId, bucketId, bucketName, filePath, mimeType, height, width, displayName, fileSize);
                    if (media != null) addOutputResult(index, media);
                }
            }
        });
        workThreads.add(thread);
        thread.start();
    }

    private ArrayList sortOutput() {
        ArrayList result = new ArrayList();
        Integer[] keysArray = output.keySet().toArray(new Integer[0]);
        Arrays.sort(keysArray);
        if (isInvertedPhotos) {
            for (int i = keysArray.length - 1; i >= 0; i--) {
                Object object = output.get(keysArray[i]);
                if (object != null) result.add(object);
            }
        } else {
            for (int i = 0; i < keysArray.length; i++) {
                Object object = output.get(keysArray[i]);
                if (object != null) result.add(object);
            }
        }
        return result;
    }

    private Media addMedia(String imgId, String bucketId, String bucketName, String filePath, String mimeType, float height, float width, String displayName, long fileSize) {
        Media media = new Media();
        media.setFileType(mimeType);
        media.setBucketId(bucketId);
        media.setBucketName(bucketName);
        media.setOriginName(displayName);
        media.setOriginPath(filePath);
        if (media.getFileType().contains(Fishton.MEDIA_FILE_TYPE_VIDEO)) {
            Uri uri = Uri.withAppendedPath(MediaStore.Video.Media.EXTERNAL_CONTENT_URI, imgId);
            Cursor cursor = context.getContentResolver().query(uri, null, null, null, null);
            if (cursor.moveToFirst()) {
                media.setDuration(cursor.getInt(cursor.getColumnIndex(MediaStore.Video.VideoColumns.DURATION)) / 1000 + "");
            } else {
                media.setDuration("0");
            }
            cursor.close();
        } else {
            media.setOriginHeight(height + "");
            media.setOriginWidth(width + "");
            media.setDuration("0");
        }
        media.setIdentifier(imgId);
        media.setMimeType(mimeType);
        media.setFileSize(fileSize + "");
        media.setMediaId(imgId);
        return media;
    }

    private HashMap addMedia(String imgId, String filePath, String mimeType, float height, float width, String displayName, long fileSize) {
        HashMap media = new HashMap();
        try {
            media.put("identifier", imgId);
            media.put("filePath", filePath);
            if (mimeType.contains("video")) {
                if (requestVideoDimen) {
                    retriever.setDataSource(filePath);
                    Bitmap bitmap = retriever.getFrameAtTime(0);
                    media.put("width", bitmap.getWidth() * 1.0);
                    media.put("height", bitmap.getHeight() * 1.0);
                } else {
                    media.put("width", 0.0);
                    media.put("height", 0.0);
                }
                Uri uri = Uri.withAppendedPath(MediaStore.Video.Media.EXTERNAL_CONTENT_URI, imgId);
                Cursor cursor = context.getContentResolver().query(uri, null, null, null, null);
                if (cursor.moveToFirst()) {
                    media.put("duration", cursor.getFloat(cursor.getColumnIndex(MediaStore.Video.VideoColumns.DURATION)) / 1000);
                } else {
                    media.put("duration", 0.0);
                }
                cursor.close();
            } else {
                double imageWidth = width;
                double imageHeight = height;
                try {
                    BitmapFactory.Options opts = new BitmapFactory.Options();
                    opts.inJustDecodeBounds = true;
                    BitmapFactory.decodeFile(filePath, opts);
                    imageWidth = opts.outWidth > 0 ? (opts.outWidth * 1.0) : imageWidth;
                    imageHeight = opts.outHeight > 0 ? (opts.outHeight * 1.0) : imageHeight;
                } catch (Exception e) {
                    e.printStackTrace();
                }
                if (fetchSpecialPhotos && !mimeType.contains("gif")) {
                    ExifInterface ei = new ExifInterface(filePath);
                    int orientation = ei.getAttributeInt(ExifInterface.TAG_ORIENTATION,
                            ExifInterface.ORIENTATION_UNDEFINED);
                    if (orientation == ExifInterface.ORIENTATION_ROTATE_90 || orientation == ExifInterface.ORIENTATION_ROTATE_270) {
                        media.put("width", imageHeight);
                        media.put("height", imageWidth);
                    } else {
                        media.put("width", imageWidth);
                        media.put("height", imageHeight);
                    }
                } else {
                    media.put("width", imageWidth);
                    media.put("height", imageHeight);
                }
                media.put("duration", 0.0);
            }
            media.put("name", displayName);
            media.put("fileType", mimeType);
            media.put("fileSize", fileSize + "");
            media.put("thumbPath", "");
            media.put("thumbName", "");
            media.put("thumbHeight", 0.0);
            media.put("thumbWidth", 0.0);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return media;
    }
}
