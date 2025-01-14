//
//  JYAlbumListTableViewCell.h
//  VideoClip
//
//  Created by yzh on 2019/7/1.
//  Copyright © 2019 JYKJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TZAssetModel.h"
#import "JYCollectionViewImageTool.h"


NS_ASSUME_NONNULL_BEGIN

@interface JYAlbumListTableViewCell : UITableViewCell

- (void)setupModel:(TZAlbumModel *)model;
@end

NS_ASSUME_NONNULL_END
