//
//  FBAlbumBottomTabbarView.m
//  FBVideoClip
//
//  Created by 杨志豪 on 3/17/22.
//

#import "FBAlbumBottomTabbarView.h"
#import "UIView+frame.h"
#import "FBVideoCLipHeader.h"
#import "JYToast.h"


@interface FBAlbumBottomTabbarView ()

@property (nonatomic,strong) UIView *pointView;

@property (weak, nonatomic) IBOutlet UIButton *albumBotton;

@property (weak, nonatomic) IBOutlet UIButton *makeVideo;

@property (weak, nonatomic) IBOutlet UIButton *makePhoto;


@end


@implementation FBAlbumBottomTabbarView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.pointView.hidden = NO;
    [self buttonAction:self.albumBotton];
}



-(UIView *)pointView {
    if (!_pointView) {
        _pointView = [[UIView alloc] initWithFrame:CGRectMake(0, 40, 20, 2)];
        _pointView.centerX = JY_SCREAN_WIDTH / 6;
        _pointView.layer.cornerRadius = 1;
        _pointView.layer.masksToBounds = YES;
        _pointView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_pointView];
    }
    return _pointView;
}

- (void)resetStatus {
    [self buttonAction:self.albumBotton];
}

- (IBAction)buttonAction:(UIButton *)sender {
    if (sender.selected) {
        return;;
    }
    if (self.type == FBTakePhtoTypeImage && sender == self.makeVideo) {
        [JYToast show:@"当前只能添加图片，无法进行拍摄视频"];
        return;
    } else if (self.type == FBTakePhtoTypeVideo && sender == self.makePhoto) {
        [JYToast show:@"当前只能添加视频，无法进行拍照"];
        return;
    }
    self.albumBotton.selected = NO;
    self.makePhoto.selected = NO;
    self.makeVideo.selected = NO;
    sender.selected = YES;
    [UIView animateWithDuration:0.2 animations:^{
        self.pointView.centerX = sender.centerX;
    }];
    if (sender == self.albumBotton) {
        [self.delegate hiddenTakePhotoView];
    } else {
        [self.delegate showTakePhotoView:sender == self.makePhoto];
    }
}


@end
