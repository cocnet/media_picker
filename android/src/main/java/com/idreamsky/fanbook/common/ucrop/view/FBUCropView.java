package com.idreamsky.fanbook.common.ucrop.view;

import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.RectF;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.widget.FrameLayout;

import com.idreamsky.multi_image_picker.R;
import com.idreamsky.fanbook.common.ucrop.callback.FBCropBoundsChangeListener;
import com.idreamsky.fanbook.common.ucrop.callback.FBOverlayViewChangeListener;

import androidx.annotation.NonNull;

public class FBUCropView extends FrameLayout {

    private FBGestureCropImageView mGestureCropImageView;
    private final FBOverlayView mViewOverlay;

    public FBUCropView(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public FBUCropView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);

        LayoutInflater.from(context).inflate(R.layout.fb_ucrop_view, this, true);
        mGestureCropImageView = findViewById(R.id.fb_image_view_crop);
        mViewOverlay = findViewById(R.id.fb_view_overlay);

        TypedArray a = context.obtainStyledAttributes(attrs, R.styleable.ucrop_UCropView);
        mViewOverlay.processStyledAttributes(a);
        mGestureCropImageView.processStyledAttributes(a);
        a.recycle();

        setListenersToViews();
    }

    private void setListenersToViews() {
        mGestureCropImageView.setCropBoundsChangeListener(new FBCropBoundsChangeListener() {
            @Override
            public void onCropAspectRatioChanged(float cropRatio) {
                mViewOverlay.setTargetAspectRatio(cropRatio);
            }
        });
        mViewOverlay.setOverlayViewChangeListener(new FBOverlayViewChangeListener() {
            @Override
            public void onCropRectUpdated(RectF cropRect) {
                mGestureCropImageView.setCropRect(cropRect);
            }
        });
    }

    @Override
    public boolean shouldDelayChildPressedState() {
        return false;
    }

    @NonNull
    public FBGestureCropImageView getCropImageView() {
        return mGestureCropImageView;
    }

    @NonNull
    public FBOverlayView getOverlayView() {
        return mViewOverlay;
    }

    /**
     * Method for reset state for UCropImageView such as rotation, scale, translation.
     * Be careful: this method recreate UCropImageView instance and reattach it to layout.
     */
    public void resetCropImageView() {
        removeView(mGestureCropImageView);
        mGestureCropImageView = new FBGestureCropImageView(getContext());
        setListenersToViews();
        mGestureCropImageView.setCropRect(getOverlayView().getCropViewRect());
        addView(mGestureCropImageView, 0);
    }
}