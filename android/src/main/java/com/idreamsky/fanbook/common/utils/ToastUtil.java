package com.idreamsky.fanbook.common.utils;

import android.content.Context;
import android.view.Gravity;
import android.view.View;
import android.widget.TextView;
import android.widget.Toast;

import com.idreamsky.multi_image_picker.R;


public class ToastUtil {

    public static void showToast(Context context, String msg) {
        Toast toast = new Toast(context);
        View layout = View.inflate(context, R.layout.view_toast, null);
        TextView mTextView = layout.findViewById(R.id.tv_toast_text);
        mTextView.setText(msg);
        toast.setView(layout);
        toast.setGravity(Gravity.CENTER, 0, 0);
        toast.setDuration(Toast.LENGTH_SHORT);
        toast.show();
    }
}
