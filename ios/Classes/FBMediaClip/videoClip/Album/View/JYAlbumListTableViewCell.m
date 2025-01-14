//
//  JYAlbumListTableViewCell.m
//  VideoClip
//
//  Created by yzh on 2019/7/1.
//  Copyright © 2019 JYKJ. All rights reserved.
//

#import "JYAlbumListTableViewCell.h"
#import "FBVideoCLipHeader.h"
#import "TZImageManager.h"
#import <ReactiveObjC/ReactiveObjC.h>

@interface JYAlbumListTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *albumIconImageView;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UILabel *countLabel;


@end


@implementation JYAlbumListTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [UIColor clearColor];
    self.albumIconImageView.contentMode = UIViewContentModeScaleAspectFill;
}

- (void)setupModel:(PHAssetCollection *)model {
    if (model) {
        PHFetchResult<PHAsset *> *result = [PHAsset fetchAssetsInAssetCollection:model options:nil];
        self.nameLabel.text = model.localizedTitle;
        self.countLabel.text = [NSString stringWithFormat:@"%ld", result.count];
        
        @weakify(self);
        [[TZImageManager manager] getPhotoWithAsset:result.lastObject photoWidth:80 completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
            @strongify(self);
            self.albumIconImageView.image = photo;
            [self setNeedsLayout];
        }];
    }
}



@end
