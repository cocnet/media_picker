//
//  FBSelectAssetsPreviewVew.h
//  FBVideoClip
//
//  Created by amzwin on 2022/3/18.
//

#import <UIKit/UIKit.h>
//#import "TZAssetModel.h"
#import "TZImagePickerController.h"
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN
@class FBSelectAssetsPreviewVew;

@protocol FBSelectAssetsPreviewVewDelegate <NSObject>

//exchangeObjectAtIndex:sourceIndexPath.item withObjectAtIndex:destinationIndexPath.item
-(void)updateAlbumDataSource:(FBSelectAssetsPreviewVew*)view fromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;
-(void)deleteItem:(FBSelectAssetsPreviewVew*)view model:(PHAsset*)model;
-(void)didAllowPickingOriginalPhoto:(FBSelectAssetsPreviewVew*)view isSelected:(BOOL)isSelected;
-(void)nextStep:(FBSelectAssetsPreviewVew*)view;
-(void)createVideoOneStep:(FBSelectAssetsPreviewVew*)view;
-(void)previewItem:(FBSelectAssetsPreviewVew*)view model:(PHAsset*)model;
@end

@interface FBSelectAssetsPreviewVew : UIView
@property (nonatomic, weak ) id<FBSelectAssetsPreviewVewDelegate> delegate;
@property(nonatomic,assign) BOOL isThumSelected;
-(void)show;
-(void)hide;
+(CGFloat)height;

-(void)fillContent:(NSMutableArray <PHAsset *>*)selectVideoArr isShowGenVideoButton:(BOOL)isShowGenVideoButton;
@end

NS_ASSUME_NONNULL_END
