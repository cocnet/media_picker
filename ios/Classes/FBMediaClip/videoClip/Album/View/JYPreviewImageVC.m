//
//  JYPreviewImageVC.m
//  VideoClip
//
//  Created by 杨志豪 on 2019/7/19.
//  Copyright © 2019 JYKJ. All rights reserved.
//

#import "JYPreviewImageVC.h"
#import "FBVideoCLipHeader.h"

@interface JYPreviewImageVC ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *chooseBtn;


@end

@implementation JYPreviewImageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

- (void)setupUI{
    self.title = NSLocalizedString(@"预览图片", nil);
    [self configDefaultNavigationBar];
    [self.chooseBtn setTitle:NSLocalizedString(@"选择图片", nil) forState:UIControlStateNormal];
    __weak typeof(self)weakSelf = self;
    [[PHImageManager defaultManager] requestImageForAsset:self.model.asset targetSize:CGSizeMake(self.imageView.width, self.imageView.height) contentMode:PHImageContentModeDefault options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.imageView.image = result;
        });
    }];
}

- (IBAction)selectButtonAction:(UIButton *)sender {
    [self.delegate passValue:self.model withTapIndexPath:self.path];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
