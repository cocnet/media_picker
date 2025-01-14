//
//  JYAlbumListView.h
//  VideoClip
//
//  Created by yzh on 2019/7/1.
//  Copyright © 2019 JYKJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TZAssetModel.h"

NS_ASSUME_NONNULL_BEGIN
typedef void(^DidSelectCellBlock)(PHAssetCollection *model);

@interface JYAlbumListView : UIView

@property (nonatomic, copy) DidSelectCellBlock didSelectBlock;

/// 刷新列表
//- (void)reloadAlbumList;

-(void)fillViewContent:(NSArray<PHAssetCollection *> *)list;
@end

NS_ASSUME_NONNULL_END
