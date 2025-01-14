package com.sangcomz.fishbun.bean;

import android.os.Parcel;
import android.os.Parcelable;

import java.util.HashMap;

public class Album implements Parcelable {

    final public long bucketId;
    final public String bucketName;
    public int counter;
    public String thumbnailPath;

    public String thumbIdentifier;

    public Album(long bucketId, String bucketName, String thumbnailPath, int counter) {
        this.bucketId = bucketId;
        this.bucketName = bucketName;
        this.counter = counter;
        this.thumbnailPath = thumbnailPath;
    }

    public Album(long bucketId, String bucketName, String thumbnailPath, int counter, String thumbIdentifier) {
        this.bucketId = bucketId;
        this.bucketName = bucketName;
        this.counter = counter;
        this.thumbnailPath = thumbnailPath;
        this.thumbIdentifier = thumbIdentifier;
    }

    protected Album(Parcel in) {
        bucketId = in.readLong();
        bucketName = in.readString();
        counter = in.readInt();
        thumbnailPath = in.readString();
    }

    public HashMap<String, Object> toMap() {
        HashMap<String, Object> map = new HashMap<>();
        map.put("albumId", bucketId);
        map.put("albumName", bucketName);
        map.put("count", counter);
        map.put("thumbPath", thumbnailPath);
        map.put("thumbIdentifier", thumbIdentifier);
        return map;
    }

    public static final Creator<Album> CREATOR = new Creator<Album>() {
        @Override
        public Album createFromParcel(Parcel in) {
            return new Album(in);
        }

        @Override
        public Album[] newArray(int size) {
            return new Album[size];
        }
    };

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel parcel, int i) {
        parcel.writeLong(bucketId);
        parcel.writeString(bucketName);
        parcel.writeInt(counter);
        parcel.writeString(thumbnailPath);
    }
}