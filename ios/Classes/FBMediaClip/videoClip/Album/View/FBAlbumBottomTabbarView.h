//
//  FBAlbumBottomTabbarView.h
//  FBVideoClip
//
//  Created by 杨志豪 on 3/17/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM (NSInteger,FBTakePhtoType){
    FBTakePhtoTypeAll = 0,
    FBTakePhtoTypeImage,
    FBTakePhtoTypeVideo,
};


@protocol FBAlbumBottomTabbarViewDelegate <NSObject>

- (void)showTakePhotoView:(BOOL)isImageMode;

- (void)hiddenTakePhotoView;

@end

@interface FBAlbumBottomTabbarView : UIView

@property(nonatomic,weak) id<FBAlbumBottomTabbarViewDelegate> delegate;

@property(nonatomic,assign) FBTakePhtoType type;

- (void)resetStatus;

@end

NS_ASSUME_NONNULL_END
