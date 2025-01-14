//
//  DownloadStatus.h
//  Pods
//
//  Created by amzwin on 2022/4/25.
//

#ifndef DownloadStatus_h
#define DownloadStatus_h

typedef NS_ENUM (NSInteger,DownloadState){
    NODownload,
    DownloadError,
    Downloading,
    Finish,
    Update,
    NoUser,
};

#endif /* DownloadStatus_h */
