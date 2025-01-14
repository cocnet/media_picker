package com.sangcomz.fishbun

import android.app.Activity
import android.content.Context
import android.content.Intent
import androidx.fragment.app.Fragment
import com.idreamsky.fanbook.common.utils.imageloader.GlideHelper
import java.lang.ref.WeakReference

class FishBun private constructor(activity: Activity?, fragment: Fragment?) {

    private val _activity: WeakReference<Activity?> = WeakReference(activity)
    private val _fragment: WeakReference<Fragment?> = WeakReference(fragment)

    val fishBunContext: FishBunContext get() = FishBunContext()

    fun setImageAdapter(imageAdapter: GlideHelper): FishBunCreator {
        val fishton = Fishton.getInstance().apply {
            refresh()
            this.imageAdapter = imageAdapter
        }
        return FishBunCreator(this, fishton)
    }

    companion object {
        @JvmStatic
        fun with(activity: Activity) = FishBun(activity, null)

        @JvmStatic
        fun with(fragment: Fragment) = FishBun(null, fragment)

//        @JvmStatic
//        fun startDefault(fragment: Fragment, albumType: AlbumType) {
//            val activity = fragment.activity ?: return;
//            val fishBun = with(fragment)
//                .setImageAdapter(GlideAdapter())
//                .setMaxCount(9)
//                .setThumb(false)
//                .setHiddenThumb(true)
//                .setPreSelectMedia("")
//                .setRequestCode(1001)
//                .setShowMediaType("all")
//                .setSelectType("selectAll")
//                .setDoneButtonText("下一步");
//            val actionBarTitle = "";
//            val allViewTitle = "All Photos";
//            val selectCircleStrokeColor = "#ff198CFE";
//            val selectionLimitReachedText = "";
//            val textOnNothingSelected = "";
//            val backButtonDrawable = "";
//            val okButtonDrawable = "";
//            if (!textOnNothingSelected.isEmpty()) {
//                fishBun.textOnNothingSelected(textOnNothingSelected);
//            }
//            if (!backButtonDrawable.isEmpty()) {
//                val id = activity.getResources().getIdentifier(
//                    backButtonDrawable,
//                    "drawable",
//                    activity.getPackageName()
//                );
//                fishBun.setHomeAsUpIndicatorDrawable(ContextCompat.getDrawable(activity, id));
//            }
//            if (!okButtonDrawable.isEmpty()) {
//                val id = activity.getResources().getIdentifier(
//                    okButtonDrawable,
//                    "drawable",
//                    activity.getPackageName()
//                );
//                fishBun.setDoneButtonDrawable(ContextCompat.getDrawable(activity, id));
//            }
//            if (actionBarTitle != null && !actionBarTitle.isEmpty()) {
//                fishBun.setActionBarTitle(actionBarTitle);
//            }
//            if (selectionLimitReachedText != null && !selectionLimitReachedText.isEmpty()) {
//                fishBun.textOnImagesSelectionLimitReached(selectionLimitReachedText);
//            }
//            if (selectCircleStrokeColor != null && !selectCircleStrokeColor.isEmpty()) {
//                fishBun.setSelectCircleStrokeColor(Color.parseColor(selectCircleStrokeColor));
//            }
//            if (allViewTitle != null && !allViewTitle.isEmpty()) {
//                fishBun.setAllViewTitle(allViewTitle);
//            }
//            fishBun.startAlbum(albumType);
//        }
    }

    inner class FishBunContext {
        private val activity = _activity.get()
        private val fragment = _fragment.get()
        fun getContext(): Context =
            activity ?: fragment?.context ?: throw NullPointerException("Activity or Fragment Null")

        fun startActivityForResult(intent: Intent, requestCode: Int) {
            when {
                activity != null -> activity.startActivityForResult(intent, requestCode)
                fragment != null -> fragment.startActivityForResult(intent, requestCode)
                else -> throw NullPointerException("Activity or Fragment Null")
            }
        }
    }
}


