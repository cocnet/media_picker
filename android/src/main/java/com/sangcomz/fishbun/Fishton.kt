package com.sangcomz.fishbun

import android.content.Context
import android.graphics.Color
import android.graphics.drawable.Drawable
import com.idreamsky.multi_image_picker.R
import com.idreamsky.fanbook.common.utils.imageloader.GlideHelper
import com.sangcomz.fishbun.bean.Media

/**
 * Created by seokwon.jeong on 04/01/2018.
 */
class Fishton {
    var imageAdapter: GlideHelper? = null
    var maxCount: Int = 0
    //从系统数据库中查出来的可供选择的资源列表
    var pickerMedias: List<Media> = ArrayList()
        set(value) {
            field = value
            if (preSelectedMedias.isNotEmpty()) {
                for (identifier in preSelectedMedias) {
                    val media = value.find { it.identifier == identifier }
                    if (media != null) selectedMedias.add(media)
                }
            }
        }
    //已选择资源列表
    var selectedMedias = ArrayList<Media>()
    var preSelectedMedias = ArrayList<String>()
    var preSelectedMedia = ""
    var isThumb : Boolean = true
    var hiddenThumb : Boolean = false
    
    //控制界面选择时：全选/只选视频/只选图片/选其中一种
    var selectType : String = Fishton.MEDIA_SELECT_TYPE_ALL
    //控制界面是否只显示相册选择tab，屏蔽拍摄tab
    var onlySelectMode : Boolean = false
    //控制选择界面："全部"/"视频"/"图片"三个tab全显示，或只显示其中一个
    var selectTabShowType : String = Fishton.SELECT_TAB_SHOW_TYPE_BOTH
    //控制从系统数据库查询时只查图片/视频/全部
    var showMediaType : String = ""

    var messageNothingSelected: String? = null
    var messageLimitReached: String? = null
    var titleAlbumAllView: String? = null
    var titleActionBar: String? = null
    var doneButtonText : String = ""

    var drawableHomeAsUpIndicator: Drawable? = null
    var drawableDoneButton: Drawable? = null
    var drawableThumbButton: Drawable? = null
    var drawableOriginButton: Drawable? = null
    var drawableAllDoneButton: Drawable? = null

    var colorSelectCircleStroke: Int = 0
    var colorDeSelectCircleStroke: Int = 0

    //视频大小限制
    var videoCanPickLimitSize: Long = -1
    //视频时长限制
    var videoCanPickLimitDuration: Long = -1
    //图片大小限制
    var imageCanPickLimitSize: Long = -1
    //图片像素限制
    var imageCanPickLimitPixel: Long = -1
    //图片边长限制
    var imageCanPickLimitSide: Long = -1

    init {
        init()
    }

    fun refresh() = init()

    private fun init() {
        imageAdapter = null

        //BaseParams
        maxCount = 10
        selectedMedias = ArrayList()
        preSelectedMedia = ""


        drawableHomeAsUpIndicator = null
        drawableDoneButton = null
        drawableAllDoneButton = null
        drawableOriginButton = null
        drawableThumbButton = null

        colorSelectCircleStroke = Color.parseColor("#00BA5A")
        colorDeSelectCircleStroke = Color.parseColor("#FFFFFF")

        pickerMedias = ArrayList()
        selectedMedias = ArrayList()
    }

    fun syncSortedPreSelectedMedias(selectedMediasInfo: ArrayList<Media>) {
        selectedMedias.clear()
        if (preSelectedMedias.isNotEmpty()) {
            for (identifier in preSelectedMedias) {
                val media = selectedMediasInfo.find { it.identifier == identifier }
                if (media != null) selectedMedias.add(media)
            }
        }
    }

    fun setDefaultMessage(context: Context) {
        messageNothingSelected = messageNothingSelected ?: context.getString(R.string.msg_no_selected)
        messageLimitReached = messageLimitReached ?: context.getString(R.string.msg_full_image)
        titleAlbumAllView = titleAlbumAllView ?: context.getString(R.string.str_all_view)
        titleActionBar = titleActionBar ?: context.getString(R.string.album)
    }

    fun isContainVideo(): Boolean {
        for (media in selectedMedias) {
            if (media.fileType.contains(Fishton.MEDIA_FILE_TYPE_VIDEO)) {
                return true
            }
        }
        return false
    }

    fun isContainImage(): Boolean {
        for (media in selectedMedias) {
            if (media.fileType.contains(Fishton.MEDIA_FILE_TYPE_IMAGH)) {
                return true
            }
        }
        return false
    }

    fun canAppendMedia(): Boolean {
        if (Fishton.MEDIA_SELECT_TYPE_SINGLE.equals(selectType) && isContainVideo()) {
            return false
        }else {
            return selectedMedias.count() < maxCount
        }
    }

    fun canAppendMedia(media: Media): Boolean {
        if (selectedMedias.count() >= maxCount) {
            return false
        }
        if (Fishton.MEDIA_SELECT_TYPE_VIDEO == selectType && !media.fileType.contains(Fishton.MEDIA_FILE_TYPE_VIDEO)) {
            return false
        }
        if (Fishton.MEDIA_SELECT_TYPE_IMAGE == selectType && !media.fileType.contains(Fishton.MEDIA_FILE_TYPE_IMAGH)) {
            return false
        }
        if (Fishton.MEDIA_SELECT_TYPE_SINGLE == selectType && isContainImage() && !media.fileType.contains(Fishton.MEDIA_FILE_TYPE_IMAGH)) {
            return false
        }
        if (Fishton.MEDIA_SELECT_TYPE_SINGLE == selectType && isContainVideo() && !media.fileType.contains(Fishton.MEDIA_FILE_TYPE_VIDEO)) {
            return false
        }
        return true
    }

    fun getBanReason(media: Media): String {
        var reason = "当前无法继续选择文件"
        if (selectedMedias.count() >= maxCount) {
            reason = "最多可选" + maxCount + "个素材"
        } else
        if (Fishton.MEDIA_SELECT_TYPE_VIDEO == selectType && !media.fileType.contains(Fishton.MEDIA_FILE_TYPE_VIDEO)) {
            reason = "当前仅支持视频选择"
        } else
        if (Fishton.MEDIA_SELECT_TYPE_IMAGE == selectType && !media.fileType.contains(Fishton.MEDIA_FILE_TYPE_IMAGH)) {
            reason = "当前仅支持图片选择"
        } else
        if (Fishton.MEDIA_SELECT_TYPE_SINGLE == selectType && isContainImage() && !media.fileType.contains(Fishton.MEDIA_FILE_TYPE_IMAGH)) {
            reason = "当前仅支持图片选择"
        } else
        if (Fishton.MEDIA_SELECT_TYPE_SINGLE == selectType && isContainVideo() && !media.fileType.contains(Fishton.MEDIA_FILE_TYPE_VIDEO)) {
            reason = "当前仅支持视频选择"
        }
        return reason
    }

    fun mediaIndexOfFirstPreSelectMedia(): Int {
        try {
            if (preSelectedMedia.isNotEmpty()) {
                for (i in pickerMedias.indices) {
                    if (pickerMedias[i].identifier.equals(preSelectedMedia)) {
                        return i;
                    }
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
        return 0
    }

    private object FishtonHolder {
        val INSTANCE = Fishton()
    }

    companion object {
        const val MEDIA_SELECT_TYPE_ALL : String = "selectAll";
        const val MEDIA_SELECT_TYPE_SINGLE : String = "selectSingleType";
        const val MEDIA_SELECT_TYPE_IMAGE : String = "selectImage";
        const val MEDIA_SELECT_TYPE_VIDEO : String = "selectVideo";

        const val MEDIA_FILE_TYPE_IMAGH : String = "image";
        const val MEDIA_FILE_TYPE_VIDEO : String = "video";
        const val MEDIA_FILE_TYPE_GIF : String = "gif";

        const val SELECT_TAB_SHOW_TYPE_BOTH : String = "both";
        const val SELECT_TAB_SHOW_TYPE_ALL : String = "onlyAll";
        const val SELECT_TAB_SHOW_TYPE_IMAGE : String = "onlyImage";
        const val SELECT_TAB_SHOW_TYPE_VIDEO : String = "oblyVideo";
        
        @JvmStatic
        fun getInstance() = FishtonHolder.INSTANCE
    }
}