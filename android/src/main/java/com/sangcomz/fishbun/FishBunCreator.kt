package com.sangcomz.fishbun

import android.app.Activity
import android.content.Intent
import android.graphics.Color
import android.graphics.drawable.Drawable
import com.idreamsky.fanbook.common.utils.imageloader.GlideHelper

enum class AlbumType {
    DEFAULT, // 之前的做法
}

/**
 * Created by sangcomz on 17/05/2017.
 */
class FishBunCreator(private val fishBun: FishBun, private val fishton: Fishton) {
    private var requestCode = 27

    fun setThumb(thumb: Boolean): FishBunCreator = this.apply {
        fishton.isThumb = thumb;
    }

    fun setHiddenThumb(hiddenThumb: Boolean): FishBunCreator = this.apply {
        fishton.hiddenThumb = hiddenThumb;
    }

    fun setPreSelectMedias(preSelectMedias: ArrayList<String>): FishBunCreator = this.apply {
        fishton.preSelectedMedias = preSelectMedias
    }

    fun setPreSelectMedia(preSelectMedia: String): FishBunCreator = this.apply {
        fishton.preSelectedMedia = preSelectMedia
    }

    fun setMaxCount(count: Int): FishBunCreator = this.apply {
        fishton.maxCount = if (count <= 0) 1 else count
    }

    fun setRequestCode(requestCode: Int): FishBunCreator = this.apply {
        this.requestCode = requestCode
    }

    fun textOnNothingSelected(message: String?): FishBunCreator = this.apply {
        fishton.messageNothingSelected = message
    }

    fun textOnImagesSelectionLimitReached(message: String?): FishBunCreator = this.apply {
        fishton.messageLimitReached = message
    }

    fun setAllViewTitle(allViewTitle: String?): FishBunCreator = this.apply {
        fishton.titleAlbumAllView = allViewTitle
    }

    fun setActionBarTitle(actionBarTitle: String?): FishBunCreator = this.apply {
        fishton.titleActionBar = actionBarTitle
    }

    fun setHomeAsUpIndicatorDrawable(icon: Drawable?): FishBunCreator = this.apply {
        fishton.drawableHomeAsUpIndicator = icon
    }

    fun setDoneButtonDrawable(icon: Drawable?): FishBunCreator = this.apply {
        fishton.drawableDoneButton = icon
    }

    fun setAllDoneButtonDrawable(icon: Drawable?): FishBunCreator = this.apply {
        fishton.drawableAllDoneButton = icon
    }

    fun setSelectType(selectType: String) = this.apply {
        fishton.selectType = selectType
    }

    fun setSelectTabShowType(type: String) = this.apply {
        fishton.selectTabShowType = type
    }

    fun setOnlySelectMode(isOnlySelectMode: Boolean) = this.apply {
        fishton.onlySelectMode = isOnlySelectMode;
    }

    fun setShowMediaType(showMediaType: String) = this.apply {
        fishton.showMediaType = showMediaType
    }

    fun setDoneButtonText(doneButtonText: String) = this.apply {
        fishton.doneButtonText = doneButtonText
    }

    fun setSelectCircleStrokeColor(strokeColor: Int): FishBunCreator = this.apply {
        fishton.colorSelectCircleStroke = strokeColor
    }

    fun setVideoCanPickLimitSize(videoCanPickLimitSize: Long): FishBunCreator = this.apply {
        fishton.videoCanPickLimitSize = videoCanPickLimitSize
    }

    fun setVideoCanPickLimitDuration(videoCanPickLimitDuration: Long): FishBunCreator = this.apply {
        fishton.videoCanPickLimitDuration = videoCanPickLimitDuration
    }

    fun setImageCanPickLimitSize(imageCanPickLimitSize: Long): FishBunCreator = this.apply {
        fishton.imageCanPickLimitSize = imageCanPickLimitSize
    }

    fun setImageCanPickLimitPixel(imageCanPickLimitPixel: Long): FishBunCreator = this.apply {
        fishton.imageCanPickLimitPixel = imageCanPickLimitPixel
    }

    fun setImageCanPickLimitSide(imageCanPickLimitSide: Long): FishBunCreator = this.apply {
        fishton.imageCanPickLimitSide = imageCanPickLimitSide
    }

    fun clearSelectedMedia() = this.apply {
        fishton.selectedMedias.clear()
    }

    fun startAlbum(albumType: AlbumType, activity: Activity? = null) {
        startAlbum(albumType, activity, 0, false);
    }

    fun startAlbum(
        albumType: AlbumType,
        activity: Activity? = null,
        albumId: Long,
        albumDetail: Boolean = false
    ) {
//        val fishBunContext = fishBun.fishBunContext
//        val context = fishBunContext.getContext()
//        if (fishton.imageAdapter == null) throw NullPointerException("ImageAdapter is Null")
//        fishton.setDefaultMessage(context)
//
//        val intent: Intent
//
//        intent = Intent(context, PickerActivity::class.java)
//        intent.putExtra(
//            MultiImagePickerPlugin.intent_param_album,
//            Album(0, fishton.titleAlbumAllView, null, 0)
//        )
//        intent.putExtra(MultiImagePickerPlugin.intent_param_position, 0)
//
//        fishBunContext.startActivityForResult(intent, requestCode)
    }

    companion object {
        fun generateDefaultFishBunCreator(activity: Activity): FishBunCreator {
            val maxImages = 9
            val thumb = "origin"
            val defaultAsset = ""
            val selectType = "selectAll"
            val doneButtonText = "下一步"
            val showMediaType = "all"
            val allViewTitle = "所有图片"
            val selectCircleStrokeColor = "#ff198cfe"

            val fishBunCreator = FishBun.with(activity)
                .setImageAdapter(GlideHelper())
                .setMaxCount(maxImages)
                .setThumb(thumb.equals("thumb", ignoreCase = true))
                .setHiddenThumb(thumb.equals("file", ignoreCase = true))
                .setPreSelectMedia(defaultAsset)
                .setShowMediaType(showMediaType)
                .setSelectType(selectType)
                .setDoneButtonText(doneButtonText);


            if (selectCircleStrokeColor.isNotEmpty()) {
                fishBunCreator.setSelectCircleStrokeColor(Color.parseColor(selectCircleStrokeColor));
            }
            if (allViewTitle.isNotEmpty()) {
                fishBunCreator.setAllViewTitle(allViewTitle);
            }
            return fishBunCreator
        }
    }

}
