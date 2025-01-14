package com.idreamsky.fanbook.common.utils.imageloader

import android.graphics.drawable.Drawable
import android.net.Uri
import android.provider.MediaStore
import android.widget.ImageView
import com.bumptech.glide.Glide
import com.bumptech.glide.load.DataSource
import com.bumptech.glide.load.DecodeFormat
import com.bumptech.glide.load.engine.GlideException
import com.bumptech.glide.load.resource.bitmap.CenterCrop
import com.bumptech.glide.load.resource.bitmap.RoundedCorners
import com.bumptech.glide.request.RequestListener
import com.bumptech.glide.request.RequestOptions
import com.bumptech.glide.request.target.Target
import com.idreamsky.multi_image_picker.R
import com.sangcomz.fishbun.Fishton
import com.sangcomz.fishbun.bean.Media
import com.sangcomz.fishbun.util.MediaThumbData

/**
 * Created by sangcomz on 23/07/2017.
 */

class GlideHelper {
    fun loadImage(imageView: ImageView, media: Media) {
        loadImage(imageView, media, 0);
    }

    fun loadImage(imageView: ImageView, media: Media, radius: Int) {
        val options = RequestOptions().apply {
            centerCrop()
            format(DecodeFormat.PREFER_RGB_565)
            if (radius > 0) {
                transform(CenterCrop(), RoundedCorners(radius))
            }
        }
        media.setmTag(-1)
        Glide
            .with(imageView.context)
            .load(media.originPath)
            .listener(object : RequestListener<Drawable> {
                override fun onLoadFailed(
                    e: GlideException?,
                    model: Any?,
                    target: com.bumptech.glide.request.target.Target<Drawable>?,
                    isFirstResource: Boolean
                ): Boolean {
                    imageView.scaleType = ImageView.ScaleType.CENTER_INSIDE
                    imageView.setImageResource(R.drawable.ic_photo_error_16dp)
                    media.setmTag(0)
                    return true
                }

                override fun onResourceReady(
                    resource: Drawable?,
                    model: Any?,
                    target: Target<Drawable>?,
                    dataSource: DataSource?,
                    isFirstResource: Boolean
                ): Boolean {
                    media.setmTag(1);
                    return false
                }
            })
            .apply(options)
            .override(imageView.width, imageView.height)
            .thumbnail(0.25f)
            .into(imageView)
    }

    fun loadImage(imageView: ImageView, uri: Uri) {
        val options = RequestOptions().apply {
            centerCrop()
            format(DecodeFormat.PREFER_RGB_565)
        }
        Glide
            .with(imageView.context)
            .load(uri)
            .listener(object : RequestListener<Drawable> {
                override fun onLoadFailed(
                    e: GlideException?,
                    model: Any?,
                    target: com.bumptech.glide.request.target.Target<Drawable>?,
                    isFirstResource: Boolean
                ): Boolean {
                    imageView.scaleType = ImageView.ScaleType.CENTER_INSIDE
                    imageView.setImageResource(R.drawable.ic_photo_error_16dp)
                    return true
                }

                override fun onResourceReady(
                    resource: Drawable?,
                    model: Any?,
                    target: Target<Drawable>?,
                    dataSource: DataSource?,
                    isFirstResource: Boolean
                ): Boolean {
                    return false
                }
            })
            .apply(options)
            .override(imageView.width, imageView.height)
            .thumbnail(0.25f)
            .into(imageView)
    }

    fun loadDetailImage(imageView: ImageView, media: Media) {
        val options = RequestOptions().centerInside()
        media.setmTag(-1)
        val listener = object : RequestListener<Drawable> {
            override fun onLoadFailed(
                e: GlideException?,
                model: Any?,
                target: com.bumptech.glide.request.target.Target<Drawable>?,
                isFirstResource: Boolean
            ): Boolean {
                imageView.scaleType = ImageView.ScaleType.CENTER_INSIDE
                imageView.setImageResource(R.drawable.ic_photo_error_64dp)
                media.setmTag(0)
                return true
            }

            override fun onResourceReady(
                resource: Drawable?,
                model: Any?,
                target: Target<Drawable>?,
                dataSource: DataSource?,
                isFirstResource: Boolean
            ): Boolean {
                media.setmTag(1)
                return false
            }
        }
        if (media.fileType.contains(Fishton.MEDIA_FILE_TYPE_VIDEO)) {
            val mediaThumbData = MediaThumbData(media.identifier, media.fileType, false, imageView.context);
            mediaThumbData.setListener { bytes ->
                Glide.with(imageView.context).load(bytes).listener(listener).apply(options).into(imageView)
            }
            mediaThumbData.execute()
        }else {
            val imagePath = media.originPath
            Glide.with(imageView.context).load(imagePath).listener(listener).apply(options).into(imageView)
        }

    }

}
