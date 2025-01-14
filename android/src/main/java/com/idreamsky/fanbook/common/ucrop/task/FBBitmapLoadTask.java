package com.idreamsky.fanbook.common.ucrop.task;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Matrix;
import android.net.Uri;
import android.os.AsyncTask;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.idreamsky.fanbook.common.utils.FileUtils;
import com.idreamsky.fanbook.common.ucrop.util.FBBitmapLoadUtils;
import com.idreamsky.fanbook.common.utils.Logger;
import com.yalantis.ucrop.callback.BitmapLoadCallback;
import com.yalantis.ucrop.model.ExifInfo;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

/**
 * Creates and returns a Bitmap for a given Uri(String url).
 * inSampleSize is calculated based on requiredWidth property. However can be adjusted if OOM occurs.
 * If any EXIF config is found - bitmap is transformed properly.
 */
public class FBBitmapLoadTask extends AsyncTask<Void, Void, FBBitmapLoadTask.BitmapWorkerResult> {

    private static final String TAG = "BitmapWorkerTask";

    private static final int MAX_BITMAP_SIZE = 100 * 1024 * 1024;   // 100 MB

    private final Context mContext;
    private Bitmap mBitmap;
    private Uri mInputUri;
    private Uri mOutputUri;
    private final int mRequiredWidth;
    private final int mRequiredHeight;

    private final BitmapLoadCallback mBitmapLoadCallback;

    public static class BitmapWorkerResult {

        Bitmap mBitmapResult;
        ExifInfo mExifInfo;
        Exception mBitmapWorkerException;

        public BitmapWorkerResult(@NonNull Bitmap bitmapResult, @NonNull ExifInfo exifInfo) {
            mBitmapResult = bitmapResult;
            mExifInfo = exifInfo;
        }

        public BitmapWorkerResult(@NonNull Exception bitmapWorkerException) {
            mBitmapWorkerException = bitmapWorkerException;
        }

    }

    public FBBitmapLoadTask(Context context, Uri inputUri, Uri outputUri,
                            Bitmap bitmap, int requiredWidth, int requiredHeight,
                            BitmapLoadCallback loadCallback) {
        mContext = context;
        mInputUri = inputUri != null ? inputUri : Uri.fromFile(new File(FileUtils.bitmapSavePath(mContext, "jpg")));
        mOutputUri = outputUri != null ? outputUri : Uri.fromFile(new File(FileUtils.bitmapSavePath(mContext, "jpg")));;
        mRequiredWidth = requiredWidth;
        mRequiredHeight = requiredHeight;
        mBitmapLoadCallback = loadCallback;
        mBitmap = bitmap;
    }

    @Override
    @NonNull
    protected BitmapWorkerResult doInBackground(Void... params) {
        Bitmap decodeSampledBitmap = null;
        if (mBitmap != null) {
            FileUtils.saveBitmap(mBitmap, mInputUri.getPath());
            decodeSampledBitmap = mBitmap;
        }else if (mInputUri != null) {
            try {
                processInputUri();
            } catch (NullPointerException | IOException e) {
                return new BitmapWorkerResult(e);
            }

            final BitmapFactory.Options options = new BitmapFactory.Options();
            options.inJustDecodeBounds = true;
            options.inSampleSize = FBBitmapLoadUtils.calculateInSampleSize(options, mRequiredWidth, mRequiredHeight);
            options.inJustDecodeBounds = false;
            boolean decodeAttemptSuccess = false;
            while (!decodeAttemptSuccess) {
                try {
                    InputStream stream = mContext.getContentResolver().openInputStream(mInputUri);
                    try {
                        decodeSampledBitmap = BitmapFactory.decodeStream(stream, null, options);
                        if (options.outWidth == -1 || options.outHeight == -1) {
                            return new BitmapWorkerResult(new IllegalArgumentException("Bounds for bitmap could not be retrieved from the Uri: [" + mInputUri + "]"));
                        }
                    } finally {
                        FBBitmapLoadUtils.close(stream);
                    }
                    if (checkSize(decodeSampledBitmap, options)) continue;
                    decodeAttemptSuccess = true;
                } catch (OutOfMemoryError error) {
                    Logger.e(TAG, "doInBackground: BitmapFactory.decodeFileDescriptor: ", error);
                    options.inSampleSize *= 2;
                } catch (IOException e) {
                    Logger.e(TAG, "doInBackground: ImageDecoder.createSource: ", e);
                    return new BitmapWorkerResult(new IllegalArgumentException("Bitmap could not be decoded from the Uri: [" + mInputUri + "]", e));
                }
            }
            if (decodeSampledBitmap == null) {
                return new BitmapWorkerResult(new IllegalArgumentException("Bitmap could not be decoded from the Uri: [" + mInputUri + "]"));
            }
        }else {
            return new BitmapWorkerResult(new NullPointerException("Input Uri cannot be null"));
        }

        int exifOrientation = FBBitmapLoadUtils.getExifOrientation(mContext, mInputUri);
        int exifDegrees = FBBitmapLoadUtils.exifToDegrees(exifOrientation);
        int exifTranslation = FBBitmapLoadUtils.exifToTranslation(exifOrientation);

        ExifInfo exifInfo = new ExifInfo(exifOrientation, exifDegrees, exifTranslation);
        Matrix matrix = new Matrix();
        if (exifDegrees != 0) {
            matrix.preRotate(exifDegrees);
        }
        if (exifTranslation != 1) {
            matrix.postScale(exifTranslation, 1);
        }
        if (!matrix.isIdentity()) {
            return new BitmapWorkerResult(FBBitmapLoadUtils.transformBitmap(decodeSampledBitmap, matrix), exifInfo);
        }

        return new BitmapWorkerResult(decodeSampledBitmap, exifInfo);
    }

    private void processInputUri() throws NullPointerException, IOException {
        String inputUriScheme = mInputUri.getScheme();
        Logger.d(TAG, "Uri scheme: " + inputUriScheme);
        if ("content".equals(inputUriScheme)) {
            try {
                copyFile(mInputUri, mOutputUri);
            } catch (NullPointerException | IOException e) {
                Logger.e(TAG, "Copying failed", e);
                throw e;
            }
        } else if (!"file".equals(inputUriScheme)) {
            Logger.e(TAG, "Invalid Uri scheme " + inputUriScheme);
            throw new IllegalArgumentException("Invalid Uri scheme" + inputUriScheme);
        }
    }

    private void copyFile(Uri inputUri, @Nullable Uri outputUri) throws NullPointerException, IOException {
        Logger.d(TAG, "copyFile");

        if (outputUri == null) {
            throw new NullPointerException("Output Uri is null - cannot copy image");
        }

        InputStream inputStream = null;
        OutputStream outputStream = null;
        try {
            inputStream = mContext.getContentResolver().openInputStream(inputUri);
            outputStream = new FileOutputStream(new File(outputUri.getPath()));
            if (inputStream == null) {
                throw new NullPointerException("InputStream for given input Uri is null");
            }

            byte buffer[] = new byte[1024];
            int length;
            while ((length = inputStream.read(buffer)) > 0) {
                outputStream.write(buffer, 0, length);
            }
        } finally {
            FBBitmapLoadUtils.close(outputStream);
            FBBitmapLoadUtils.close(inputStream);
            mInputUri = mOutputUri;
        }
    }

    @Override
    protected void onPostExecute(@NonNull BitmapWorkerResult result) {
        if (result.mBitmapWorkerException == null) {
            mBitmapLoadCallback.onBitmapLoaded(result.mBitmapResult, result.mExifInfo, mInputUri, mOutputUri);
        } else {
            mBitmapLoadCallback.onFailure(result.mBitmapWorkerException);
        }
    }

    private boolean checkSize(Bitmap bitmap, BitmapFactory.Options options) {
        int bitmapSize = bitmap != null ? bitmap.getByteCount() : 0;
        if (bitmapSize > MAX_BITMAP_SIZE) {
            options.inSampleSize *= 2;
            return true;
        }
        return false;
    }
}